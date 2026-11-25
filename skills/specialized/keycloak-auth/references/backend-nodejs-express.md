# Node.js / Express Keycloak JWT Validation Guide

This guide covers validating Keycloak Bearer JWT tokens in a Node.js Express REST API backend using `jose` or `jwks-rsa` + `jsonwebtoken`.

---

## 1. Dependencies Setup

Install standard JWT verification dependencies:

```bash
npm install express jose dotenv cors
# or using jsonwebtoken + jwks-rsa:
npm install express jsonwebtoken jwks-rsa dotenv cors
npm install --save-dev @types/express @types/cors
```

---

## 2. Dynamic JWKS Verification Middleware (`jose`)

Using `jose` is light, dependency-free, and handles JWKS caching and key rotation automatically:

```typescript
// middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { createRemoteJWKSet, jwtVerify, JWTPayload } from 'jose';

const KEYCLOAK_URL = process.env.KEYCLOAK_URL || 'https://iam.domain.com/auth/';
const REALM = process.env.KEYCLOAK_REALM || 'meu-realm';
const CLIENT_ID = process.env.KEYCLOAK_CLIENT_ID || 'painel-atendente';

const JWKS_URI = `${KEYCLOAK_URL.replace(/\/$/, '')}/realms/${REALM}/protocol/openid-connect/certs`;
const ISSUER_URI = `${KEYCLOAK_URL.replace(/\/$/, '')}/realms/${REALM}`;

// Remote JWKS key set (cached in memory automatically)
const JWKS = createRemoteJWKSet(new URL(JWKS_URI));

export interface AuthenticatedRequest extends Request {
  user?: JWTPayload & {
    preferred_username?: string;
    email?: string;
    name?: string;
    realm_access?: { roles: string[] };
    resource_access?: Record<string, { roles: string[] }>;
  };
}

export async function verifyKeycloakToken(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Header Authorization no formato Bearer token é obrigatório' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: ISSUER_URI,
    });

    req.user = payload as AuthenticatedRequest['user'];
    next();
  } catch (error: any) {
    console.error('Falha na verificação do token Keycloak:', error.message);
    return res.status(401).json({ error: 'Token inválido ou expirado', details: error.message });
  }
}

export function requireRole(requiredRole: string) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Não autenticado' });
    }

    const realmRoles = req.user.realm_access?.roles || [];
    const clientRoles = req.user.resource_access?.[CLIENT_ID]?.roles || [];
    const allRoles = [...realmRoles, ...clientRoles].map(r => r.toUpperCase());

    if (!allRoles.includes(requiredRole.toUpperCase())) {
      return res.status(403).json({ error: `Acesso negado. Requer a role: ${requiredRole}` });
    }

    next();
  };
}
```

---

## 3. Express Application Setup (`src/app.ts`)

```typescript
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { verifyKeycloakToken, requireRole, AuthenticatedRequest } from './middleware/auth.middleware';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Public Endpoint
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'UP', timestamp: new Date() });
});

// Protected Endpoint
app.get('/api/v1/user/me', verifyKeycloakToken, (req: AuthenticatedRequest, res) => {
  res.json({
    uuid: req.user?.sub,
    username: req.user?.preferred_username,
    email: req.user?.email,
    name: req.user?.name,
  });
});

// Admin-Only Endpoint
app.get('/api/v1/admin/dashboard', verifyKeycloakToken, requireRole('ADMIN'), (req, res) => {
  res.json({ message: 'Bem-vindo ao painel administrativo!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```
