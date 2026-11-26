# React & Next.js Keycloak Integration Guide

This guide covers Keycloak authentication for React Single Page Applications (SPAs) and Next.js applications (App Router and Pages Router).

---

## 1. React SPA Implementation (`keycloak-js`)

### Dependencies
```bash
npm install keycloak-js @react-keycloak/web
```

### Keycloak Client Setup (`src/keycloak.ts`)
```typescript
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: process.env.REACT_APP_KEYCLOAK_URL || 'https://iam.domain.com/auth/',
  realm: process.env.REACT_APP_KEYCLOAK_REALM || 'meu-realm',
  clientId: process.env.REACT_APP_KEYCLOAK_CLIENT_ID || 'react-app-client',
});

export default keycloak;
```

### Provider Configuration (`src/index.tsx`)
Wrap your React tree with `ReactKeycloakProvider`:

```tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { ReactKeycloakProvider } from '@react-keycloak/web';
import keycloak from './keycloak';
import App from './App';

const eventLogger = (event: string, error?: unknown) => {
  console.log('onKeycloakEvent', event, error);
};

const tokenLogger = (tokens: { token?: string }) => {
  if (tokens.token) {
    localStorage.setItem('access_token', tokens.token);
  }
};

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <ReactKeycloakProvider
    authClient={keycloak}
    initOptions={{
      onLoad: 'check-sso',
      pkceMethod: 'S256',
    }}
    onEvent={eventLogger}
    onTokens={tokenLogger}
  >
    <App />
  </ReactKeycloakProvider>
);
```

### Accessing Auth State & Protected Routes (`src/App.tsx`)
```tsx
import React from 'react';
import { useKeycloak } from '@react-keycloak/web';

export const UserProfile: React.FC = () => {
  const { keycloak, initialized } = useKeycloak();

  if (!initialized) {
    return <div>Carregando autenticação...</div>;
  }

  if (!keycloak.authenticated) {
    return (
      <div>
        <p>Você não está autenticado.</p>
        <button onClick={() => keycloak.login()}>Entrar com Keycloak</button>
      </div>
    );
  }

  const userInfo = keycloak.tokenParsed;

  return (
    <div>
      <h2>Bem-vindo, {userInfo?.name}</h2>
      <p>Email: {userInfo?.email}</p>
      <button onClick={() => {
        localStorage.clear();
        keycloak.logout({ redirectUri: window.location.origin });
      }}>
        Sair
      </button>
    </div>
  );
};
```

---

## 2. Next.js Integration (NextAuth.js / Auth.js)

For Next.js (App Router or Pages Router), the recommended approach is using NextAuth.js with the built-in `KeycloakProvider` to maintain secure HttpOnly session cookies server-side.

### Dependencies
```bash
npm install next-auth
```

### NextAuth Configuration (`src/app/api/auth/[...nextauth]/route.ts`)
```typescript
import NextAuth, { NextAuthOptions } from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

export const authOptions: NextAuthOptions = {
  providers: [
    KeycloakProvider({
      clientId: process.env.KEYCLOAK_CLIENT_ID!,
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET!,
      issuer: `${process.env.KEYCLOAK_URL}/realms/${process.env.KEYCLOAK_REALM}`,
    }),
  ],
  callbacks: {
    async jwt({ token, account, profile }) {
      if (account) {
        token.accessToken = account.access_token;
        token.refreshToken = account.refresh_token;
        token.idToken = account.id_token;
        token.expiresAt = account.expires_at;
      }
      return token;
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken as string;
      session.user.id = token.sub as string;
      return session;
    },
  },
};

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
```

### Next.js Middleware Protection (`src/middleware.ts`)
```typescript
export { default } from "next-auth/middleware";

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
};
```
