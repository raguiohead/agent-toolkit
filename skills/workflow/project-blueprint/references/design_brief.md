# Estrutura do Design Brief (Briefing de Design)

O `DESIGN_BRIEF.md` define a identidade visual (look & feel), paleta de cores, tipografia, componentes e convenções de estilo das telas, garantindo consistência e prevenindo geração aleatória de layouts pela IA.

## Template Padrão

```markdown
# 🎨 Design Brief & Visual Identity — [Nome do Projeto]

## 1. Identidade & Estilo (Look & Feel)
- **Tom & Estilo**: [ex: Moderno, Limpo, Profissional, Minimalista, Dark Mode por padrão / Light Mode].
- **Diretriz de Design**: [ex: Interfaces de alta densidade de informação com foco em clareza, contrastes acessíveis (WCAG AA) e cantos levemente arredondados].

## 2. Paleta de Cores (Design Tokens)
- **Primary (Cor Principal)**: `#0066FF` (Azul Tecnológico)
- **Primary Hover / Active**: `#0052CC`
- **Secondary (Acompanhamento)**: `#10B981` (Verde Sucesso/Ação)
- **Background (Fundo)**: `#0F172A` (Slate Dark) / `#FFFFFF` (Modo Claro)
- **Surface / Card**: `#1E293B` / `#F8FAFC`
- **Text Primary**: `#F8FAFC` / `#0F172A`
- **Text Secondary**: `#94A3B8` / `#64748B`
- **Border / Divider**: `#334155` / `#E2E8F0`
- **Status / State Colors**:
  - Success: `#22C55E`
  - Warning: `#F59E0B`
  - Error: `#EF4444`
  - Info: `#3B82F6`

## 3. Tipografia
- **Família de Fontes**: [ex: Inter / Roboto / Plus Jakarta Sans], fallback `sans-serif`.
- **Escala Tipográfica**:
  - H1: `32px` / Bold / Line-height: `1.2`
  - H2: `24px` / SemiBold / Line-height: `1.3`
  - H3: `20px` / Medium / Line-height: `1.4`
  - Body: `16px` / Regular / Line-height: `1.5`
  - Small / Caption: `14px` / Regular / Line-height: `1.4`

## 4. Sistema de Espaçamento e Grids
- **Unidade Base de Grid**: `8px` (multiplicadores: 8px, 16px, 24px, 32px, 48px).
- **Border Radius**: Small (`4px`), Medium (`8px`), Large (`16px`), Pill (`9999px`).

## 5. Componentes Padrão
- **Botões**:
  - Primary: Fundo primário, texto claro, padding `10px 20px`, transição suave no hover.
  - Secondary: Outlined com borda suave, fundo transparente.
  - Ghost / Text: Sem borda ou fundo, apenas texto com feedback no hover.
- **Inputs & Forms**:
  - Label visível no topo, borda discreta, efeito focus com anel (focus-ring) na cor primária.
  - Mensagem de erro em vermelho abaixo do campo.
- **Cards & Modais**:
  - Sombra sutil (`box-shadow`), padding interno de `24px`, cabeçalho delimitado.

## 6. Regras Antideriva para IAs (Layout Consistency Guards)
- ❌ NÃO misturar estilos de botões (ex: botões 3D com botões totalmente flat no mesmo painel).
- ❌ NÃO alterar a paleta de cores arbitrariamente em telas secundárias.
- ✅ SEMPRE usar componentes da biblioteca padrão do projeto (ex: Quasar / Tailwind / Material UI).
```
