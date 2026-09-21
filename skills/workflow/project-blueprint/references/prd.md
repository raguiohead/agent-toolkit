# Estrutura do PRD (Product Requirements Document)

O `PRD.md` deve descrever a visão geral da ideia, o problema a ser resolvido, quem utilizará o produto e todas as funcionalidades principais (core features).

## Template Padrão

```markdown
# 📄 Product Requirements Document (PRD) — [Nome do Projeto]

## 1. Visão Geral & Problema
- **Visão do Produto**: [Descrição clara de 2-3 frases sobre o que o produto é e qual seu objetivo principal].
- **Problema Integrado**: [Qual dor ou problema o produto resolve?].
- **Público-Alvo**: [Perfil dos usuários finais / personas].

## 2. Objetivos & Métricas de Sucesso (KPIs)
- [Objetivo 1, ex: Permitir cadastro de clientes em menos de 2 minutos]
- [Objetivo 2, ex: Suportar até 10.000 requisições simultâneas sem degradação]

## 3. Principais Funcionalidades (Core Features)

### F1: [Nome da Funcionalidade 1]
- **Descrição**: [O que a funcionalidade faz].
- **Valor para o Usuário**: [Por que isso é necessário].
- **Casos de Uso**:
  - [Caso 1]
  - [Caso 2]

### F2: [Nome da Funcionalidade 2]
- **Descrição**: [O que a funcionalidade faz].
- **Valor para o Usuário**: [Por que isso é necessário].

[Adicionar demais funcionalidades F3, F4, etc.]

## 4. Requisitos Não-Funcionais (RNF)
- **Segurança**: [Autenticação JWT/OAuth2, RLS, criptografia de dados sensíveis].
- **Performance**: [Tempo de resposta < 200ms para APIs de leitura].
- **Escalabilidade**: [Suporte a múltiplos clientes / multi-tenancy se aplicável].
- **Disponibilidade**: [Uptime de 99.9%].

## 5. Escopo e Limitações (Out of Scope)
- **O que NÃO será feito nesta versão**:
  - [Item 1 fora do escopo inicial]
  - [Item 2 fora do escopo inicial]

## 6. Premissas e Dependências
- [Dependência de API externa X]
- [Necessidade de credenciais Y]
```
