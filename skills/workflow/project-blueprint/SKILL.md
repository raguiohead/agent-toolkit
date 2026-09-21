---
name: project-blueprint
description: "Cria e mantém a suíte completa de documentação local de projeto: PRD (Product Requirements Document), TDD (Tech Design Document), App Flow (Fluxo da Aplicação), Design Brief (Guia de Design/UI), Backend Schema (Modelo de Dados) e Engineering Plan (Plano de Engenharia e Tarefas). Garante obrigatoriamente que a pasta e os arquivos de documentação sejam adicionados ao .gitignore para nunca serem enviados ao repositório git remoto. Use esta skill sempre que o usuário pedir para criar especificação, PRD, TDD, arquitetura de projeto, fluxo de telas, esquemas de banco ou planejar um novo aplicativo/funcionalidade."
---

# Project Blueprint — Documentação Local de Projeto

Esta skill gera e mantém a estrutura padrão de especificações do projeto dividida em 6 documentos essenciais, garantindo que **permaneçam apenas locais** (ignorados pelo Git).

---

## 🛡️ Regra Fundamental: Segurança do Git (Git Isolation)

**ANTES** de criar qualquer documento de especificação, você **DEVE**:
1. Definir o diretório local de documentação. O padrão recomendado é `.docs/` na raiz do projeto (ou `docs/local/`).
2. Verificar se o arquivo `.gitignore` existe na raiz do projeto. Se não existir, crie-o.
3. Verificar se a pasta de documentação (ex: `.docs/` ou `.docs/*`) está listada no `.gitignore`.
4. Se não estiver, adicione a entrada no `.gitignore` imediatamente e confirme a inclusão.
5. **NUNCA** execute `git add` ou permita que estes arquivos entrem na staging area.

---

## 📑 Os 6 Documentos do Project Blueprint

A documentação é organizada na pasta `.docs/` (ou caminho definido) nos seguintes arquivos:

1. **`PRD.md`** — Product Requirements Document (Visão geral, problema, público e core features).
2. **`TDD.md`** — Tech Design Document (Arquitetura, stack, APIs, ferramentas e decisões técnicas).
3. **`APP_FLOW.md`** — Fluxo do Aplicativo (Jornadas de usuário, telas, onboarding e eventos de botões/ações).
4. **`DESIGN_BRIEF.md`** — Briefing de Design (Look & feel, paleta de cores, tipografia, componentes e regras visuais).
5. **`BACKEND_SCHEMA.md`** — Esquema de Backend (Tabelas/coleções, campos, tipos, relacionamentos e DTOs/payloads).
6. **`ENGINEERING_PLAN.md`** — Plano de Engenharia (Subdivisão em tarefas testáveis, ordens de dependência e critérios de aceite).

---

## 🚀 Fluxo de Execução (Passo a Passo)

### Passo 1: Entrevista & Coleta de Contexto
Se o projeto for novo ou as informações não estiverem totalmente claras na conversa:
- Faça perguntas objetivas sobre o objetivo do produto, público-alvo, stack preferida, identidade visual e banco de dados.
- Se o usuário já forneceu a ideia/código, analise os arquivos do repositório para extrair o contexto automaticamente.

### Passo 2: Garantir Proteção no `.gitignore`
Executar a verificação do `.gitignore` conforme a **Regra Fundamental**:
- Adicionar `.docs/` ao `.gitignore`.

### Passo 3: Geração dos Documentos
Consulte os arquivos de referência detalhados em `references/` para estruturar cada documento com máxima qualidade:
- Para `PRD.md`: veja `references/prd.md`
- Para `TDD.md`: veja `references/tdd.md`
- Para `APP_FLOW.md`: veja `references/app_flow.md`
- Para `DESIGN_BRIEF.md`: veja `references/design_brief.md`
- Para `BACKEND_SCHEMA.md`: veja `references/backend_schema.md`
- Para `ENGINEERING_PLAN.md`: veja `references/engineering_plan.md`

### Passo 4: Apresentação e Confirmação
Após criar os 6 documentos na pasta local (ex: `.docs/`):
1. Confirme ao usuário que os documentos foram criados em `.docs/`.
2. Confirme que `.docs/` foi devidamente inserido no `.gitignore` para proteção remota.
3. Resuma os pontos chave do produto e os primeiros passos recomendados no `ENGINEERING_PLAN.md`.
