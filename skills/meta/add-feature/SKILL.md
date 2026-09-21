---
name: add-feature
description: "Add a new feature to the project. Collects info via interview, then updates PRD.md, feature_list.json, and ROADMAP.md."
disable-model-invocation: true
argument-hint: "[brief description of new feature]"
---

# /add-feature — Add New Feature

Add a new feature to the project management framework.

## Steps

1. **Determine next feature ID**: Read `feature_list.json`, find the highest existing ID number, increment by 1.

2. **Collect feature info** using `AskUserQuestion`:
   - Feature name
   - Description: What does this feature do?
   - User story: As a ___, I want to ___ so that ___
   - Priority: High / Medium / Low
   - Acceptance criteria (2-5 items)

   If the argument already provides a description, use it and ask only for missing details.

3. **Generate verification steps**: Convert acceptance criteria into concrete, testable verification steps for feature_list.json.

4. **Update all three files**:
   a. **PRD.md**: Append a new feature section following the existing format
   b. **feature_list.json**: Add a new entry
   c. **ROADMAP.md**: Add the feature under the appropriate priority section

5. **Confirm**: Display the new feature summary and its ID.
