# 🔌 Guia de Servidores MCP (Model Context Protocol)

Este diretório contém as configurações e esquemas dos servidores MCP selecionados para o seu ecossistema.

---

## 📋 Catálogo dos Servidores MCP

| Servidor | Pacote / Comando | Finalidade | Variáveis Necessárias |
|---|---|---|---|
| **Sequential Thinking** | `@modelcontextprotocol/server-sequential-thinking` | Raciocínio estruturado passo a passo | Nenhuma |
| **Context7** | `ctx7 mcp` (Upstash) | Injeção de docs oficiais em tempo real (Spring Boot, Vue, etc.) | `CONTEXT7_API_KEY` (Opcional, grátis em [context7.com](https://context7.com)) |
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Manipulação de arquivos em diretórios autorizados | Caminhos permitidos (ex: `C:\Users\voce\projetos`, `C:\Users\voce\vault`) |
| **Git** | `@modelcontextprotocol/server-git` | Diffs, logs e histórico de repositórios locais | Nenhuma |
| **GitHub** | `@modelcontextprotocol/server-github` | Operações no GitHub (Issues, PRs, repos) | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **PostgreSQL** | `@modelcontextprotocol/server-postgres` | Consultas e inspeção de schema de banco de dados | Connection string local |
| **Docker** | `docker-mcp` | Monitoramento e inspeção de containers locais | Docker Desktop / Daemon ativo |
| **Playwright** | `@modelcontextprotocol/server-playwright` | Automação e screenshots de navegadores | Nenhuma (requer Node 18+) |
| **Chrome DevTools** | `@modelcontextprotocol/server-chrome-devtools` | Depuração de páginas web via CDP | Nenhuma |
| **Exa Search** | `exa-mcp-server` | Pesquisa web profunda e leitura em tempo real | `EXA_API_KEY` ([exa.ai](https://exa.ai)) |
| **Obsidian** | `mcp-obsidian` | Leitura e enriquecimento do Segundo Cérebro (Cognito) | `OBSIDIAN_VAULT_PATH` |

---

## 🚀 Como Ativar

1. Copie o template desejado:
   - Para Claude Desktop / Claude Code: [`mcps/configs/claude_desktop_config.example.json`](configs/claude_desktop_config.example.json) para o seu arquivo de configuração local (`%APPDATA%\Claude\claude_desktop_config.json`).
   - Para Antigravity: [`mcps/configs/antigravity_mcp.example.json`](configs/antigravity_mcp.example.json).
2. Substitua os placeholders (`${GITHUB_TOKEN}`, `${EXA_API_KEY}`, etc.) pelas suas variáveis de ambiente ou tokens pessoais.
3. Reinicie o aplicativo do agente.
