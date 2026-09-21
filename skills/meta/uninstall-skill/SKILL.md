---
name: uninstall-skill
description: "Uninstall a skill by removing its directory and cleaning up related MCP server configurations."
disable-model-invocation: true
argument-hint: "[skill-name]"
---

# /uninstall-skill — Remove an Installed Skill

Uninstall a skill and clean up its configuration.

## Steps

1. **Parse the skill name** from the argument. If no argument, list installed skills using `/list-skills` logic and use `AskUserQuestion` to ask which skill to uninstall.

   Note: `AskUserQuestion` supports a maximum of 4 options. If more than 3 skills are installed, first present the full numbered list as text output, then offer the top 3 as options. Users can select "Other" to specify a different skill by name or number.

2. **Verify the skill exists**:
   - Validate the skill name: it must contain only alphanumeric characters, hyphens (`-`), and underscores (`_`). Reject names containing path separators (`/`, `\`), dots (`..`), or other special characters. If invalid, report: "Invalid skill name. Skill names can only contain letters, numbers, hyphens, and underscores."
   - Check if `.claude/skills/{skill-name}/` directory exists.
   - If not found, try a case-insensitive match against existing skill directories.
   - If still not found, report: "Skill '{skill-name}' is not installed. Use `/list-skills` to see installed skills."

3. **Read the skill before removal**: Read the SKILL.md to check for MCP server references.

4. **Confirm with user**: Use `AskUserQuestion` to confirm:
   - "Are you sure you want to uninstall **{skill-name}**? ({description})"
   - Options: "Yes, uninstall" / "No, cancel"

5. **Remove the skill**:
   - Delete the entire `.claude/skills/{skill-name}/` directory using `Bash` (`rm -rf`)
   - If the SKILL.md referenced an MCP server, run `claude mcp remove {server-name}` to clean up the MCP configuration

6. **Report result**:

   ```
   ✅ Skill uninstalled:
   - Name: {skill-name}
   - Removed: .claude/skills/{skill-name}/
   - MCP cleanup: {removed server-name / no MCP servers to clean}
   ```
