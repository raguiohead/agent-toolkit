# Plano de Implementação: Repositório `agent-toolkit`

- **Data:** 2026-09-21
- **Autor:** Guilherme Alves (@raguiohead)
- **Status:** Pronto para Execução
- **Especificação:** [`docs/superpowers/specs/2026-09-21-agent-toolkit-design.md`](file:///D:/code/agent-toolkit/docs/superpowers/specs/2026-09-21-agent-toolkit-design.md)
- **Localização:** [`D:\code\agent-toolkit`](file:///D:/code/agent-toolkit)

---

## 📋 Resumo das Fases de Execução

| Fase | Descrição | Arquivos / Pastas Impactadas | Critério de Aceite |
|---|---|---|---|
| **Fase 1** | Scaffolding da estrutura de pastas, `.gitignore` e `README.md` mestre | `.gitignore`, `README.md`, árvore de pastas | Estrutura limpa e versionada sem segredos |
| **Fase 2** | Migração e categorização das skills agnósticas locais | `skills/*/*` | ~60 skills migradas, 0 skills corporativas Unimed |
| **Fase 3** | Ingestão e curadoria dos 20 subagentes VoltAgent | `agents/*/*.md` | 20 arquivos `.md` baixados com YAML frontmatter válido |
| **Fase 4** | Templates de configuração e schemas dos 10 MCPs | `mcps/configs/*.json`, `mcps/schemas/` | Configurações completas e 100% sanitizadas (sem tokens) |
| **Fase 5** | Implementação dos scripts `setup.ps1` e `verify.ps1` | `scripts/setup.ps1`, `scripts/verify.ps1` | Idempotência validada, linter e security scanner aprovados |
| **Fase 6** | Homologação local (`-DryRun`) e configuração remota do Git | Git remote `origin` e checklist final | Repositório pronto para push em `raguiohead/agent-toolkit` |

---

## Detalhamento das Tarefas

### Fase 1: Scaffolding e Governança Base
- [ ] Criar pastas temáticas:
  - `skills/engineering`, `skills/architecture`, `skills/workflow`, `skills/knowledge`, `skills/specialized`, `skills/meta`
  - `agents/languages`, `agents/architecture`, `agents/debugging`, `agents/reasoning-ai`
  - `mcps/configs`, `mcps/schemas`, `mcps/servers`
  - `scripts`, `docs/superpowers/plans`
- [ ] Criar `.gitignore` blindado com regras para arquivos sensíveis, caches de agentes e artefatos de build.
- [ ] Criar `README.md` com arquitetura visual, catálogo completo, tabela de subagentes e comandos do setup.
- [ ] Commit atômico: `feat: estruturar scaffold inicial, gitignore e documentacao mestre`.

### Fase 2: Migração e Filtro de Skills Agnósticas
- [ ] Mapear todas as skills existentes em `~/.gemini/config/skills`.
- [ ] Copiar apenas as skills genéricas e de uso pessoal para as categorias:
  - `engineering/`: `code-review`, `code-reviewer`, `tdd`, `unit-tests`, `security-review`, `vibe-code-security`, `setup-pre-commit`, `setup-ts-deep-modules`, `migrate-to-shoehorn`, `resolving-merge-conflicts`.
  - `architecture/`: `codebase-design`, `domain-modeling`, `design-an-interface`, `request-refactor-plan`, `improve-codebase-architecture`, `ubiquitous-language`.
  - `workflow/`: `brainstorming`, `project-blueprint`, `grilling`, `grill-me`, `batch-grill-me`, `grill-with-docs`, `start-task`, `next-task`, `progress`, `standup`, `triage`, `verify`, `handoff`, `claude-handoff`.
  - `knowledge/`: `cognito-agent`, `obsidian-vault`, `book-to-skill`, `research`, `graphify`, `teach`.
  - `specialized/`: `frontend-design`, `prototype`, `qa`, `keycloak`, `keycloak-auth`, `sonarqube`.
  - `meta/`: `skill-creator`, `skill-search`, `find-skill`, `init-skills`, `install-skill`, `list-skills`, `update-skills`, `uninstall-skill`, `find-mcp`, `writing-great-skills`.
- [ ] Auditar exclusão de skills Unimed (`central-notificacoes`, `g4-flex`, `unipix-sms`, `lambda`, `unimed-dev-standards`, `jira-tickets`, `logs-search`, `metrics-search`, `vera`).
- [ ] Commit atômico: `feat(skills): catalogar e organizar acervo de skills agnosticas por categoria`.

### Fase 3: Ingestão dos Subagentes VoltAgent
- [ ] Baixar os 20 subagentes oficiais via GitHub API / raw content:
  - `languages/`: `spring-boot-engineer.md`, `java-architect.md`, `vue-expert.md`, `typescript-pro.md`, `sql-pro.md`, `python-pro.md`, `powershell-7-expert.md`.
  - `architecture/`: `api-designer.md`, `mcp-developer.md`, `docker-expert.md`, `git-workflow-manager.md`.
  - `debugging/`: `debugger.md`, `error-detective.md`, `performance-engineer.md`, `security-auditor.md`, `test-automator.md`.
  - `reasoning-ai/`: `prompt-engineer.md`, `llm-architect.md`, `context-manager.md`, `first-principles-thinking.md`.
- [ ] Validar cabeçalho YAML de cada subagente.
- [ ] Commit atômico: `feat(agents): adicionar subagentes curados para spring boot, vue, docker e debugging`.

### Fase 4: Templates MCP e Schemas
- [ ] Criar `mcps/configs/claude_desktop_config.example.json` contemplando os 10 servidores selecionados (`sequential-thinking`, `context7`, `filesystem`, `git`, `github`, `postgres`, `docker`, `playwright`, `chrome_devtools`, `exa`, `obsidian`, `sonarqube`).
- [ ] Criar `mcps/configs/antigravity_mcp.example.json`.
- [ ] Criar `mcps/README.md` com instruções de como obter e configurar chaves (GitHub PAT, Context7, Exa).
- [ ] Commit atômico: `feat(mcps): fornecer templates sanitizados e documentacao de configuracao mcp`.

### Fase 5: Scripts de Automação PowerShell
- [ ] Desenvolver `scripts/setup.ps1`:
  - Flags: `-Target` (`All`, `Claude`, `Antigravity`), `-DryRun`.
  - Descoberta dinâmica de caminhos (`~/.claude/skills`, `~/.claude/agents`, `~/.gemini/config/skills`).
  - Criação de Junctions NTFS individuais para cada skill e subagente.
  - Salvaguarda de arquivos pré-existentes (criação de `.bak`).
  - Relatório visual formatado no console.
- [ ] Desenvolver `scripts/verify.ps1`:
  - Verificação de integridade dos links (sem links quebrados).
  - Linter de frontmatter de todas as skills e subagentes.
  - Scanner de segurança procurando tokens ou segredos hardcoded.
- [ ] Testar execução dos scripts localmente.
- [ ] Commit atômico: `feat(scripts): implementar automacao de junctions e validacao de saude`.

### Fase 6: Validação Final e Preparação Remota
- [ ] Rodar `scripts/verify.ps1` e certificar saída 100% verde (Exit Code 0).
- [ ] Configurar remote Git oficial: `git remote add origin git@github.com:raguiohead/agent-toolkit.git`.
- [ ] Exibir guia rápido para o Guilherme criar o repositório privado no GitHub e realizar o primeiro `git push -u origin main`.
