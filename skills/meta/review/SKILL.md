---
name: review
description: "Review recent code changes against PRD acceptance criteria. Generates a review report with findings and recommendations."
disable-model-invocation: true
---

# /review — Code Review Against PRD

Review recent code changes against the product requirements.

## Steps

1. **Get recent changes**:
   ```bash
   git log --oneline -10
   git diff HEAD~1
   ```
   If no git history, review the most recently modified files.

2. **Read requirements**:
   - Read `PRD.md` — get acceptance criteria for relevant features
   - Read `feature_list.json` — get verification steps

3. **Review against criteria**: For each changed file/feature:
   - Does the implementation match the PRD description?
   - Are acceptance criteria being addressed?
   - Are there edge cases not handled?
   - Are there potential bugs or issues?
   - Is the code consistent with project patterns?

4. **Generate review report**:
   ```
   Code Review Report

   Changes Reviewed:
   - {list of files/features reviewed}

   Looks Good:
   - {things that are well implemented}

   Concerns:
   - {potential issues, missing edge cases, etc.}

   Suggestions:
   - {improvement recommendations}

   PRD Alignment:
   - {how well changes align with PRD requirements}
   ```
