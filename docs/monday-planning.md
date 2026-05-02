# Monday Planning Process

Weekly planning ritual for the DevOps team, run every Monday morning.

## Quick Start

```bash
python3 scripts/monday_planning.py
```

This generates a pre-filled Markdown template in `docs/planning/` and opens it in your `$GIT_EDITOR`.

## Options

| Flag | Description |
|------|-------------|
| `--output-dir PATH` | Override output directory (default: `docs/planning/`) |
| `--no-edit` | Generate file without opening an editor |

## Template Sections

1. **Last Week Recap** — Deployments shipped, incidents closed, carry-overs.
2. **This Week Goals** — Prioritised task table with owner and due date.
3. **Infrastructure Health Check** — Checklist: CI, monitoring, certs, backups, CVE scan.
4. **Deployments Planned** — Services, versions, environments, and target dates.
5. **On-Call Rotation** — Primary, secondary, and escalation contacts.
6. **Blockers & Risks** — Anything that could slow the week down.
7. **Notes** — Free-form space.

## File Naming

Files are saved as `planning-week-<ISO_WEEK>-<YEAR>.md`, e.g. `planning-week-18-2026.md`.

## Recommended Workflow

1. Run the script at the start of Monday standup.
2. Fill in the table collaboratively during the meeting.
3. Commit the file to the repo so it serves as a historical record.

```bash
git add docs/planning/planning-week-*.md
git commit -m "chore: add week $(date +%V) planning doc"
```
