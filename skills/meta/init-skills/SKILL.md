---
name: init-skills
description: "Tell me what project you're building, and I'll automatically search skill marketplaces, find matching skills, and install them for you. Just describe your project in plain language."
disable-model-invocation: true
argument-hint: "[describe your project, e.g. 'React + TypeScript e-commerce app']"
---

# /init-skills — One-Sentence Project Setup

User describes their project → auto-detect tech stack → search skill markets → install everything.

## Steps

1. **Get project description**:
   - If the user provided an argument (e.g., `/init-skills React TypeScript e-commerce`), use that as the project description.
   - If no argument AND project config files exist (package.json, etc.), auto-detect the tech stack (see step 2a).
   - If no argument AND no config files, use `AskUserQuestion` to ask:
     - Question: "What kind of project are you building? Describe it in one sentence."
     - Options: "React/Next.js Web App", "Python Backend (Django/FastAPI)", "Full-Stack TypeScript", "Other (I'll describe it)"

2. **Identify technologies** from the project description or config files:

   ### 2a. Auto-detect from config files (if they exist)
   Use `Glob` to check for these files and `Read` to extract dependencies:
   | File | Extract |
   |------|---------|
   | `package.json` | `dependencies` + `devDependencies` keys → React, Vue, Next.js, Express, TypeScript, etc. |
   | `tsconfig.json` | TypeScript |
   | `Cargo.toml` | Rust + crate names |
   | `go.mod` | Go + module dependencies |
   | `requirements.txt` / `pyproject.toml` | Python + Django/Flask/FastAPI etc. |
   | `Gemfile` | Ruby + Rails |
   | `Dockerfile` | Docker |

   ### 2b. Parse from natural language description
   Extract technology keywords from the user's description. Examples:
   - "React 电商项目" → keywords: `react`, `e-commerce`, `frontend`
   - "Python FastAPI 后端" → keywords: `python`, `fastapi`, `backend`, `api`
   - "全栈 TypeScript" → keywords: `typescript`, `fullstack`, `node`

   Combine both sources (config files + description) for the most complete keyword list.

3. **Show detected tech stack** and confirm:
   ```
   📊 Project Profile:
   - Description: {user's description}
   - Detected technologies: {tech1}, {tech2}, {tech3}
   - Currently installed skills: {N}

   🔍 Searching skill marketplaces...
   ```

4. **Search ALL marketplaces** for each technology keyword. For each keyword, search all 4 sources in parallel:

   For each technology keyword (e.g., "react", "typescript", "testing"):

   - **SkillsMP**: `WebSearch` → `"{keyword} claude skill site:skillsmp.com"`
   - **GitHub**: Use `Bash` → `gh api search/repositories -X GET -f q="claude skill {keyword}"` to search. If `gh` is not available, fall back to `WebSearch` → `"{keyword} claude code skill site:github.com"`
   - **SkillHub**: `WebSearch` → `"{keyword} claude skill site:skillhub.club"`
   - **Anthropic Official**: `WebSearch` → `"anthropic official claude skill {keyword} site:github.com"` or use `Bash` → `gh api search/repositories -X GET -f q="claude skill {keyword} org:anthropics"`

   If any source fails, skip it and continue. Record which sources were unavailable.

   For each result found, extract:
   - `name`: Skill name
   - `description`: What it does
   - `source`: Which marketplace (SkillsMP / GitHub / SkillHub / Anthropic Official)
   - `install_url`: URL to install from
   - `relevance`: Which technology keyword matched

5. **Deduplicate and filter**:
   - Remove duplicate skills (same name from different sources — keep the one from the most reliable source)
   - Read `.claude/skills/` directory to get list of already-installed skills
   - Remove any skill that's already installed (match by name, case-insensitive)
   - Sort by relevance: exact keyword match in name > keyword in description > partial match

6. **Present recommendations with multi-select**:

   If no skills were found after deduplication and filtering:
   ```
   🔍 No matching skills found for your project's tech stack.

   💡 Suggestions:
   - Use `/find-skill [query]` to search with different keywords
   - Browse skill marketplaces directly: skillsmp.com, skillhub.club
   ```
   Skip steps 7-9 (no installation needed).

   Otherwise:

   Limit to top 10 most relevant skills. If more results exist, note: "Showing top 10 of {total} results."

   Note: `AskUserQuestion` supports a maximum of 4 options. If more than 3 skills are found, first present the full numbered list as text output, then use `AskUserQuestion` with the top 3 most relevant skills as options. Users can select "Other" to specify additional skills by number from the list above.

   Use `AskUserQuestion` with `multiSelect: true`:

   ```
   Question: "Found {N} skills for your project. Which ones do you want to install?"
   ```

   Options (each skill as a selectable option):
   - Label: `{skill-name} — {short description}`
   - Description: `Source: {source} | Related to: {technology}`
   - Mark the top-relevance skills as "(Recommended)" in the label

   The user can select/deselect individual skills. They can also choose "Other" to specify additional needs.

7. **Batch install all selected skills**: For each selected skill:

   a. **Download content first**: For each selected skill, download the SKILL.md content (WebFetch from raw GitHub URL / SkillsMP / other source) but do NOT write to disk yet.

   b. **Show batch summary for final confirmation**: After downloading all selected skills, present a summary:
      ```
      📋 Ready to install {N} skills:

      1. **{skill-name}** — {description}
         Commands: /{command-1}, /{command-2}
         Source: {url}

      2. **{skill-name}** — {description}
         Commands: /{command-1}
         Source: {url}
      ```
      Use `AskUserQuestion` to confirm:
      - Question: "Confirm installing these {N} skills?"
      - Options: "Yes, install all", "Let me review each one", "Cancel"
      - If "Cancel": abort and display "Installation cancelled."
      - If "Let me review each one": show each skill's full content summary individually, with per-skill "Install" / "Skip" options.

   c. **Write files**: For confirmed skills, create `.claude/skills/{skill-name}/` directory and write the SKILL.md using `Write` tool.

   d. After writing each skill file, check its content for MCP server references. If found, run `claude mcp add {name} -- {command}` via `Bash`.

   e. Track result: ✅ success or ❌ failure (with reason).

   f. If one skill fails, continue installing the rest — don't stop the batch.

8. **Show final summary**:

   ```
   ✅ Project skill setup complete!

   📋 Results:
   ✅ {skill-1} — installed to .claude/skills/{skill-1}/
   ✅ {skill-2} — installed to .claude/skills/{skill-2}/
   ❌ {skill-3} — failed: {reason}
   ⏭️ {skill-4} — skipped (already installed)

   📦 Total: {installed} installed, {skipped} skipped, {failed} failed

   💡 Quick tips:
   - Use `/list-skills` to see all your skills
   - Use `/find-skill [query]` to search for more
   - Use `/uninstall-skill [name]` to remove one
   ```

9. **Report unavailable sources** (if any):
   ```
   ⚠️ Some skill sources were unavailable:
   - {source}: {reason}
   Try again later or search manually with `/find-skill [query]`
   ```
