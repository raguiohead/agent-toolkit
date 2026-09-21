---
name: start-task
description: "Start working on a feature. Reads feature details from PRD and feature_list.json, shows acceptance criteria, marks task as in-progress on ROADMAP."
disable-model-invocation: true
argument-hint: "[feature-id, e.g. F1]"
---

# /start-task — Begin Feature Implementation

The user wants to start working on a feature. The argument is the feature ID (e.g., "F1").

## Steps

1. **Parse argument**: Extract the feature ID from the argument. If no argument given, read ROADMAP.md and suggest the highest-priority incomplete task.

2. **Read feature details**:
   - Read `feature_list.json` — find the entry matching the feature ID
   - Read `PRD.md` — find the section for this feature

3. **Display task briefing**:
   ```
   Starting: {feature-id}: {feature name}

   Description:
   {description from PRD}

   Acceptance Criteria:
   {list from PRD}

   Verification Steps:
   {steps from feature_list.json}

   Priority: {priority}
   ```

4. **Update ROADMAP.md**: Change the feature's checkbox from `[ ]` to `[-]` and add the in-progress marker.

5. **Update claude-progress.txt**: Add a note that this task has been started.

6. **Begin implementation**: Start working on the feature according to the acceptance criteria.
