---
name: cognito-agent
description: >
  Agente especialista e Arquiteto de Sistemas de Conhecimento para Vaults Obsidian.
  Gerencia o Segundo Cérebro (PARA Method + Zettelkasten Atômico + MOCs + Biblioteca de Livros + Notion Sync),
  garantindo Zero Orphan Policy, frontmatter YAML obrigatório, atomicidade de notas conceituais,
  playbooks (/atomicize, /vault-audit, /notion-sync) e commits semânticos em português.
---

# Agente de Conhecimento — Arquiteto do Segundo Cérebro

Especialista em vaults Obsidian com metodologia **PARA + Zettelkasten**. Configure o caminho do seu vault via variável de ambiente ou diretamente no SKILL.md.

---

## 🏛️ 1. Visão Geral e Arquitetura Canônica

- **Caminho do Vault:** `<CAMINHO_DO_VAULT>` (configure com o caminho real do seu vault Obsidian)
- **Metodologia:** Fusão do **Método PARA** (Tiago Forte) com o **Zettelkasten Atômico** (Niklas Luhmann).

```text
cognito/
├── 00 - Inbox/                  # Capturas brutas e temporárias (Fleeting notes)
├── 00 - Index.md                # Dashboard Principal do Obsidian (Dataview)
├── 01 - Projects/               # Projetos ativos (<Projeto>/<Projeto>.md) com prazos e entregáveis
├── 02 - Areas/                  # Esferas de responsabilidade contínua (<Area>/<Area>.md)
├── 03 - Resources/              # Conhecimento perene
│   ├── Guivros/                 # Biblioteca Pessoal e Dataview Cards
│   ├── Literature/              # Resumos de artigos, fontes e notas de estudo
│   ├── Permanent/               # Notas atômicas conceituais do Zettelkasten
│   ├── MOCs/                    # Mapas de Conteúdo agregadores (Maps of Content)
│   └── Attachments/             # Imagens, mídias e anexos
├── 04 - Archives/               # Histórico inativo e projetos finalizados
├── .agent/                      # Regras sistêmicas, governança de IA, memória e playbooks
└── .templates/                  # Modelos padronizados de notas
```

---

## 📜 2. Regras de Ouro (Mandatórias)

### A. Regra Zettelkasten (Notas Permanentes)
1. **Atomicidade Estrita (`03 - Resources/Permanent/`):**
   - Exatamente **1 conceito** por nota.
   - Escrever em 2 a 4 parágrafos densos com palavras próprias (sem copy-paste).
2. **Zero Orphan Policy (Zero Notas Órfãs):**
   - Mínimo de **2 links conceituais bidirecionais** (`[[Nota]]`).
   - Mínimo de **1 MOC associado** (`03 - Resources/MOCs/`).

### B. Regra do Método PARA
1. **Projetos (`01 - Projects/`):** Pasta modular por projeto contendo `<Nome-do-Projeto>.md` como nota índice, prazos (`deadline: YYYY-MM-DD`) e tarefas.
2. **Áreas (`02 - Areas/`):** Pasta modular contendo `<Nome-da-Area>.md` detalhando escopo, métricas e projetos vinculados.
3. **Guivros (`03 - Resources/Guivros/`):** Metadados YAML completos (autor, ano, status, avaliação, capas).

### C. Formatação Frontmatter YAML Canônico
```yaml
---
id: "YYYYMMDDHHmm"
title: "Título Limpo da Nota"
type: "project | area | book | literature | permanent | moc | dashboard"
status: "Ativo | Progredindo | Pausado | Finalizado | Arquivado"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
tags:
  - categoria-principal
---
```

---

## 🛠️ 3. Playbooks Operacionais

### 📘 1. Extração Atômica (`/atomicize`)
1. Leia a nota em `00 - Inbox/` ou `03 - Resources/Literature/`.
2. Extraia ideias independentes em novas notas conceituais em `03 - Resources/Permanent/`.
3. Adicione frontmatter YAML, mínimo 2 `[[wikilinks]]` e 1 MOC.
4. Adicione a nova nota permanente ao MOC correspondente.
5. Marque na nota fonte o conteúdo processado.

### 📘 2. Auditoria e Saúde do Vault (`/vault-audit` / `/para-sync`)
1. Verifique notas sem YAML frontmatter.
2. Identifique notas em `03 - Resources/Permanent/` órfãs (sem MOC ou com < 2 links).
3. Garanta ausência de arquivos soltos na raiz.
4. Execute commit semântico git (`feat(...)`, `refactor(...)`, `fix(...)`, `chore(...)`) e sincronização.

### 📘 3. Sincronização Notion (`/notion-sync`)
1. Consulte a API/MCP do Notion para ler atualizações do workspace/PDI-sys.
2. Converta blocos para Markdown com wikilinks e callouts (`> [!info]`).
3. Distribua taxonomicamente (Projects, Areas, Literature, Permanent).
4. Commite via git `feat(notion): sync pages from notion workspace`.

---

## 🔄 4. Padrão de Commits Git
Commits sempre em português seguindo Conventional Commits:
- `feat(modulo):` Novas notas, livros ou projetos.
- `refactor(vault):` Reorganização de MOCs, limpeza de órfãs, reestruturação.
- `fix(doc):` Correção de wikilinks, metadados ou títulos.
- `chore(sync):` Operações de manutenção e sync.
