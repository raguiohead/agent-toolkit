---
name: recommend
description: "Describe your project or let me auto-detect your tech stack, then I'll recommend the best skills from all marketplaces. Works with natural language."
disable-model-invocation: true
argument-hint: "[optional: describe your project, e.g. 'React app with testing']"
---

# /recommend — Smart Skill Recommendations

Describe your project in plain language, or let it auto-detect. Get personalized skill recommendations.

## Steps

1. **Understand the project**:

   ### Option A: User provided a description
   If the user gave an argument (e.g., `/recommend React app with testing`), extract technology keywords from the natural language:
   - "React app with testing" → `react`, `testing`, `frontend`
   - "Python API with database" → `python`, `api`, `database`
   - "TypeScript monorepo" → `typescript`, `monorepo`

   ### Option B: Auto-detect from config files
   If no argument, use `Glob` to scan for project config files and `Read` to extract tech stack:
   | File | Technologies |
   |------|-------------|
   | `package.json` | Read `dependencies` + `devDependencies` → React, Vue, Express, Next.js, TypeScript, etc. |
   | `tsconfig.json` | TypeScript |
   | `Cargo.toml` | Rust |
   | `go.mod` | Go |
   | `requirements.txt` / `pyproject.toml` | Python, Django, Flask, FastAPI |
   | `Gemfile` | Ruby, Rails |
   | `Dockerfile` | Docker |

   ### Option C: Ask the user
   If no argument AND no config files found, use `AskUserQuestion`:
   - "What technologies does your project use?"
   - Options: "JavaScript/TypeScript", "Python", "Rust", "Go", "Other (I'll describe)"

   Combine all sources for the fullest keyword list.

2. **Scan installed skills**: Use `Glob` to find all `SKILL.md` files under `.claude/skills/`. Read each one to get skill names.

3. **Search marketplaces** for each technology keyword:
   - **SkillsMP**: `WebSearch` → `"{keyword} claude skill site:skillsmp.com"`
   - **GitHub**: Use `Bash` → `gh api search/repositories -X GET -f q="claude skill {keyword}"` to search. If `gh` is not available, fall back to `WebSearch` → `"{keyword} claude code skill site:github.com"`
   - **SkillHub**: `WebSearch` → `"{keyword} claude skill site:skillhub.club"`
   - **Anthropic Official**: `WebSearch` → `"anthropic official claude skill {keyword} site:github.com"` or use `Bash` → `gh api search/repositories -X GET -f q="claude skill {keyword} org:anthropics"`

   Skip failed sources, continue with the rest.

4. **Filter and deduplicate**:
   - Remove duplicates (same skill from multiple sources)
   - Remove already-installed skills (match by name)
   - Sort by relevance to the detected tech stack
   - Limit to top 10 most relevant results. If more exist, note: "Showing top 10 of {total} recommendations."

5. **Present recommendations**:

   If no recommendations were found after filtering (all results were duplicates or already installed):

   ```
   📊 Project Analysis:
   - Tech stack: {tech1}, {tech2}, {tech3}
   - Installed skills: {N}

   💡 No new skills found for your tech stack. You may already have good coverage!
   - Use `/find-skill [query]` to search for specific capabilities
   - Browse skill marketplaces directly: skillsmp.com, skillhub.club
   ```

   Skip step 6 (no installation to offer).

   Otherwise, present in this format:

   ```
   📊 Project Analysis:
   - Tech stack: {tech1}, {tech2}, {tech3}
   - Installed skills: {N}

   💡 Recommended Skills ({M} found):

   1. **{skill-name}** — {description}
      📦 Source: {source} | 🔗 Related to: {technology}
      ⚡ Install: `/install-skill {url}`

   2. ...

   ```

6. **Offer installation**: Use `AskUserQuestion` with `multiSelect: true` to let the user select which skills to install:

   Note: `AskUserQuestion` supports a maximum of 4 options. If more than 3 recommendations, first present the full list in the Step 5 output, then offer the top 3 as quick-select options here. Users can select "Other" to specify additional choices by number.

   - Question: "Would you like to install any of these skills?"
   - Options: each recommended skill as a selectable option
     - Label: `{skill-name} — {short description}`
     - Description: `Source: {source} | Related to: {technology}`
   - If user selects skills, execute installation using `/install-skill` logic (download SKILL.md → write to `.claude/skills/` → check for MCP requirements).
   - If user selects none, display "No skills installed. Use `/find-skill [query]` to search for more."
