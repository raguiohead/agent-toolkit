---
name: standup
description: "Generate a standup-style report: what was done, what's planned, and what's blocked. Based on claude-progress.txt and ROADMAP.md."
disable-model-invocation: true
---

# /standup — Daily Standup Report

Generate a standup-style status report.

## Steps

1. **Read tracking files**:
   - Read `claude-progress.txt` — get the most recent session entry
   - Read `ROADMAP.md` — get current task statuses
   - Read `feature_list.json` — get verification statuses

2. **Generate report**:
   ```
   Standup Report — {today's date}

   Completed (since last session):
   - {items from latest claude-progress.txt "Completed" section}

   Working On Today:
   - {items marked [-] in ROADMAP or from "In Progress" section}
   - {next priority task if nothing is in progress}

   Blockers:
   - {items from "Blocked" section, or "None"}

   Overall Progress:
   {completed}/{total} features complete ({percentage}%)
   ```
