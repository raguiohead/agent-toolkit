---
name: progress
description: "Generate a project progress report from ROADMAP.md, feature_list.json, and claude-progress.txt. Shows completion rate, current tasks, and blockers."
disable-model-invocation: true
---

# /progress — Project Progress Report

Generate a comprehensive progress report.

## Steps

1. **Read all tracking files**:
   - Read `ROADMAP.md`
   - Read `feature_list.json`
   - Read `claude-progress.txt`

2. **Calculate metrics**:
   - Total features count
   - Completed features (passes: true)
   - In-progress features (marked [-] in ROADMAP)
   - Blocked features
   - Completion percentage

3. **Display report**:
   ```
   Project Progress Report

   Overall: {completed}/{total} features ({percentage}%)

   Completed:
   - F1: {name} — verified {date}

   In Progress:
   - F3: {name} — {brief status}

   Todo:
   - F4: {name} — {priority}

   Blocked:
   - (none or list blockers)

   Recent Activity:
   {Last 2-3 entries from claude-progress.txt}
   ```
