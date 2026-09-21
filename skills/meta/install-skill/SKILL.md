---
name: install-skill
description: "Install a skill from URL or search result. Supports GitHub repos, SkillsMP, and direct URLs. Handles MCP server configuration automatically."
disable-model-invocation: true
argument-hint: "[skill URL or name]"
---

# /install-skill — One-Click Skill Installation

Install a skill from a URL, GitHub repo, or search result.

## Steps

1. **Parse the input**:
   - If the argument is a **URL** (starts with `http`), use it directly.
   - If the argument is a **skill name**, search for it using `/find-skill` logic. If multiple results are found, use `AskUserQuestion` to present the top 3 candidates and let the user choose (users can select "Other" to specify a different match). If only one match is found, use it directly.
   - If no argument, use `AskUserQuestion` to ask the user for a skill URL or name.

2. **Determine the source type** and download/extract content (read-only, do NOT write files yet):

   ### GitHub Repository
   - If the URL points to a GitHub repo containing a `SKILL.md` or `.claude/skills/` directory:
     1. Use `WebFetch` to read the repository structure
     2. Identify the skill files (look for `SKILL.md`, or skill directories)
     3. Download the skill content using `WebFetch` on raw file URLs (e.g., `https://raw.githubusercontent.com/...`)
     4. Save the downloaded content for review
   - If the repo is a standalone skill (single SKILL.md at root):
     1. Extract the skill name from the SKILL.md frontmatter or repo name
     2. Save the downloaded content for review

   ### SkillsMP
   - If the URL is from `skillsmp.com`:
     1. Use `WebFetch` to get the skill page content
     2. Extract the skill definition/content

   ### Direct SKILL.md URL
   - If the URL points directly to a SKILL.md file:
     1. Use `WebFetch` to download the content
     2. Extract the skill name from frontmatter

3. **Security confirmation before install**:
   - After downloading the skill content, show the user a summary:
     - Skill name (from frontmatter)
     - Description (from frontmatter)
     - Commands it defines (any slash commands referenced in the SKILL.md)
   - Check if `.claude/skills/{skill-name}/` already exists. If so, add a warning to the summary: "⚠️ This skill is already installed. Installing will overwrite the existing version."
   - Adjust the AskUserQuestion options to: **"Yes, install (overwrite)"**, **"No, cancel"** when overwriting.
   - Use `AskUserQuestion` to ask: "Install this skill?" with options **"Yes, install"** and **"No, cancel"** (or the overwrite variants if already installed)
   - If user selects "No, cancel", abort installation and display "Installation cancelled."
   - Only proceed with writing files if user confirms "Yes, install"

4. **Write the skill files**:
   - Create the skill directory: `.claude/skills/{skill-name}/`
   - Write the downloaded SKILL.md content using the `Write` tool

5. **Check for MCP server requirements**:
   - Read the installed SKILL.md content
   - Look for references to MCP servers (e.g., `mcp add`, MCP configuration, external service dependencies)
   - If an MCP server is needed:
     1. Extract the MCP server name and command
     2. Run `claude mcp add {name} -- {command}` via `Bash`
     3. If API keys are needed, ask the user via `AskUserQuestion`

6. **Handle errors gracefully**:
   - **Network failure**: "Could not reach {url}. Please check your internet connection and try again."
   - **Invalid URL**: "The URL doesn't appear to contain a valid skill. Expected a repository with SKILL.md."
   - **Permission error**: "Could not write to .claude/skills/. Please check directory permissions."
   - **Format error**: "The skill file format is invalid. Expected YAML frontmatter with name and description fields."
   - For each error, suggest a fix or alternative approach.

7. **Show installation summary** on success:

   ```
   ✅ Skill installed successfully!

   📋 Summary:
   - Name: {skill-name}
   - Path: .claude/skills/{skill-name}/SKILL.md
   - Description: {description}
   - MCP Server: {configured/not needed}

   📖 Usage:
   - Run `/{skill-name}` to use this skill
   - {any additional usage notes from the SKILL.md}
   ```
