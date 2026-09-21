---
name: next-task
description: "Find the highest-priority incomplete and unblocked task from ROADMAP.md and suggest starting it."
disable-model-invocation: true
---

# /next-task — Get Next Priority Task

Find and suggest the next task to work on.

## Steps

1. **Read tracking files**:
   - Read `ROADMAP.md`
   - Read `feature_list.json`

2. **Find next task**: Identify the highest-priority feature where:
   - `passes` is `false` in feature_list.json
   - Checkbox is `[ ]` (not in-progress or completed) in ROADMAP.md
   - Priority order: High > Medium > Low

3. **Display suggestion**:
   ```
   Next Task Recommendation

   {feature-id}: {feature name}
   Priority: {priority}
   Description: {brief description}

   Acceptance Criteria:
   {list from PRD}

   Use /start-task {feature-id} to begin.
   ```

4. **If no tasks remain**: Report "All features are complete! Consider running /verify on each to confirm, or /add-feature to add new work."
