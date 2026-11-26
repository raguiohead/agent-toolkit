# Design Técnico: Repositório Pessoal `agent-toolkit`

- **Data:** 2026-09-21
- **Status:** Aprovado (Brainstorming Concluído)
- **Repositório GitHub:** `raguiohead/agent-toolkit`

---

## 1. Visão Geral e Objetivos

O **`agent-toolkit`** é um monorepo pessoal, privado e agnóstico de ferramentas para agentes de IA (Claude Code, Antigravity/Gemini e compatíveis), consolidando:
1. **Skills Modulares:** Coleção curada de skills de alta engenharia de software, TDD, Clean Architecture, Segundo Cérebro (Cognito/Obsidian) e condução de tarefas.
2. **Subagentes Nativos (VoltAgent Curation):** Subagentes selecionados do ecossistema VoltAgent alinhados rigorosamente à stack Java/Spring Boot, Vue 3/TypeScript, Docker e Engenharia de IA.
3. **Model Context Protocol (MCP) Hub:** Configurações sanitizadas e prontas para uso dos melhores servidores MCP abertos (Context7, Sequential Thinking, GitHub, Postgres, Docker, Git, Playwright, Exa, Chrome DevTools, Obsidian).
4. **Automação Idempotente via PowerShell (`setup.ps1`):** Instalação automática via *junctions* NTFS para `~/.claude/skills`, `~/.claude/agents` e `~/.gemini/config/skills`.
5. **Auditoria e Saúde (`verify.ps1`):** Verificação de integridade dos links, validação de sintaxe de frontmatter YAML e scanner de prevenção contra vazamento de segredos.

### Política de Não-Vazamento e Isolamento
Conforme diretriz estrita, **nenhuma ferramenta, skill, plugin ou credencial proprietária de qualquer organização** fará parte deste repositório. O `agent-toolkit` é 100% agnóstico e voltado ao desenvolvimento de software de alta performance e uso pessoal/open source.

---

## 2. Arquitetura do Diretório

```
agent-toolkit/
├── .github/
│   └── workflows/              # Linting e validação contínua (opcional)
├── skills/                     # Skills modulares em formato SKILL.md
│   ├── engineering/            # Clean code, testes e segurança
│   ├── architecture/           # Arquitetura de software e modelagem
│   ├── workflow/               # Condução de tarefas, brainstorming e specs
│   ├── knowledge/              # Segundo Cérebro, Cognito e Obsidian
│   ├── specialized/            # Frontend, QA e autenticação
│   └── meta/                   # Criação, busca e governança de skills
├── agents/                     # Subagentes para Claude Code (.md) curados da VoltAgent
│   ├── languages/              # Spring Boot, Java, Vue 3, TypeScript, SQL, Python, PowerShell
│   ├── architecture/           # API Designer, MCP Developer, Docker Expert, Git Workflow
│   ├── debugging/              # Debugger, Error Detective, Performance, Security Auditor, Test Automator
│   └── reasoning-ai/           # Prompt Engineer, LLM Architect, Context Manager, First Principles
├── mcps/                       # Catálogo e templates de servidores MCP
│   ├── configs/
│   │   ├── claude_desktop_config.example.json
│   │   └── antigravity_mcp.example.json
│   └── schemas/                # Schemas JSON das ferramentas MCP
├── scripts/
│   ├── setup.ps1               # Criação de junctions e links locais
│   └── verify.ps1              # Auditoria de integridade, linter e scanner de segredos
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-09-21-agent-toolkit-design.md
├── .gitignore                  # Blindagem de credenciais, logs e caches
└── README.md                   # Documentação, catálogo escaneável e quickstart
```

---

## 3. Catálogo de Conteúdo

### 3.1. Skills Agnósticas Selecionadas
- **`skills/engineering/`:** `code-reviewer`, `code-review`, `tdd`, `unit-tests`, `security-review`, `vibe-code-security`, `setup-pre-commit`, `setup-ts-deep-modules`, `migrate-to-shoehorn`, `resolving-merge-conflicts`.
- **`skills/architecture/`:** `codebase-design`, `domain-modeling`, `design-an-interface`, `request-refactor-plan`, `improve-codebase-architecture`, `ubiquitous-language`.
- **`skills/workflow/`:** `brainstorming`, `project-blueprint`, `grilling`, `grill-me`, `batch-grill-me`, `grill-with-docs`, `start-task`, `next-task`, `progress`, `standup`, `triage`, `verify`, `handoff`, `claude-handoff`.
- **`skills/knowledge/`:** `cognito-agent`, `obsidian-vault`, `book-to-skill`, `research`, `graphify`, `teach`.
- **`skills/specialized/`:** `frontend-design`, `prototype`, `qa`, `keycloak`, `keycloak-auth`, `sonarqube`.
- **`skills/meta/`:** `skill-creator`, `skill-search`, `find-skill`, `init-skills`, `install-skill`, `list-skills`, `update-skills`, `uninstall-skill`, `find-mcp`, `writing-great-skills`.

### 3.2. Subagentes VoltAgent Curados (`agents/`)
1. **Linguagens & Frameworks:**
   - `spring-boot-engineer.md` (Spring Boot 3, Microservices, GraalVM, Clean Arch)
   - `java-architect.md` (Padrões corporativos Java, JVM tuning)
   - `vue-expert.md` (Vue 3 Composition API, Quasar, Pinia)
   - `typescript-pro.md` (Tipagem estrita, generics, TS moderno)
   - `sql-pro.md` (Queries complexas, índices, normalização)
   - `python-pro.md` (Scripts rápidos, automações, APIs FastAPI)
   - `powershell-7-expert.md` (Automação avançada Windows/Linux)
2. **Arquitetura & Core Dev:**
   - `api-designer.md` (Contratos OpenAPI/Swagger, REST patterns)
   - `mcp-developer.md` (Desenvolvimento de servidores Model Context Protocol)
   - `docker-expert.md` (Dockerfiles multi-stage, compose, otimização de imagens)
   - `git-workflow-manager.md` (Estratégias de branching, conventional commits)
3. **Qualidade & Resolução de Bugs:**
   - `debugger.md` (Depuração metódica passo a passo)
   - `error-detective.md` (Análise de stacktraces e causas-raiz)
   - `performance-engineer.md` (Profiling, latência, concorrência)
   - `security-auditor.md` (OWASP Top 10, sanitização, RBAC)
   - `test-automator.md` (Estratégias completas de teste e pirâmide de testes)
4. **IA, Contexto & Raciocínio:**
   - `prompt-engineer.md` (Estruturação de prompts e few-shot learning)
   - `llm-architect.md` (Pipelines RAG, agentes, harness engineering)
   - `context-manager.md` (Mitigação de Context Rot e curadoria de janelas)
   - `first-principles-thinking.md` (Decomposição lógica a partir de verdades fundamentais)

### 3.3. Servidores MCP Configurados
1. **Raciocínio & Documentação Dinâmica:**
   - `sequential-thinking` (`@modelcontextprotocol/server-sequential-thinking`): Decomposição cognitiva em passos encadeados.
   - `context7` (`npx ctx7` / Upstash): Documentação oficial e atualizada de frameworks injetada sob demanda.
   - `memory`: Grafo de conhecimento de entidades persistente.
2. **Engenharia Local:**
   - `filesystem`: Operações avançadas no disco.
   - `git` (`@modelcontextprotocol/server-git`): Diffs, histórico e branches locais.
   - `github`: Gestão de repositórios, PRs e issues via PAT.
   - `postgres` (`@modelcontextprotocol/server-postgres`): Conexão e inspeção de bancos de dados locais.
   - `docker` (`docker-mcp`): Monitoramento e ciclo de vida de containers.
3. **Web, Automação & Testes:**
   - `playwright`: Navegação headless, screenshots e automação web.
   - `chrome_devtools`: Depuração de interfaces ao vivo.
   - `exa`: Pesquisa web profunda e leitura de páginas.
4. **Conhecimento & Qualidade:**
   - `obsidian`: Conexão com vault Markdown (Cognito).
   - `sonarqube`: Análise estática de código local.

---

## 4. Especificação dos Scripts de Automação

### 4.1. `scripts/setup.ps1`
- **Parâmetros Suportados:**
  - `-DryRun` (Switch): Apenas exibe o que seria feito sem criar junctions.
  - `-Target` (String, Default: 'All'): Opções `'All'`, `'Claude'`, `'Antigravity'`.
- **Lógica de Execução:**
  1. Identifica `$RepoRoot = Resolve-Path "$PSScriptRoot\.."`.
  2. Define destinos:
     - Claude Skills: `~/.claude/skills`
     - Claude Agents: `~/.claude/agents`
     - Antigravity Skills: `~/.gemini/config/skills`
  3. Cria diretórios de destino se não existirem.
  4. Varre recursivamente `$RepoRoot\skills\*` procurando pastas contendo `SKILL.md`.
  5. Cria uma Junction NTFS (`New-Item -ItemType Junction -Target $skillDir -Path $destPath`) para cada skill encontrada.
  6. Varre `$RepoRoot\agents\*\*.md` e cria Hardlink/Junction para `~/.claude/agents\`.
  7. Registra log colorido:
     - `[OK]`: Junction criada ou já existente e válida.
     - `[BACKUP]`: Pasta física pré-existente renomeada para `.bak` antes do link.
     - `[SKIP]`: Item ignorado por flag ou regra.

### 4.2. `scripts/verify.ps1`
- **Lógica de Execução:**
  1. **Auditoria de Junctions:** Testa cada link em `~/.claude/skills` e `~/.gemini/config/skills` para assegurar que o alvo existe (`Test-Path`).
  2. **Validador de Frontmatter YAML:** Checa se cada `SKILL.md` e cada `agents/*.md` possui bloco inicial `---` com `name` e `description`.
  3. **Security Scanner:** Busca recursiva no repositório por padrões sensíveis:
     - `(ghp_|github_pat_|sk-ant-|Bearer |password\s*=|secret\s*=)`
     - Falha imediatamente se encontrar padrões de credenciais ativas em arquivos rastreados.
  4. Retorna Exit Code 0 em caso de sucesso ou 1 em falha com lista dos erros encontrados.

---

## 5. Blindagem e Segurança (.gitignore)

```gitignore
# Segredos e variáveis de ambiente
.env
.env.*
*.token
*.key
*.pem
*credentials*.json

# Caches e executáveis de agentes
.claude/sessions/
.claude/backups/
.gemini/tmp/
.cache/

# Dependências e Runtimes
node_modules/
__pycache__/
*.pyc
venv/
.venv/

# Sistema operacional
Thumbs.db
.DS_Store
*.bak
```

---

## 6. Governança Git e Setup Remoto

1. **Repositório Local:** `<seu-caminho>/agent-toolkit` inicializado com branch padrão `main`.
2. **Remote Oficial:** `git@github.com:raguiohead/agent-toolkit.git`.
3. **Padrão de Commits:** Conventional Commits em Português do Brasil (`feat: ...`, `fix: ...`, `docs: ...`), atômicos.
4. **Passos de Implementação (Writing-Plans):**
   - Fase 1: Inicialização da estrutura de pastas, `.gitignore` e `README.md`.
   - Fase 2: Migração e cópia seletiva das skills agnósticas locais de `~/.gemini/config/skills`.
   - Fase 3: Download e curadoria dos 20 subagentes da VoltAgent em `agents/`.
   - Fase 4: Criação dos schemas e templates de configuração MCP em `mcps/configs/`.
   - Fase 5: Implementação dos scripts `setup.ps1` e `verify.ps1`.
   - Fase 6: Execução de testes de verificação e criação do repositório remoto no GitHub (`raguiohead/agent-toolkit`).
