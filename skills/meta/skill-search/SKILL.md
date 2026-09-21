---
name: skill-search
description: "Auto-discover, search, recommend, install, and manage skills from multiple marketplaces (SkillsMP, GitHub, SkillHub, Anthropic Official, MCP servers). Use when the user asks to search for skills, find a skill for a specific stack, install a skill, or manage installed skills."
---

# skill-search — Multi-Market Skill Discovery & Management

Unified toolkit to search across skill marketplaces, get smart recommendations based on the project's tech stack, install skills safely, and manage installed skills.

## Sources Covered
- **SkillsMP** (`skillsmp.com`) — 96,000+ community skills
- **GitHub** (`github.com`) — Open-source repositories with `SKILL.md` or `.claude/skills` / `.agents/skills`
- **SkillHub** (`skillhub.club`) — Claude/Agent Skills marketplace
- **Anthropic Official** (`github.com/anthropics/skills`) — Official skill definitions
- **MCP Directories** (`mcp.so`, `mcpservers.org`) — MCP tool integrations

---

## Workflows & Capabilities

### 1. Search Skills (`find-skill` / search query)
When searching for a skill:
1. Search across marketplaces using web searches and GitHub search (`gh api search/repositories` or search queries `"{query} claude skill site:skillsmp.com"`, `"{query} skill site:github.com"`).
2. Deduplicate results and extract:
   - **Name**
   - **Description**
   - **Source** (SkillsMP / GitHub / SkillHub / Anthropic Official)
   - **Install reference** (Repo URL / SKILL.md URL)
3. Rank results by relevance: exact match in title > keyword in title > match in description.
4. Present top 5-10 results clearly with install instructions.
5. Offer to install the selected skill.

### 2. Smart Recommendations (`recommend` / `init-skills`)
When analyzing a project to suggest skills:
1. Detect the tech stack (inspect `package.json`, `tsconfig.json`, `pom.xml`, `build.gradle`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Dockerfile`, etc.) or parse the user's description.
2. Check existing installed skills in `.agents/skills/` or `~/.gemini/config/skills/` to avoid duplicates.
3. Search marketplaces for relevant skills matching the detected technologies.
4. Present curated recommendations and offer single or batch installation.

### 3. Install Skill (`install-skill` / direct install)
When installing a skill from URL or name:
1. Download/fetch the `SKILL.md` content (via raw GitHub URL, repository fetch, or direct link).
2. Validate content and security: verify frontmatter (`name`, `description`), check commands and safety.
3. Check for existing version in `.agents/skills/{skill-name}/SKILL.md` or `~/.agents/skills/{skill-name}/SKILL.md`.
4. Ask confirmation before overwriting if already exists.
5. Write the skill to `.agents/skills/{skill-name}/SKILL.md` (or workspace `.agents/skills/` if project-specific).
6. Check for any required MCP servers or dependencies.

### 4. Manage Skills (`list-skills`, `update-skills`, `uninstall-skill`)
- **List**: Scan `.agents/skills/` and `~/.gemini/config/skills/` to show installed skills and their descriptions.
- **Update**: Check remote sources of installed skills for updates/changes and prompt to update with backup.
- **Uninstall**: Remove `.agents/skills/{skill-name}` upon confirmation.
