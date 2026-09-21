---
name: update-skills
description: "Check installed skills for available updates by comparing against their source repositories."
disable-model-invocation: true
argument-hint: "[skill-name (optional, checks all if omitted)]"
---

# /update-skills — Check & Update Installed Skills

Check installed skills for updates and apply them. Skills should include `version` and `source` fields in their YAML frontmatter for reliable update tracking.

## Steps

1. **Scan installed skills**: Use `Glob` to find all `SKILL.md` files under `.claude/skills/`. Read each file's frontmatter to get the skill name and source URL.

2. **Check for updates**: For each skill that has a source URL:
   - Use `WebFetch` to fetch the latest version from the source URL
   - If both the local and remote SKILL.md have a `version` field in frontmatter, compare versions to determine if an update is available
   - If no `version` field is present, fall back to content comparison: compare the fetched content with the locally installed SKILL.md, and if the content differs, mark the skill as having an update available
   - If the source URL is unreachable, note it and continue

3. **Skip skills without source**: Built-in skills (no `source` field in frontmatter) → mark as "built-in, skip" in the report.

4. **Present update report**:

   ```
   🔄 Update Check Results:

   Updates available:
   - **{skill-name}**: New version available from {source}
   - **{skill-name}**: New version available from {source}

   Up to date:
   - **{skill-name}**: No changes detected
   - **{skill-name}**: No changes detected

   Skipped (no source URL):
   - **{skill-name}**: Built-in skill, no remote source

   ⚠️ Unreachable:
   - **{skill-name}**: Could not reach {source}
   ```

5. **Offer updates**: If updates are available, use `AskUserQuestion` with `multiSelect: true`:

   Note: `AskUserQuestion` supports a maximum of 4 options. If more than 3 skills have updates, first list all updatable skills in the Step 4 report, then offer the top 3 as quick-select options here. Users can select "Other" to specify additional skills by name.

   - Question: "Which skills would you like to update?"
   - Options: each skill with an available update as a selectable option
     - Label: `{skill-name}`
     - Description: `New version available from {source}`
   - If user selects skills, proceed to apply updates for the selected ones.
   - If user selects none, display "No updates applied."
   - If no updates are available, skip this step.

6. **Apply updates** for selected skills:
   - For each skill to update, download the latest SKILL.md from the source
   - Back up the current version by appending `.backup` to the filename
   - Write the new content
   - Report success or failure for each update

7. **Show summary**:
   ```
   ✅ Updated {N} skill(s):
   - {skill-name}: Updated successfully
   - {skill-name}: Updated successfully

   💡 Backups saved as SKILL.md.backup in each skill directory.
   ```
