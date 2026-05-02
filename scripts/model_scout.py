#!/usr/bin/env python3
"""
Model Scout — discovers new Claude models, benchmarks them against
your DevOps task types, and recommends the best model per task.

How it works
------------
1. Queries the Anthropic Models API to discover all currently available models.
2. Compares against a local registry to detect *newly released* models.
3. Runs a small benchmark suite (one sample prompt per task type) on each
   new model, tracking: latency, token usage, cache efficiency, output quality.
4. Saves results + persists a ranked recommendation per task type.
5. Can be scheduled (cron, systemd timer) or called from agent_orchestrator.py.

Usage
-----
    # Full scan + benchmark + update recommendations
    python model_scout.py

    # Just print current recommendations
    python model_scout.py --recommendations

    # Benchmark a specific model against all task types
    python model_scout.py --benchmark claude-sonnet-4-6

    # Watch for new models every hour (blocking)
    python model_scout.py --watch --interval 3600
"""

import argparse
import json
import logging
import sys
import time
from dataclasses import dataclass, asdict, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

import anthropic

sys.path.insert(0, str(Path(__file__).parent))
from agent_monitor import make_call_stats, AgentMonitor  # noqa: E402

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("model_scout")

REGISTRY_FILE     = Path("logs/model_registry.json")
BENCHMARK_FILE    = Path("logs/model_benchmarks.json")
RECOMMEND_FILE    = Path("logs/model_recommendations.json")

# ---------------------------------------------------------------------------
# Benchmark prompts — one representative sample per DevOps task type.
# Kept short deliberately so benchmark runs are cheap.
# ---------------------------------------------------------------------------
BENCHMARK_PROMPTS: dict[str, str] = {
    "code_review": (
        "Review this Python function for bugs and security issues:\n\n"
        "```python\n"
        "def get_user(db, user_id):\n"
        "    return db.execute(f'SELECT * FROM users WHERE id={user_id}')\n"
        "```"
    ),
    "deploy": (
        "Write a minimal Kubernetes Deployment manifest for a web service named "
        "'api-gateway' using image 'myrepo/api:v1.2', 2 replicas, port 8080, "
        "with liveness and readiness probes."
    ),
    "monitor": (
        "A Prometheus alert fires: 'HTTP 5xx rate > 2% for 5 minutes on service "
        "checkout'. List the first three things to check and the PromQL query to "
        "confirm the issue."
    ),
    "security": (
        "A Trivy scan reports CVE-2023-44487 (HTTP/2 Rapid Reset) in an nginx "
        "container. What is the impact and the recommended remediation steps?"
    ),
    "infra": (
        "Write a Terraform resource block to create an AWS S3 bucket with "
        "versioning enabled, server-side encryption (AES-256), and public "
        "access fully blocked."
    ),
    "incident": (
        "A production database is at 95% disk usage and writes are starting to "
        "fail. Describe an immediate mitigation runbook in numbered steps."
    ),
    "general": (
        "Explain the difference between blue/green and canary deployment "
        "strategies, and when to prefer each one."
    ),
}

# Minimum context window (tokens) required for our use cases
MIN_CONTEXT_TOKENS = 8_000


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class ModelInfo:
    id: str
    display_name: str
    max_input_tokens: int
    max_output_tokens: int
    first_seen: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    capabilities: dict = field(default_factory=dict)


@dataclass
class BenchmarkResult:
    model_id: str
    task_type: str
    timestamp: str
    latency_ms: float
    input_tokens: int
    output_tokens: int
    cache_creation_tokens: int
    cache_read_tokens: int
    estimated_cost_usd: float
    response_length: int
    error: Optional[str] = None

    @property
    def ok(self) -> bool:
        return self.error is None


@dataclass
class ModelRecommendation:
    task_type: str
    recommended_model: str
    reason: str
    avg_latency_ms: float
    avg_cost_usd: float
    updated_at: str


# ---------------------------------------------------------------------------
# Model discovery
# ---------------------------------------------------------------------------

class ModelRegistry:
    def __init__(self, path: Path = REGISTRY_FILE) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def load(self) -> dict[str, ModelInfo]:
        if not self.path.exists():
            return {}
        try:
            raw = json.loads(self.path.read_text())
            return {k: ModelInfo(**v) for k, v in raw.items()}
        except Exception:
            return {}

    def save(self, models: dict[str, ModelInfo]) -> None:
        self.path.write_text(json.dumps({k: asdict(v) for k, v in models.items()}, indent=2))

    def update(self, discovered: list[ModelInfo]) -> list[ModelInfo]:
        """Merge discovered models into registry. Returns list of *new* models."""
        existing = self.load()
        new_models: list[ModelInfo] = []
        for m in discovered:
            if m.id not in existing:
                new_models.append(m)
                log.info("New model detected: %s (%s)", m.id, m.display_name)
            existing[m.id] = m
        self.save(existing)
        return new_models


def discover_models(client: anthropic.Anthropic) -> list[ModelInfo]:
    """Fetch all models from the Anthropic Models API."""
    models: list[ModelInfo] = []
    for m in client.models.list():
        caps = {}
        try:
            caps = dict(m.capabilities) if hasattr(m, "capabilities") else {}
        except Exception:
            pass
        models.append(ModelInfo(
            id=m.id,
            display_name=getattr(m, "display_name", m.id),
            max_input_tokens=getattr(m, "max_input_tokens", 0),
            max_output_tokens=getattr(m, "max_tokens", 0),
            capabilities=caps,
        ))
    log.info("Discovered %d models from API", len(models))
    return models


def usable_models(models: list[ModelInfo]) -> list[ModelInfo]:
    """Filter to models suitable for our DevOps workloads."""
    return [m for m in models if m.max_input_tokens >= MIN_CONTEXT_TOKENS]


# ---------------------------------------------------------------------------
# Benchmarking
# ---------------------------------------------------------------------------

SYSTEM_PROMPT = (
    "You are a senior DevOps engineer. Answer concisely and accurately."
)


def benchmark_model(
    client: anthropic.Anthropic,
    model_id: str,
    task_type: str,
    prompt: str,
) -> BenchmarkResult:
    timestamp = datetime.now(timezone.utc).isoformat()
    start = time.monotonic()

    try:
        with client.messages.stream(
            model=model_id,
            max_tokens=1024,
            system=[{
                "type": "text",
                "text": SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"},
            }],
            messages=[{"role": "user", "content": prompt}],
        ) as stream:
            chunks = list(stream.text_stream)
            final = stream.get_final_message()

        latency_ms = (time.monotonic() - start) * 1000
        usage = final.usage
        stats = make_call_stats(
            agent_name="model_scout",
            task_type=task_type,
            model=model_id,
            usage=usage,
            duration_ms=latency_ms,
        )
        return BenchmarkResult(
            model_id=model_id,
            task_type=task_type,
            timestamp=timestamp,
            latency_ms=latency_ms,
            input_tokens=usage.input_tokens,
            output_tokens=usage.output_tokens,
            cache_creation_tokens=stats.cache_creation_tokens,
            cache_read_tokens=stats.cache_read_tokens,
            estimated_cost_usd=stats.estimated_cost_usd,
            response_length=sum(len(c) for c in chunks),
        )
    except Exception as exc:
        latency_ms = (time.monotonic() - start) * 1000
        log.warning("Benchmark failed for %s / %s: %s", model_id, task_type, exc)
        return BenchmarkResult(
            model_id=model_id,
            task_type=task_type,
            timestamp=timestamp,
            latency_ms=latency_ms,
            input_tokens=0, output_tokens=0,
            cache_creation_tokens=0, cache_read_tokens=0,
            estimated_cost_usd=0.0,
            response_length=0,
            error=str(exc),
        )


def run_benchmarks(
    client: anthropic.Anthropic,
    model_ids: list[str],
    task_types: Optional[list[str]] = None,
) -> list[BenchmarkResult]:
    if task_types is None:
        task_types = list(BENCHMARK_PROMPTS.keys())

    results: list[BenchmarkResult] = []
    total = len(model_ids) * len(task_types)
    done = 0
    for model_id in model_ids:
        for task_type in task_types:
            done += 1
            log.info("[%d/%d] Benchmarking %s / %s", done, total, model_id, task_type)
            result = benchmark_model(client, model_id, task_type, BENCHMARK_PROMPTS[task_type])
            results.append(result)
            # Small pause to avoid rate-limit bursts
            time.sleep(0.5)

    return results


# ---------------------------------------------------------------------------
# Persisting benchmark results
# ---------------------------------------------------------------------------

class BenchmarkStore:
    def __init__(self, path: Path = BENCHMARK_FILE) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def load(self) -> list[BenchmarkResult]:
        if not self.path.exists():
            return []
        try:
            return [BenchmarkResult(**r) for r in json.loads(self.path.read_text())]
        except Exception:
            return []

    def append(self, results: list[BenchmarkResult]) -> None:
        existing = self.load()
        existing.extend(results)
        self.path.write_text(json.dumps([asdict(r) for r in existing], indent=2))


# ---------------------------------------------------------------------------
# Recommendation engine
# ---------------------------------------------------------------------------

def build_recommendations(
    results: list[BenchmarkResult],
) -> dict[str, ModelRecommendation]:
    """
    For each task type, pick the model with the best score:
        score = (1 / latency_ms) * (1 / cost_usd) * response_length_bonus
    Only considers successful benchmark results.
    """
    from collections import defaultdict

    # Group by task_type then model_id
    by_task: dict[str, dict[str, list[BenchmarkResult]]] = defaultdict(lambda: defaultdict(list))
    for r in results:
        if r.ok:
            by_task[r.task_type][r.model_id].append(r)

    recommendations: dict[str, ModelRecommendation] = {}

    for task_type, models_data in by_task.items():
        best_model: Optional[str] = None
        best_score = -1.0
        best_latency = 0.0
        best_cost = 0.0

        for model_id, runs in models_data.items():
            avg_lat  = sum(r.latency_ms for r in runs) / len(runs)
            avg_cost = sum(r.estimated_cost_usd for r in runs) / len(runs)
            avg_len  = sum(r.response_length for r in runs) / len(runs)

            # Avoid division by zero
            if avg_lat < 1 or avg_cost < 1e-9:
                continue

            # Higher is better: fast, cheap, verbose (length as quality proxy)
            score = (1 / avg_lat) * (1 / avg_cost) * (avg_len ** 0.3)

            if score > best_score:
                best_score = score
                best_model = model_id
                best_latency = avg_lat
                best_cost = avg_cost

        if best_model:
            runner_up_count = len(models_data) - 1
            reason = (
                f"Best composite score (latency × cost × response quality) "
                f"across {runner_up_count + 1} models benchmarked on '{task_type}' tasks."
            )
            recommendations[task_type] = ModelRecommendation(
                task_type=task_type,
                recommended_model=best_model,
                reason=reason,
                avg_latency_ms=round(best_latency, 1),
                avg_cost_usd=round(best_cost, 6),
                updated_at=datetime.now(timezone.utc).isoformat(),
            )

    return recommendations


class RecommendationStore:
    def __init__(self, path: Path = RECOMMEND_FILE) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def save(self, recs: dict[str, ModelRecommendation]) -> None:
        self.path.write_text(json.dumps({k: asdict(v) for k, v in recs.items()}, indent=2))

    def load(self) -> dict[str, ModelRecommendation]:
        if not self.path.exists():
            return {}
        try:
            return {k: ModelRecommendation(**v) for k, v in json.loads(self.path.read_text()).items()}
        except Exception:
            return {}

    def best_model_for(self, task_type: str, fallback: str = "claude-sonnet-4-6") -> str:
        recs = self.load()
        if task_type in recs:
            return recs[task_type].recommended_model
        return fallback


def print_recommendations(recs: dict[str, ModelRecommendation]) -> None:
    if not recs:
        print("No recommendations available yet. Run model_scout.py to generate them.")
        return
    print("=" * 72)
    print("  Model Recommendations by Task Type")
    print("=" * 72)
    for task_type, rec in sorted(recs.items()):
        print(f"  {task_type:<15} → {rec.recommended_model}")
        print(f"  {'':15}   lat={rec.avg_latency_ms:.0f}ms  cost=${rec.avg_cost_usd:.5f}")
        print(f"  {'':15}   {rec.reason}")
        print()
    print(f"  Updated: {max(r.updated_at for r in recs.values())}")
    print("=" * 72)


# ---------------------------------------------------------------------------
# Full scout cycle
# ---------------------------------------------------------------------------

def scout_cycle(
    client: anthropic.Anthropic,
    registry: ModelRegistry,
    bench_store: BenchmarkStore,
    rec_store: RecommendationStore,
    force_all: bool = False,
) -> None:
    discovered = discover_models(client)
    suitable   = usable_models(discovered)
    new_models = registry.update(discovered)

    models_to_benchmark = suitable if force_all else [
        m for m in suitable if m.id in {n.id for n in new_models}
    ]

    if not models_to_benchmark:
        log.info("No new models to benchmark.")
    else:
        log.info("Benchmarking %d model(s): %s", len(models_to_benchmark),
                 [m.id for m in models_to_benchmark])
        results = run_benchmarks(client, [m.id for m in models_to_benchmark])
        bench_store.append(results)
        log.info("Benchmarks complete. Updating recommendations...")

    # Rebuild recommendations from all historical data
    all_results = bench_store.load()
    if all_results:
        recs = build_recommendations(all_results)
        rec_store.save(recs)
        print_recommendations(recs)
    else:
        log.info("No benchmark data yet; skipping recommendation update.")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Model Scout — discover and benchmark new Claude models")
    parser.add_argument("--recommendations", action="store_true",
                        help="Print current recommendations and exit")
    parser.add_argument("--benchmark", metavar="MODEL_ID",
                        help="Benchmark a specific model against all task types")
    parser.add_argument("--force-all", action="store_true",
                        help="Benchmark all known models (not just new ones)")
    parser.add_argument("--watch", action="store_true",
                        help="Run continuously, polling for new models")
    parser.add_argument("--interval", type=int, default=3600,
                        help="Poll interval in seconds when --watch is set (default: 3600)")
    args = parser.parse_args()

    client    = anthropic.Anthropic()
    registry  = ModelRegistry()
    bench     = BenchmarkStore()
    rec_store = RecommendationStore()

    if args.recommendations:
        print_recommendations(rec_store.load())
        return

    if args.benchmark:
        log.info("Benchmarking model: %s", args.benchmark)
        results = run_benchmarks(client, [args.benchmark])
        bench.append(results)
        recs = build_recommendations(bench.load())
        rec_store.save(recs)
        print_recommendations(recs)
        return

    if args.watch:
        log.info("Watch mode: polling every %ds", args.interval)
        while True:
            try:
                scout_cycle(client, registry, bench, rec_store, force_all=args.force_all)
            except Exception as exc:
                log.exception("Scout cycle error: %s", exc)
            log.info("Next check in %ds", args.interval)
            time.sleep(args.interval)
    else:
        scout_cycle(client, registry, bench, rec_store, force_all=args.force_all)


if __name__ == "__main__":
    main()
