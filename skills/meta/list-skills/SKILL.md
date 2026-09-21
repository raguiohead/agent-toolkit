---
name: list-skills
description: "List all installed skills with their name, description, and source information."
disable-model-invocation: true
argument-hint: ""
---

# /list-skills — View Installed Skills

List all currently installed skills with details.

## Steps

1. **Scan the skills directory**: Use `Glob` to find all `SKILL.md` files under `.claude/skills/`.

2. **Read each skill's metadata**: For each `SKILL.md`, read the file and extract from YAML frontmatter:
   - **name**: The skill name
   - **description**: What the skill does
   - **source** (if present): Where the skill was installed from
   - **version** (if present): The skill version number
   - **argument-hint** (if present): Expected arguments

3. **Present the list**:

   ```
   📦 Installed Skills ({N} total):

   | # | Skill | Description | Version | Source |
   |---|-------|-------------|---------|--------|
   | 1 | /{name} | {description} | {version or "-"} | {source or "built-in"} |
   | 2 | /{name} | {description} | {version or "-"} | {source or "built-in"} |
   ...
   ```

4. **Show usage tip**:
   ```
   💡 Tips:
   - Use `/find-skill [query]` to search for new skills
   - Use `/recommend` to get skill recommendations for this project
   - Use `/uninstall-skill [name]` to remove a skill
   - Use `/update-skills` to check for updates
   ```
