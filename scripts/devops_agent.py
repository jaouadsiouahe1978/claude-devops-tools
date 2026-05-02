#!/usr/bin/env python3
"""
DevOps agent with optimised prompt caching and streaming.

Stable system prompt is cached (cache_control: ephemeral).
Per-call volatile context is appended after the cache breakpoint so the
cached prefix is never invalidated between requests.
"""

import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import anthropic

# Allow running directly from scripts/
sys.path.insert(0, str(Path(__file__).parent))
from agent_monitor import AgentMonitor, make_call_stats  # noqa: E402

MODEL = "claude-sonnet-4-6"

# ---------------------------------------------------------------------------
# Stable system prompt — this entire block is cached on the first call and
# reused on every subsequent call, cutting input costs by ~90 % for repeated
# requests to the same agent.
# ---------------------------------------------------------------------------
_SYSTEM_STABLE = """You are a senior DevOps / SRE engineer embedded in an \
automated pipeline.  Your job is to analyse, plan, and respond to DevOps \
tasks with precision.

## Capabilities
- Infrastructure as Code: Terraform, Ansible, CloudFormation
- CI/CD: GitHub Actions, GitLab CI, Jenkins, ArgoCD
- Containers & orchestration: Docker, Kubernetes, Helm
- Observability: Prometheus, Grafana, ELK, OpenTelemetry
- Cloud platforms: AWS, GCP, Azure
- Security: SAST, DAST, CVE triage, secret scanning, IAM review
- Databases: PostgreSQL, MySQL, Redis, MongoDB
- Scripting: Python, Bash, Go

## Response format
Return structured responses:
1. **Assessment** — what you found / understand about the task
2. **Plan** — numbered steps you will take
3. **Output** — actual result (code, config, analysis, recommendation)
4. **Risks** — anything the operator should watch for

## Rules
- Be concise; skip preamble.
- If you need information that was not provided, state what is missing.
- Always output production-ready artifacts (lint-clean, documented).
- Never suggest hard-deletes without explicit confirmation in the task.
- Flag security issues immediately, before anything else.

## Task types you handle
| Type          | Description                                     |
|---------------|-------------------------------------------------|
| code_review   | Review code / config for bugs, security, style  |
| deploy        | Produce or validate deployment manifests        |
| monitor       | Analyse metrics, logs, alerts                   |
| security      | CVE triage, secret scanning, IAM review         |
| infra         | Terraform / Ansible / config generation         |
| incident      | Incident analysis and runbook generation        |
| general       | Everything else                                 |
"""


@dataclass
class AgentTask:
    task_type: str
    content: str
    context: Optional[str] = None


@dataclass
class AgentResult:
    text: str
    cache_hit_rate: float
    estimated_cost_usd: float
    duration_ms: float


class DevOpsAgent:
    """Single DevOps agent with an internal conversation window."""

    def __init__(
        self,
        name: str,
        monitor: AgentMonitor,
        max_history_turns: int = 10,
    ) -> None:
        self.name = name
        self.monitor = monitor
        self.client = anthropic.Anthropic()
        self._history: list[dict] = []
        self._max_turns = max_history_turns

    # ------------------------------------------------------------------ #
    # Public API                                                           #
    # ------------------------------------------------------------------ #

    def run(self, task: AgentTask, *, stream_stdout: bool = True) -> AgentResult:
        """Execute a task, stream output to stdout, record usage, return result."""
        messages = self._history + [
            {"role": "user", "content": self._format_task(task)}
        ]

        start = time.monotonic()
        chunks: list[str] = []

        with self.client.messages.stream(
            model=MODEL,
            max_tokens=8192,
            system=self._build_system(),
            messages=messages,
        ) as stream:
            for text in stream.text_stream:
                if stream_stdout:
                    print(text, end="", flush=True)
                chunks.append(text)
            final = stream.get_final_message()

        duration_ms = (time.monotonic() - start) * 1000
        response_text = "".join(chunks)

        call_stats = make_call_stats(
            agent_name=self.name,
            task_type=task.task_type,
            model=MODEL,
            usage=final.usage,
            duration_ms=duration_ms,
        )
        self.monitor.record(call_stats)

        # Update rolling conversation window
        self._history = messages + [{"role": "assistant", "content": response_text}]
        if len(self._history) > self._max_turns * 2:
            # Drop oldest pair (user+assistant) while keeping system anchor
            self._history = self._history[2:]

        if stream_stdout:
            print()  # newline after streamed output

        return AgentResult(
            text=response_text,
            cache_hit_rate=call_stats.cache_hit_rate,
            estimated_cost_usd=call_stats.estimated_cost_usd,
            duration_ms=duration_ms,
        )

    def reset(self) -> None:
        """Clear conversation history (keeps cached system prompt intact)."""
        self._history = []

    # ------------------------------------------------------------------ #
    # Internals                                                            #
    # ------------------------------------------------------------------ #

    def _build_system(self) -> list[dict]:
        """System prompt with cache breakpoint after the stable block."""
        return [
            {
                "type": "text",
                "text": _SYSTEM_STABLE,
                # Everything up to this breakpoint is cached.
                # Volatile context (timestamps, per-call IDs) must come
                # AFTER this breakpoint in the messages array, not here.
                "cache_control": {"type": "ephemeral"},
            }
        ]

    @staticmethod
    def _format_task(task: AgentTask) -> str:
        parts = [f"**Task type**: `{task.task_type}`"]
        if task.context:
            parts.append(f"**Context**:\n{task.context}")
        parts.append(f"**Request**:\n{task.content}")
        return "\n\n".join(parts)


# ---------------------------------------------------------------------------
# CLI convenience
# ---------------------------------------------------------------------------

def _cli() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Run a single DevOps agent task.")
    parser.add_argument("task_type", help="code_review | deploy | monitor | security | infra | incident | general")
    parser.add_argument("content", help="Task description / content")
    parser.add_argument("--context", help="Optional extra context")
    args = parser.parse_args()

    monitor = AgentMonitor()
    agent = DevOpsAgent("cli-agent", monitor)
    result = agent.run(AgentTask(args.task_type, args.content, args.context))
    print(f"\n[cache hit: {result.cache_hit_rate:.0%}  cost: ${result.estimated_cost_usd:.4f}  {result.duration_ms:.0f}ms]")
    print(monitor.dashboard())


if __name__ == "__main__":
    _cli()
