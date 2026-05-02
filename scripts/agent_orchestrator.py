#!/usr/bin/env python3
"""
24/7 autonomous multi-agent DevOps orchestrator.

Runs a pool of specialised agents continuously.  Each agent picks tasks
from a shared queue, executes them with prompt-cached streaming calls,
and reports usage to the central monitor.

Usage
-----
    # Start the orchestrator (blocks; Ctrl-C to stop)
    python agent_orchestrator.py

    # Enqueue a one-shot task from another process / CI pipeline
    python agent_orchestrator.py --enqueue code_review "Review deploy.yaml"

    # Print current usage dashboard
    python agent_orchestrator.py --dashboard
"""

import argparse
import asyncio
import json
import logging
import signal
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

import anthropic

sys.path.insert(0, str(Path(__file__).parent))
from agent_monitor import AgentMonitor        # noqa: E402
from devops_agent import DevOpsAgent, AgentTask  # noqa: E402

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("orchestrator")

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
TASK_QUEUE_FILE = Path("logs/task_queue.json")
AGENT_POOL: dict[str, list[str]] = {
    # task_type → list of agent names to handle it (first available wins)
    "code_review": ["agent-review-1", "agent-review-2"],
    "deploy":      ["agent-deploy-1"],
    "monitor":     ["agent-monitor-1"],
    "security":    ["agent-security-1"],
    "infra":       ["agent-infra-1"],
    "incident":    ["agent-incident-1"],
    "general":     ["agent-general-1", "agent-general-2"],
}
POLL_INTERVAL_S = 5          # how often to poll the queue
MAX_RETRIES = 3              # per task
BACKOFF_BASE_S = 2.0         # exponential backoff base
DASHBOARD_INTERVAL_S = 300   # print dashboard every N seconds


# ---------------------------------------------------------------------------
# Task queue (file-based for simplicity; swap for Redis / SQS in production)
# ---------------------------------------------------------------------------

@dataclass
class QueuedTask:
    id: str
    task_type: str
    content: str
    context: Optional[str] = None
    retries: int = 0
    enqueued_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    status: str = "pending"   # pending | running | done | failed


class TaskQueue:
    def __init__(self, path: Path = TASK_QUEUE_FILE) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._lock = asyncio.Lock()

    async def enqueue(self, task: QueuedTask) -> None:
        async with self._lock:
            tasks = self._load()
            tasks.append(vars(task))
            self._save(tasks)
        log.info("Enqueued task %s (%s)", task.id, task.task_type)

    async def next_pending(self, task_type: Optional[str] = None) -> Optional[QueuedTask]:
        async with self._lock:
            tasks = self._load()
            for i, t in enumerate(tasks):
                if t["status"] == "pending":
                    if task_type and t["task_type"] != task_type:
                        continue
                    tasks[i]["status"] = "running"
                    self._save(tasks)
                    return QueuedTask(**t)
        return None

    async def complete(self, task_id: str, success: bool) -> None:
        async with self._lock:
            tasks = self._load()
            for t in tasks:
                if t["id"] == task_id:
                    t["status"] = "done" if success else "failed"
                    break
            self._save(tasks)

    async def requeue(self, task: QueuedTask) -> None:
        """Return a failed task to 'pending' if retries remain."""
        async with self._lock:
            tasks = self._load()
            for t in tasks:
                if t["id"] == task.id:
                    t["retries"] += 1
                    t["status"] = "pending" if t["retries"] < MAX_RETRIES else "failed"
                    break
            self._save(tasks)

    def _load(self) -> list[dict]:
        if not self.path.exists():
            return []
        try:
            return json.loads(self.path.read_text())
        except (json.JSONDecodeError, ValueError):
            return []

    def _save(self, tasks: list[dict]) -> None:
        self.path.write_text(json.dumps(tasks, indent=2))


# ---------------------------------------------------------------------------
# Agent worker
# ---------------------------------------------------------------------------

async def agent_worker(
    name: str,
    task_types: list[str],
    queue: TaskQueue,
    monitor: AgentMonitor,
    stop_event: asyncio.Event,
) -> None:
    """Continuously dequeue and process tasks for one agent."""
    agent = DevOpsAgent(name, monitor)
    log.info("%s started, handles: %s", name, task_types)

    while not stop_event.is_set():
        task: Optional[QueuedTask] = None
        for tt in task_types:
            task = await queue.next_pending(tt)
            if task:
                break

        if task is None:
            await asyncio.sleep(POLL_INTERVAL_S)
            continue

        log.info("%s picked up task %s (%s)", name, task.id, task.task_type)
        try:
            agent.run(
                AgentTask(task.task_type, task.content, task.context),
                stream_stdout=False,  # silence in 24/7 mode; use logs
            )
            await queue.complete(task.id, success=True)
            log.info("%s completed task %s", name, task.id)
        except anthropic.RateLimitError:
            backoff = BACKOFF_BASE_S ** (task.retries + 1)
            log.warning("%s rate-limited on task %s; backoff %.0fs", name, task.id, backoff)
            await queue.requeue(task)
            await asyncio.sleep(backoff)
        except anthropic.APIStatusError as exc:
            if exc.status_code >= 500:
                backoff = BACKOFF_BASE_S ** (task.retries + 1)
                log.error("%s server error on task %s (%s); retry in %.0fs", name, task.id, exc.status_code, backoff)
                await queue.requeue(task)
                await asyncio.sleep(backoff)
            else:
                log.error("%s bad request on task %s (%s); dropping", name, task.id, exc.status_code)
                await queue.complete(task.id, success=False)
        except Exception as exc:
            log.exception("%s unexpected error on task %s: %s", name, task.id, exc)
            await queue.requeue(task)


# ---------------------------------------------------------------------------
# Dashboard printer
# ---------------------------------------------------------------------------

async def dashboard_printer(monitor: AgentMonitor, stop_event: asyncio.Event) -> None:
    while not stop_event.is_set():
        await asyncio.sleep(DASHBOARD_INTERVAL_S)
        if not stop_event.is_set():
            print(monitor.dashboard())


# ---------------------------------------------------------------------------
# Orchestrator entry point
# ---------------------------------------------------------------------------

async def run_orchestrator() -> None:
    queue = TaskQueue()
    monitor = AgentMonitor()
    stop_event = asyncio.Event()

    def _shutdown(*_):
        log.info("Shutdown signal received; stopping workers...")
        stop_event.set()

    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, _shutdown)

    # Build worker pool
    workers = []
    for task_type, agent_names in AGENT_POOL.items():
        for agent_name in agent_names:
            # Each agent only processes the task types it's assigned to
            assigned = [t for t, names in AGENT_POOL.items() if agent_name in names]
            workers.append(
                asyncio.create_task(
                    agent_worker(agent_name, assigned, queue, monitor, stop_event),
                    name=agent_name,
                )
            )

    workers.append(
        asyncio.create_task(
            dashboard_printer(monitor, stop_event),
            name="dashboard",
        )
    )

    log.info("Orchestrator running with %d workers. Ctrl-C to stop.", len(workers) - 1)

    await asyncio.gather(*workers, return_exceptions=True)
    print(monitor.dashboard())
    log.info("Orchestrator stopped.")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _make_task_id() -> str:
    import uuid
    return f"task-{uuid.uuid4().hex[:8]}"


def main() -> None:
    parser = argparse.ArgumentParser(description="DevOps agent orchestrator")
    parser.add_argument("--enqueue", nargs=2, metavar=("TASK_TYPE", "CONTENT"),
                        help="Add a task to the queue and exit")
    parser.add_argument("--context", help="Optional context for --enqueue")
    parser.add_argument("--dashboard", action="store_true",
                        help="Print usage dashboard and exit")
    args = parser.parse_args()

    if args.dashboard:
        print(AgentMonitor.from_file().dashboard())
        return

    if args.enqueue:
        task_type, content = args.enqueue
        task = QueuedTask(
            id=_make_task_id(),
            task_type=task_type,
            content=content,
            context=args.context,
        )
        asyncio.run(_enqueue_only(task))
        return

    asyncio.run(run_orchestrator())


async def _enqueue_only(task: QueuedTask) -> None:
    await TaskQueue().enqueue(task)
    print(f"Task {task.id} enqueued.")


if __name__ == "__main__":
    main()
