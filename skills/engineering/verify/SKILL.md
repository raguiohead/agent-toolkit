---
name: verify
description: "Run acceptance verification for a feature against feature_list.json steps. Reports pass/fail for each step and updates tracking files."
disable-model-invocation: true
argument-hint: "[feature-id, e.g. F1]"
---

# /verify — Feature Acceptance Verification

The user wants to verify a feature. The argument is the feature ID (e.g., "F1").

## Steps

1. **Parse argument**: Extract the feature ID. If no argument, ask which feature to verify.

2. **Read verification steps**: Read `feature_list.json`, find the entry for this feature ID.

3. **Execute each verification step**:
   For each step in the `steps` array:
   - Execute or manually verify the step
   - Record result: PASS or FAIL
   - If a step requires running code/tests, run them

4. **Display results**:
   ```
   Verification Report: {feature-id}: {feature name}

   Step 1: {step description} — PASS / FAIL
   Step 2: {step description} — PASS / FAIL
   Step 3: {step description} — PASS / FAIL

   Result: {X}/{Y} steps passed — {PASSED / FAILED}
   ```

5. **If ALL steps pass**:
   - Update `feature_list.json`: set `passes: true` for this feature
   - Update `ROADMAP.md`: change `[-]` to `[x]`, add date, move to Completed section
   - Update `claude-progress.txt`: log the verification success

6. **If ANY step fails**:
   - Keep `passes: false`
   - Report which steps failed and why
   - Suggest fixes for the failures
