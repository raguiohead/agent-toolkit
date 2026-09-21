---
name: prd-update
description: "Update a specific section of PRD.md and sync changes to feature_list.json if features are affected."
disable-model-invocation: true
argument-hint: "[section to update, e.g. 'F1' or 'constraints']"
---

# /prd-update — Update PRD Section

Update a section of the Product Requirements Document.

## Steps

1. **Read current PRD.md** to understand the full document structure.

2. **Identify section**: Parse the argument to determine which section to update:
   - If it's a feature ID (e.g., "F1") → update that feature's section
   - If it's a section name (e.g., "constraints", "nfr", "milestones") → update that section
   - If no argument → ask the user which section to update

3. **Collect updates**: Ask the user what changes they want to make to this section using `AskUserQuestion`.

4. **Apply changes to PRD.md**: Edit the specified section with the new content.

5. **Sync to feature_list.json** (if a feature was updated):
   - If acceptance criteria changed → update the `steps` array
   - If priority changed → update the `priority` field
   - If description changed → update the `description` field

6. **Sync to ROADMAP.md** (if priority changed): Move the feature to the correct priority section.

7. **Confirm**: Show what was changed and which files were updated.
