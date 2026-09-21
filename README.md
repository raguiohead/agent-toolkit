# 🤖 Agent Toolkit — Arsenal Pessoal de IA & Engenharia

[![Status](https://img.shields.io/badge/status-active-brightgreen.svg)]()
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue.svg)]()
[![License](https://img.shields.io/badge/license-Private-red.svg)]()

Repositório pessoal, privado e agnóstico consolidando **skills modulares**, **subagentes especializados**, **templates MCP** e **scripts de automação** para **Claude Code**, **Antigravity**, **OpenAI Codex** e assistentes de IA de alto desempenho.

---

## 🧭 Visão Geral da Arquitetura

```
agent-toolkit/
├── skills/                     # Skills modulares em formato SKILL.md
│   ├── engineering/            # Clean Code, TDD, Testes Unitários e Segurança
│   ├── architecture/           # Design de Sistemas, Modelagem de Domínio e RFCs
│   ├── workflow/               # Condução de tarefas, Brainstorming e Handoff
│   ├── knowledge/              # Segundo Cérebro (Cognito, Obsidian, Book to Skill)
│   ├── specialized/            # Frontend Design, QA, Keycloak e SonarQube
│   └── meta/                   # Criação, busca e governança de skills
├── agents/                     # Subagentes curados da VoltAgent para Claude Code (.md)
│   ├── languages/              # Spring Boot, Java, Vue 3, TypeScript, SQL, Python, PowerShell
│   ├── architecture/           # API Designer, MCP Developer, Docker Expert, Git Workflow
│   ├── debugging/              # Debugger, Error Detective, Performance, Security Auditor
│   └── reasoning-ai/           # Prompt Engineer, LLM Architect, Context Manager, First Principles
├── mcps/                       # Camada de Model Context Protocol
│   ├── configs/                # Templates sanitizados para Claude Desktop e Antigravity
│   └── schemas/                # Schemas e documentações de ferramentas MCP
├── scripts/
│   ├── setup.ps1               # Automação de junctions NTFS nos agentes locais
│   └── verify.ps1              # Linter de frontmatter, saúde de links e scanner de segredos
├── docs/                       # Especificações e planos de implementação
│   └── superpowers/
│       ├── specs/              # Design técnico aprovado
│       └── plans/              # Plano detalhado de engenharia
└── README.md
```

---

## ⚡ Quickstart: Configurando seu Ambiente

Para vincular todas as skills e subagentes deste repositório aos seus agentes de IA locais no Windows (via **Junctions NTFS** idempotentes):

### 1. Simulação (Dry Run)
```powershell
.\scripts\setup.ps1 -DryRun
```

### 2. Instalação Completa (Claude Code + Antigravity + Codex)
```powershell
.\scripts\setup.ps1
```

### 3. Instalação Específica por Agente
```powershell
# Apenas Claude Code (~/.claude/skills e ~/.claude/agents)
.\scripts\setup.ps1 -Target Claude

# Apenas Antigravity (~/.gemini/config/skills)
.\scripts\setup.ps1 -Target Antigravity

# Apenas Codex (~/.codex/skills)
.\scripts\setup.ps1 -Target Codex
```

### 4. Auditoria de Saúde & Segurança
```powershell
.\scripts\verify.ps1
```
O script `verify.ps1` audita:
- Se há links quebrados (*dangling junctions*);
- Validação sintática do YAML frontmatter em 100% das skills e subagentes;
- **Security Scanner:** Impede que tokens ou credenciais ativas subam para o Git.

---

## 📚 Catálogo de Skills por Categoria

| Categoria | Descrição | Principais Skills |
|---|---|---|
| **`skills/engineering/`** | Qualidade, testes e segurança | `code-reviewer`, `tdd`, `unit-tests`, `security-review`, `vibe-code-security`, `setup-pre-commit`, `setup-ts-deep-modules`, `migrate-to-shoehorn`, `resolving-merge-conflicts` |
| **`skills/architecture/`** | Design e engenharia de software | `codebase-design`, `domain-modeling`, `design-an-interface`, `request-refactor-plan`, `improve-codebase-architecture`, `ubiquitous-language` |
| **`skills/workflow/`** | Condução metódica de tarefas | `brainstorming`, `project-blueprint`, `grilling`, `grill-me`, `batch-grill-me`, `start-task`, `next-task`, `progress`, `standup`, `triage`, `verify`, `handoff` |
| **`skills/knowledge/`** | Gestão de conhecimento e Segundo Cérebro | `cognito-agent`, `obsidian-vault`, `book-to-skill`, `research`, `graphify`, `teach` |
| **`skills/specialized/`** | Frontend, QA e Autenticação | `frontend-design`, `prototype`, `qa`, `keycloak`, `keycloak-auth`, `sonarqube` |
| **`skills/meta/`** | Criação e governança de skills | `skill-creator`, `skill-search`, `find-skill`, `init-skills`, `install-skill`, `list-skills`, `update-skills`, `writing-great-skills` |

---

## 🤖 Catálogo de Subagentes Curados (VoltAgent)

Subagentes em formato `.md` instalados diretamente em `~/.claude/agents/`:

| Domínio | Subagente | Especialidade |
|---|---|---|
| **Linguagens** | `spring-boot-engineer` | Spring Boot 3+, Microservices, GraalVM, Clean Architecture |
| | `java-architect` | Padrões corporativos Java, concorrência e JVM tuning |
| | `vue-expert` | Vue 3 Composition API, Quasar Framework, Pinia e TypeScript |
| | `typescript-pro` | Tipagem estrita, utility types e arquitetura frontend modular |
| | `sql-pro` | Modelagem relacional, otimização de queries e índices |
| | `python-pro` | Scripts rápidos, automações e APIs assíncronas FastAPI |
| | `powershell-7-expert` | Automação avançada de sistema e pipelines Windows/Linux |
| **Arquitetura** | `api-designer` | Design de APIs RESTful, contratos OpenAPI e governança |
| | `mcp-developer` | Desenvolvimento de servidores e ferramentas MCP |
| | `docker-expert` | Dockerfiles multi-stage otimizados e Docker Compose |
| | `git-workflow-manager` | Estratégia de branches, Conventional Commits e release flows |
| **Qualidade & Debug** | `debugger` | Resolução sistemática de defeitos e bugs complexos |
| | `error-detective` | Rastreamento e diagnóstico de causa-raiz em stacktraces |
| | `performance-engineer` | Profiling de gargalos, latência e consumo de recursos |
| | `security-auditor` | Varredura OWASP Top 10, sanitização e RBAC |
| | `test-automator` | Pirâmide de testes e automação de testes de unidade e integração |
| **IA & Raciocínio** | `prompt-engineer` | Engenharia de prompts, few-shot prompting e mitigação de slop |
| | `llm-architect` | Arquitetura de sistemas baseados em LLM, RAG e harnesses |
| | `context-manager` | Gestão eficiente de janelas de contexto e mitigação de Context Rot |
| | `first-principles-thinking` | Resolução de problemas via decomposição em primeiros princípios |

---

## 🔌 Camada de Model Context Protocol (MCP)

O repositório fornece templates prontos em `mcps/configs/`:
- `claude_desktop_config.example.json`
- `antigravity_mcp.example.json`

### Servidores Integrados:
1. **Raciocínio & Documentação:** `sequential-thinking` (Anthropic), `context7` (Upstash/Docs ao vivo), `memory`.
2. **Engenharia Local:** `filesystem`, `git`, `github`, `postgres`, `docker`.
3. **Web & Automação:** `playwright`, `chrome_devtools`, `exa`.
4. **Conhecimento & Qualidade:** `obsidian`, `sonarqube`.

---

## 🛡️ Política de Segurança e Compliance

1. **Zero Segredos no Git:** Chaves de API, senhas e tokens **nunca** são commitados. Utilize variáveis de ambiente locais referenciadas pelos templates.
2. **Zero Dependência Corporativa:** Todas as ferramentas neste repositório são 100% agnósticas e utilizáveis em qualquer projeto pessoal ou de código aberto.
