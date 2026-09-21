---
name: vibe-code-security
description: "Audita e blinda aplicações geradas por IA (Vibe Coding / assistentes de código) contra as 5 falhas de segurança mais comuns: RLS desativado no Supabase/Firebase, validações/permissões apenas no frontend, rotas com IDOR/BOLA sem checagem de dono, chaves e segredos expostos no bundle do front ou Git, e inputs/uploads sem validação e sem rate limit. Aplica checklists pré-deploy, arquitetura BFF e integração de scanners SAST/DAST (Gitleaks, Bandit, Opengrep, OWASP ZAP)."
---

# 🛡️ Vibe Code Security: Auditoria de Segurança em Código Gerado por IA

Esta skill é especializada em identificar, auditar e corrigir as vulnerabilidades mais frequentes introduzidas em código gerado por IA (*Vibe Coding*, LLMs, copilots).

Modelos de linguagem entregam rapidamente o que foi solicitado visualmente e funcionalmente, mas frequentemente omitem camadas defensivas silenciosas (RLS, autorização server-side, rate limiting, sanitização e isolamento de segredos).

---

## 🚨 Os 5 Vacilos Críticos de Segurança em Código de IA

### 1. RLS (Row Level Security) Desligado no Supabase / Firebase & Vazamento de `service_role`
- **Problema:** Em BaaS (Backend-as-a-Service), o client conecta direto ao banco. Se o RLS estiver desativado, qualquer usuário com a chave pública (`anon`) pode ler e escrever dados de outros usuários via console/REST.
- **Risco Crítico Adicional:** Expor a chave mestra (`service_role` ou chave de admin do Firebase) no frontend, que ignora qualquer regra de RLS.
- **Remediação:**
  ```sql
  -- Ativar RLS em toda tabela pública
  ALTER TABLE public.sua_tabela ENABLE ROW LEVEL SECURITY;

  -- Criar policies explícitas por usuário
  CREATE POLICY "Usuarios acessam apenas seus proprios dados"
  ON public.sua_tabela
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
  ```
  - **Regra de Ouro:** Apenas a chave `anon` vai para o frontend. A chave `service_role` **NUNCA** pode estar no bundle client-side ou no repositório.

---

### 2. Regras de Negócio e Permissões Decididas Apenas no Frontend
- **Problema:** Ocultar telas, botões ou rotas sensíveis via `v-if`, `isAdmin` ou condicionais no menu/sidebar sem validar o token e o perfil no backend. Qualquer usuário pode forçar chamadas HTTP para os endpoints administrativos.
- **Remediação:**
  - O frontend apenas adapta a experiência visual (UX); a **autorização real deve ser validada no servidor/middleware**.
  ```typescript
  // ❌ Inseguro (apenas no front):
  if (user.role === 'admin') showAdminPanel();

  // ✅ Seguro: Backend/Edge Function valida claims do token JWT
  export async function handleAdminAction(req: Request) {
    const token = extractJwt(req);
    if (!token || token.role !== 'admin') {
      return new Response(JSON.stringify({ error: 'Forbidden' }), { status: 403 });
    }
    // executa ação administrativa...
  }
  ```

---

### 3. Fetch de Dados sem Validação de Posse (IDOR / BOLA)
- **Problema:** Endpoints que buscam registros por ID (ex: `GET /api/documents/:id`, `PATCH /api/orders/:id`) devolvem ou alteram o registro sem verificar se o `userId` autenticado é o proprietário legítimo do recurso.
- **Remediação:**
  ```typescript
  // ❌ Inseguro: Busca direto pelo ID vindo da URL
  const doc = await db.document.findUnique({ where: { id: req.params.id } });

  // ✅ Seguro: Filtra pelo ID do recurso E pelo ID do usuário autenticado
  const doc = await db.document.findFirst({
    where: {
      id: req.params.id,
      userId: authenticatedUser.id // Garante posse do dado
    }
  });
  if (!doc) {
    return res.status(404).json({ error: 'Recurso não encontrado' });
  }
  ```

---

### 4. Chaves Secretas e API Keys Expostas no Bundle ou no Git
- **Problema:** Variáveis de ambiente inseridas em projetos frontend (ex: `VITE_API_KEY`, `NEXT_PUBLIC_STRIPE_SECRET`, chaves de OpenAI, Resend, gateways de pagamento) são embutidas no build JavaScript e lidas por qualquer pessoa via DevTools.
- **Remediação (Padrão BFF - Backend for Frontend):**
  - O frontend nunca faz requisições diretas com API keys de terceiros.
  - O frontend chama um endpoint intermediário próprio no backend/serverless; o servidor armazena as chaves no ambiente seguro e faz o proxy da requisição.
  - Garantir `.env*` no `.gitignore` antes do primeiro commit.

---

### 5. Confiança Cega em Inputs, Uploads e Ausência de Rate Limit
- **Problema:** 
  - Falta de sanitização e validação estrita de schemas (XSS, injeção).
  - Upload de arquivos aceitando extensões perigosas (ex: executáveis, scripts PHP/HTML com mimetype forjado).
  - Rotas sensíveis (login, recuperação de senha, geração de IA, webhooks) sem controle de frequência (Rate Limiting).
- **Remediação:**
  - Validar payloads de entrada com validadores de schema (Zod, Joi, Bean Validation).
  - Validar arquivos por *magic bytes* e extensão estrita, renomeando o arquivo salvo e servindo-o com cabeçalhos de download restritivos (`Content-Disposition: attachment`).
  - Aplicar rate limiting por IP/token em rotas de auth e custos elevados.

---

## 🛠️ Ferramentas Open Source de Auditoria & Segurança

Integre ou execute estas ferramentas para varredura automatizada:

1. **OWASP ZAP (DAST)**
   - *Finalidade:* Scanner dinâmico da OWASP Foundation para testar aplicações em execução contra portas abertas, falhas de injeção e headers faltantes.
   - *Download/Docs:* [zaproxy.org](https://www.zaproxy.org/) / [GitHub zaproxy](https://github.com/zaproxy/zaproxy)

2. **Gitleaks (Secret Detection)**
   - *Finalidade:* Caça credenciais, tokens de API e senhas no código-fonte e em todo o histórico do Git.
   ```bash
   # Executar na raiz do projeto:
   gitleaks detect --source . -v
   ```

3. **Opengrep (SAST Poliglota)**
   - *Finalidade:* Motor de análise estática open source (fork do Semgrep) mantido por consórcio público para detectar SQLi, XSS, IDOR e brechas lógicas em várias linguagens.
   - *Repo:* [github.com/opengrep/opengrep](https://github.com/opengrep/opengrep)

4. **Bandit (SAST Python)**
   - *Finalidade:* Análise estática focada em vulnerabilidades conhecidas em Python.
   ```bash
   pip install bandit
   bandit -r ./seu_projeto
   ```

---

## 📋 Checklist Pré-Deploy

Antes de subir qualquer projeto para produção, execute este checklist:

- [ ] **RLS Ativo:** `ENABLE ROW LEVEL SECURITY` em todas as tabelas no Supabase/Postgres + policies configuradas.
- [ ] **Segredo Isolado:** `service_role` / chaves de admin privadas **NUNCA** constam no código do frontend ou repositório.
- [ ] **Autorização no Backend:** Toda checagem de permissão e role é verificada no servidor.
- [ ] **Proteção IDOR:** Todo endpoint que recebe `id` valida a posse do recurso contra o usuário autenticado.
- [ ] **BFF Implementado:** Frontend não guarda API keys de provedores terceiros (IA, gateways, e-mails).
- [ ] **Higienização de Inputs & Uploads:** Schemas validados, uploads checam extensão/conteúdo real.
- [ ] **Rate Limiting:** Rotas de autenticação, geração de conteúdo e pagamentos com limitador de taxa.
- [ ] **Varredura Automatizada:** `gitleaks` e scanner SAST rodados e limpos.

---

## 🔍 Prompt Rápido de Auditoria para Agentes

Ao inspecionar código de uma funcionalidade recém-criada por IA, utilize o prompt:

> *"Revisa este código atrás das 5 falhas mais comuns em app gerado por IA: (1) tabelas de Supabase/Firebase sem RLS ou uso de service_role no front; (2) autorização decidida no frontend em vez do servidor; (3) rotas que buscam por ID sem checar o dono (IDOR/BOLA); (4) segredos/API keys expostos no código ou no bundle; (5) input do usuário sem validação/sanitização, upload sem checar tipo de arquivo e falta de rate limit. Lista cada achado com arquivo, linha e a correção recomendada em formato diff."*
