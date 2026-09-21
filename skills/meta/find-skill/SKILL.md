---
name: find-skill
description: "Search for community skills across multiple marketplaces (SkillsMP, GitHub, SkillHub, Anthropic Official). Returns aggregated results with graceful fallback when sources are unavailable."
disable-model-invocation: true
argument-hint: "[search keyword]"
---

# /find-skill — Multi-Market Unified Skill Search

Search for community skills across **all** major skill marketplaces in one command.

## Sources

| # | Marketplace | Method |
|---|-------------|--------|
| 1 | SkillsMP (skillsmp.com) | MCP (if available) → WebSearch `site:skillsmp.com` |
| 2 | GitHub | `gh api search/repositories` → WebSearch fallback |
| 3 | SkillHub (skillhub.club) | WebSearch `site:skillhub.club` |
| 4 | Anthropic Official | WebSearch `site:github.com/anthropics` |

## Steps

1. **Parse the search query** from the argument. If no argument, use `AskUserQuestion` to ask the user what capability they're looking for.

2. **Search each marketplace independently**. For each source, attempt the search and record results. If a source fails or returns no results, record it as unavailable and continue to the next source. Never let one source's failure stop the entire search.

   ### Source 1: SkillsMP
   - Check if the `skillsmp` MCP server is configured. If available, use it to search.
   - Fallback: If MCP is not available or returns no results, use `WebSearch` for: `"{query} claude skill site:skillsmp.com"`
   - If both methods fail or are unavailable, mark SkillsMP as unavailable.

   ### Source 2: GitHub
   - Primary: Use `gh api search/repositories -X GET -f q="claude skill {query}"` via Bash to get structured results.
   - Parse the JSON response to extract repo names (`.items[].full_name`), descriptions (`.items[].description`), and URLs (`.items[].html_url`).
   - Fallback: If `gh` is not available or fails, use `WebSearch` for: `"{query} claude code skill site:github.com"`
   - Extract skill repositories that contain SKILL.md or claude skill definitions.

   ### Source 3: SkillHub
   - Use `WebSearch` for: `"{query} claude skill site:skillhub.club"`
   - If no results, mark SkillHub as unavailable.

   ### Source 4: Anthropic Official
   - Use `WebSearch` for: `"anthropic official claude skill {query} site:github.com"`
   - Or use `gh api search/repositories -X GET -f q="claude skill org:anthropics"` via Bash for structured results.
   - If no results from either method, mark Anthropic Official as unavailable.

3. **Compile and deduplicate results**. For each skill found, extract these 4 required fields:
   - **name**: Skill name
   - **description**: What the skill does
   - **source**: Which marketplace it came from (SkillsMP / GitHub / SkillHub / Anthropic Official)
   - **install_command**: How to install it (e.g., `/install-skill <url>` or `git clone`)

4. **Sort results by relevance**:
   - **Tier 1**: Name exactly matches the query keyword → top
   - **Tier 2**: Name contains the query keyword → next
   - **Tier 3**: Description matches the query keyword → next
   - **Tier 4**: Partial/fuzzy match → last
   - Limit displayed results to the **top 10** most relevant. If more results exist, note: "Showing top 10 of {total} results. Use more specific keywords to narrow down."

5. **Present results**:

   If no results were found from any source:
   ```
   🔍 No skills found for "{query}".

   💡 Suggestions:
   - Try different keywords (e.g., more general or more specific)
   - Browse skill marketplaces directly: skillsmp.com, skillhub.club
   - Check if the skill exists under a different name
   ```
   Skip steps 6 and 7 (no installation to offer).

   Otherwise, present in this format:

   ```
   🔍 Found {N} skills for "{query}" from {M} sources:

   1. **{skill-name}** — {description}
      📦 Source: {source}
      ⚡ Install: `{install_command}`

   2. **{skill-name}** — {description}
      📦 Source: {source}
      ⚡ Install: `{install_command}`

   ...
   ```

6. **Report unavailable sources** (if any) at the end:

   ```
   ⚠️ The following sources were unavailable during this search:
   - {source_name}: {reason}
   ```

7. **Offer installation**: Present the results list from Step 5 as context, then use `AskUserQuestion` to ask: "Would you like to install any of these skills?"

   Note: `AskUserQuestion` supports a maximum of 4 options. If more than 3 results, first present the full numbered list in Step 5, then offer the top 3 most relevant skills as options here. Users can select "Other" to specify a different skill by number from the list above.

   Options: `Install {skill-1}`, `Install {skill-2}`, `Install {skill-3}`, `Other (specify by number)`. If user selects a skill, invoke `/install-skill` with that skill's URL.
