---
name: find-mcp
description: "Search for and install MCP servers from mcp.so and mcpservers.org. Use when the user needs to connect Claude Code to an external service or tool."
disable-model-invocation: true
argument-hint: "[service or capability you need]"
---

# /find-mcp — Search & Install MCP Servers

Search for MCP servers that provide the capability the user needs.

## Steps

1. **Parse the search query** from the argument. If no argument, ask the user what service or capability they need.

2. **Search MCP directories**:
   - Use `WebSearch` for: `"mcp server {query} site:mcp.so"`
   - Use `WebSearch` for: `"mcp server {query} site:mcpservers.org"`
   - Use `WebSearch` for: `"claude mcp {query} server npm OR npx"`

3. **Compile results**: For each MCP server found, extract:
   - Name
   - Description
   - NPM package or command
   - Configuration needed (API keys, etc.)

4. **Present options**:
   ```
   Found {N} MCP servers for "{query}":

   1. **{server-name}** — {description}
      Source: {url}
      Install: `claude mcp add {name} -- npx -y {package}`
      Config: {any API keys or setup needed}

   2. **{server-name}** — {description}
      Source: {url}
      Install: `claude mcp add {name} -- {command}`
      Config: {setup notes}

   Would you like to install any of these?
   ```

5. **Install if requested**: Run the `claude mcp add` command the user chooses. If API keys are needed, ask the user for them first.
