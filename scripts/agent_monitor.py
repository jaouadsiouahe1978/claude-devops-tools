#!/usr/bin/env python3
"""Token and cache consumption monitoring for Claude DevOps agents."""

import json
import time
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path

STATS_FILE = Path("logs/agent_usage.json")

# claude-sonnet-4-6 pricing (USD per token)
_PRICE = {
    "input":         3.00e-6,
    "output":       15.00e-6,
    "cache_write":   3.75e-6,   # 1.25x input
    "cache_read":    0.30e-6,   # 0.1x input
}


@dataclass
class CallStats:
    agent_name: str
    task_type: str
    model: str
    timestamp: str
    input_tokens: int
    output_tokens: int
    cache_creation_tokens: int
    cache_read_tokens: int
    duration_ms: float

    @property
    def total_prompt_tokens(self) -> int:
        return self.input_tokens + self.cache_creation_tokens + self.cache_read_tokens

    @property
    def cache_hit_rate(self) -> float:
        if self.total_prompt_tokens == 0:
            return 0.0
        return self.cache_read_tokens / self.total_prompt_tokens

    @property
    def estimated_cost_usd(self) -> float:
        return (
            self.input_tokens * _PRICE["input"]
            + self.output_tokens * _PRICE["output"]
            + self.cache_creation_tokens * _PRICE["cache_write"]
            + self.cache_read_tokens * _PRICE["cache_read"]
        )

    @property
    def cost_without_cache_usd(self) -> float:
        """What this call would have cost with no caching."""
        return self.total_prompt_tokens * _PRICE["input"] + self.output_tokens * _PRICE["output"]

    @property
    def cache_savings_usd(self) -> float:
        return max(0.0, self.cost_without_cache_usd - self.estimated_cost_usd)


class AgentMonitor:
    """Records and reports Claude API usage across multiple agents."""

    def __init__(self, stats_file: Path = STATS_FILE) -> None:
        self.stats_file = stats_file
        self.stats_file.parent.mkdir(parents=True, exist_ok=True)
        self._session: list[CallStats] = []

    # ------------------------------------------------------------------ #
    # Recording                                                            #
    # ------------------------------------------------------------------ #

    def record(self, stats: CallStats) -> None:
        self._session.append(stats)
        self._append_to_file(stats)

    def _append_to_file(self, stats: CallStats) -> None:
        records: list[dict] = []
        if self.stats_file.exists():
            try:
                records = json.loads(self.stats_file.read_text())
            except (json.JSONDecodeError, ValueError):
                pass
        records.append(asdict(stats))
        self.stats_file.write_text(json.dumps(records, indent=2))

    # ------------------------------------------------------------------ #
    # Reporting                                                            #
    # ------------------------------------------------------------------ #

    def dashboard(self, last_n: int = 0) -> str:
        data = self._session[-last_n:] if last_n else self._session
        if not data:
            return "No usage data recorded yet."

        total_in      = sum(s.input_tokens for s in data)
        total_out     = sum(s.output_tokens for s in data)
        total_cw      = sum(s.cache_creation_tokens for s in data)
        total_cr      = sum(s.cache_read_tokens for s in data)
        total_cost    = sum(s.estimated_cost_usd for s in data)
        total_savings = sum(s.cache_savings_usd for s in data)
        avg_hit_rate  = sum(s.cache_hit_rate for s in data) / len(data)
        avg_latency   = sum(s.duration_ms for s in data) / len(data)

        by_agent: dict[str, list[CallStats]] = {}
        for s in data:
            by_agent.setdefault(s.agent_name, []).append(s)

        lines = [
            "=" * 64,
            "  Claude Agent Usage Dashboard",
            "=" * 64,
            f"  Calls         : {len(data):>8}",
            f"  Input tokens  : {total_in:>8,}",
            f"  Output tokens : {total_out:>8,}",
            f"  Cache written : {total_cw:>8,}",
            f"  Cache read    : {total_cr:>8,}",
            f"  Avg cache hit : {avg_hit_rate:>8.1%}",
            f"  Avg latency   : {avg_latency:>7.0f} ms",
            f"  Estimated cost: ${total_cost:>8.4f}",
            f"  Cache savings : ${total_savings:>8.4f}",
            "-" * 64,
            "  Per agent:",
        ]
        for name, agent_data in sorted(by_agent.items()):
            agent_cost = sum(s.estimated_cost_usd for s in agent_data)
            agent_hit  = sum(s.cache_hit_rate for s in agent_data) / len(agent_data)
            lines.append(
                f"    {name:<20} calls={len(agent_data):>4}  "
                f"hit={agent_hit:.0%}  cost=${agent_cost:.4f}"
            )
        lines.append("=" * 64)
        return "\n".join(lines)

    @classmethod
    def from_file(cls, stats_file: Path = STATS_FILE) -> "AgentMonitor":
        monitor = cls(stats_file)
        if stats_file.exists():
            try:
                for record in json.loads(stats_file.read_text()):
                    monitor._session.append(CallStats(**record))
            except Exception:
                pass
        return monitor


def make_call_stats(
    *,
    agent_name: str,
    task_type: str,
    model: str,
    usage,           # anthropic.types.Usage
    duration_ms: float,
) -> CallStats:
    """Build a CallStats from an Anthropic SDK usage object."""
    return CallStats(
        agent_name=agent_name,
        task_type=task_type,
        model=model,
        timestamp=datetime.now(timezone.utc).isoformat(),
        input_tokens=usage.input_tokens,
        output_tokens=usage.output_tokens,
        cache_creation_tokens=getattr(usage, "cache_creation_input_tokens", 0) or 0,
        cache_read_tokens=getattr(usage, "cache_read_input_tokens", 0) or 0,
        duration_ms=duration_ms,
    )


if __name__ == "__main__":
    monitor = AgentMonitor.from_file()
    print(monitor.dashboard())
