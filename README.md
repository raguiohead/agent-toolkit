# Agent Toolkit

Arsenal de **skills modulares**, **subagentes especializados**, **templates MCP** e **scripts de automação** para [Claude Code](https://claude.ai/code), [Antigravity](https://deepmind.google/technologies/gemini/code/) e [OpenAI Codex](https://platform.openai.com/docs/guides/code).

Destinado a desenvolvedores que querem tirar o máximo dos seus assistentes de IA — adicionando comportamentos especializados, conexões com ferramentas externas e fluxos de trabalho prontos para usar.

---

## Por que existe?

Assistentes de IA ficam mais úteis quando entendem o contexto do seu projeto, seguem metodologias de engenharia e têm acesso a ferramentas externas (Git, banco de dados, Docker, etc.). O Agent Toolkit empacota esse conhecimento em arquivos versionados e reutilizáveis, que você vincula ao seu agente local em vez de repetir instruções toda vez.

---

## Principais recursos

| Componente | Quantidade | O que faz |
|---|---|---|
| **Skills** | 70 | Instruções especializadas que o agente segue sob demanda (TDD, revisão de código, design de sistemas, gestão de conhecimento, etc.) |
| **Subagentes** | 20 | Agentes especializados invocáveis pelo Claude Code para tarefas de linguagem, arquitetura, debugging e IA |
| **Templates MCP** | 2 | Configurações prontas (com placeholders) para habilitar servidores MCP no Claude Desktop e no Antigravity |
| **Scripts PowerShell** | 2 | Automação de instalação via junctions NTFS e auditoria de saúde do ambiente |

---

## Como funciona

Skills e subagentes são arquivos `.md` com frontmatter YAML lidos pelo agente na hora da invocação. Você não precisa copiar arquivos manualmente: `setup.ps1` cria junctions NTFS (links simbólicos do Windows) dos diretórios deste repositório para as pastas que o Claude Code, Antigravity e Codex esperam.

```
agent-toolkit/          ← este repositório
    skills/
        engineering/
            tdd/SKILL.md ──junction──► ~/.claude/skills/tdd/SKILL.md
            ...
        workflow/
        architecture/
        ...
    agents/
        languages/
            spring-boot-engineer.md ──copy──► ~/.claude/agents/spring-boot-engineer.md
            ...
    mcps/configs/       ← templates para configurar servidores MCP
    scripts/
        setup.ps1       ← instala junctions
        verify.ps1      ← audita integridade
```

Depois da instalação, qualquer mensagem como `/tdd`, `/code-review` ou `use the spring-boot-engineer agent` faz o assistente carregar a skill ou invocar o subagente correto.

---

## Requisitos

| Requisito | Versão mínima |
|---|---|
| **Windows** (para `setup.ps1` / `verify.ps1`) | Windows 10/11 |
| **PowerShell** | 7.x (Core) |
| **Claude Code** | qualquer versão recente |
| **Node.js** (para servidores MCP via `npx`) | 18+ |

**Linux / macOS:** os scripts são PowerShell e não possuem equivalente nativo neste repositório. É possível criar os mesmos links manualmente com `ln -s`:

```bash
# Exemplo: vincular todas as skills ao Claude Code
for dir in skills/*/; do
    ln -s "$(pwd)/$dir" ~/.claude/skills/$(basename "$dir")
done

# Exemplo: copiar subagentes
cp agents/**/*.md ~/.claude/agents/
```

---

## Instalação e primeiro uso (Windows)

### 1. Clonar o repositório

```bash
git clone https://github.com/raguiohead/agent-toolkit.git
cd agent-toolkit
```

### 2. Simular a instalação (recomendado antes de executar)

```powershell
.\scripts\setup.ps1 -DryRun
```

### 3. Instalar (Claude Code + Antigravity + Codex)

```powershell
.\scripts\setup.ps1
```

### 4. Instalar apenas para um agente específico

```powershell
# Apenas Claude Code (~/.claude/skills e ~/.claude/agents)
.\scripts\setup.ps1 -Target Claude

# Apenas Antigravity (~/.gemini/config/skills)
.\scripts\setup.ps1 -Target Antigravity

# Apenas Codex (~/.codex/skills)
.\scripts\setup.ps1 -Target Codex
```

### 5. Auditar saúde do ambiente

```powershell
.\scripts\verify.ps1
```

O `verify.ps1` verifica:
- Junctions válidas (sem links quebrados)
- Sintaxe do YAML frontmatter em todas as skills e subagentes
- Ausência de tokens ou credenciais hardcoded

### 6. Configurar servidores MCP (opcional)

Copie o template correspondente ao seu agente:

| Agente | Template | Destino |
|---|---|---|
| Claude Desktop / Claude Code | [`mcps/configs/claude_desktop_config.example.json`](mcps/configs/claude_desktop_config.example.json) | `%APPDATA%\Claude\claude_desktop_config.json` |
| Antigravity | [`mcps/configs/antigravity_mcp.example.json`](mcps/configs/antigravity_mcp.example.json) | Configuração do Antigravity |

Substitua os placeholders (`${GITHUB_TOKEN}`, `${EXA_API_KEY}`, etc.) pelas suas variáveis de ambiente antes de usar.

---

## Exemplo de uso

Após a instalação, dentro do Claude Code:

```
/tdd           → ativa o fluxo de Test-Driven Development
/code-review   → inicia revisão estruturada do diff atual
/brainstorming → abre sessão guiada de ideação
/handoff       → gera resumo de contexto para troca de sessão
```

Para invocar um subagente especializado:

```
Use the spring-boot-engineer agent to implement this endpoint.
Use the security-auditor agent to review this authentication flow.
```

---

## Estrutura de pastas

```
agent-toolkit/
├── skills/
│   ├── engineering/    # Qualidade de código, TDD, revisão, segurança, Git
│   ├── architecture/   # Design de sistemas, modelagem de domínio, refatoração
│   ├── workflow/       # Condução de tarefas, brainstorming, triagem, handoff
│   ├── knowledge/      # Gestão de conhecimento, Obsidian, pesquisa
│   ├── specialized/    # Frontend design, QA, autenticação (Keycloak), SonarQube
│   └── meta/           # Criação, busca e governança de skills
├── agents/
│   ├── languages/      # Spring Boot, Java, Vue 3, TypeScript, SQL, Python, PowerShell
│   ├── architecture/   # API Designer, MCP Developer, Docker, Git Workflow
│   ├── debugging/      # Debugger, Error Detective, Performance, Security Auditor
│   └── reasoning-ai/   # Prompt Engineer, LLM Architect, Context Manager, First Principles
├── mcps/
│   ├── configs/        # Templates de configuração MCP (Claude Desktop, Antigravity)
│   └── README.md       # Catálogo detalhado dos servidores MCP disponíveis
├── scripts/
│   ├── setup.ps1       # Instalação via junctions NTFS (idempotente)
│   └── verify.ps1      # Auditoria de saúde, linting e scanner de segredos
└── docs/
    └── superpowers/    # Especificações técnicas e planos de implementação
```

---

## Servidores MCP disponíveis

Os templates em `mcps/configs/` configuram os seguintes servidores (via `npx`):

| Servidor | Finalidade | Variável necessária |
|---|---|---|
| `sequential-thinking` | Raciocínio passo a passo | — |
| `context7` | Documentação oficial em tempo real | `CONTEXT7_API_KEY` (opcional) |
| `filesystem` | Acesso a arquivos locais | Caminhos permitidos |
| `git` | Diffs e histórico de repositórios | — |
| `github` | Issues, PRs e repositórios GitHub | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| `postgres` | Consultas e inspeção de schema | String de conexão local |
| `docker` | Monitoramento de containers | Docker Desktop ativo |
| `playwright` | Automação de navegador | Node 18+ |
| `chrome-devtools` | Depuração via CDP | — |
| `exa` | Pesquisa web profunda | `EXA_API_KEY` |
| `obsidian` | Leitura de vault Obsidian | `OBSIDIAN_VAULT_PATH` |

---

## Como contribuir

Este repositório é pessoal e não mantém um fluxo formal de contribuições externas. Forks são bem-vindos. Se encontrar um problema ou tiver uma sugestão, abra uma issue.

Ao criar ou modificar skills, siga o padrão de frontmatter YAML existente e execute `verify.ps1` antes de commitar.

---

## Status do projeto

Ativo. Novas skills e subagentes são adicionados conforme o uso prático revela necessidades.

---

## Licença

Licença ainda não definida. Todo o conteúdo é fornecido como está, sem garantias.

---

## In English

**Agent Toolkit** is a curated collection of modular skills, specialized sub-agents, MCP server templates, and automation scripts for Claude Code, Antigravity, and OpenAI Codex.

- **Skills** (70): Markdown instruction files the AI agent loads on demand — covering TDD, code review, system design, brainstorming, knowledge management, and more.
- **Sub-agents** (20): Specialized Claude Code agents for Spring Boot, Java, Vue 3, TypeScript, Python, SQL, PowerShell, Docker, API design, debugging, and AI reasoning.
- **MCP templates** (2): Ready-to-use JSON configs (with placeholder variables) for Claude Desktop and Antigravity.
- **PowerShell scripts**: `setup.ps1` links the repository into the agent's expected directories via NTFS junctions; `verify.ps1` audits integrity and scans for hardcoded secrets.

See the sections above for installation instructions. Linux/macOS users can create symlinks manually — refer to the [Installation](#instalação-e-primeiro-uso-windows) section for the equivalent `ln -s` commands.
