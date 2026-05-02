#!/usr/bin/env python3
"""Monday planning report generator for DevOps teams."""

import argparse
import datetime
import subprocess
import sys
from pathlib import Path

TEMPLATE = """# Monday Planning — Week {week} ({date})

## 1. Last Week Recap
- [ ] Deployments completed:
- [ ] Incidents / postmortems:
- [ ] Carry-over items:

## 2. This Week Goals
| Priority | Task | Owner | Due |
|----------|------|-------|-----|
| P1       |      |       |     |
| P2       |      |       |     |
| P3       |      |       |     |

## 3. Infrastructure Health Check
- [ ] CI/CD pipelines green
- [ ] Monitoring dashboards reviewed
- [ ] Certificate expirations checked
- [ ] Backup jobs verified
- [ ] Dependency vulnerability scan run

## 4. Deployments Planned This Week
| Service | Version | Environment | Date |
|---------|---------|-------------|------|
|         |         |             |      |

## 5. On-Call Rotation
- Primary:
- Secondary:
- Escalation:

## 6. Blockers & Risks
-

## 7. Notes
-
"""


def get_week_number() -> int:
    return datetime.date.today().isocalendar()[1]


def get_monday_date() -> datetime.date:
    today = datetime.date.today()
    return today - datetime.timedelta(days=today.weekday())


def generate_report(output_dir: Path) -> Path:
    monday = get_monday_date()
    week = get_week_number()
    filename = output_dir / f"planning-week-{week}-{monday.year}.md"

    content = TEMPLATE.format(
        week=week,
        date=monday.strftime("%Y-%m-%d"),
    )

    filename.write_text(content)
    return filename


def open_editor(path: Path) -> None:
    editor = subprocess.run(["git", "var", "GIT_EDITOR"], capture_output=True, text=True).stdout.strip()
    if not editor:
        editor = "vi"
    try:
        subprocess.run([editor, str(path)], check=True)
    except FileNotFoundError:
        print(f"Editor '{editor}' not found. File saved at: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate Monday DevOps planning document.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("docs/planning"),
        help="Directory where planning files are saved (default: docs/planning)",
    )
    parser.add_argument(
        "--no-edit",
        action="store_true",
        help="Skip opening the file in an editor",
    )
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    report = generate_report(args.output_dir)
    print(f"Planning document created: {report}")

    if not args.no_edit:
        open_editor(report)

    return 0


if __name__ == "__main__":
    sys.exit(main())
