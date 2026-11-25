# Vue 3 + Quasar Keycloak Integration Guide

This guide details the standard, production-proven Keycloak authentication implementation for Vue 3 applications built with Quasar Framework, Vite, Vue Router, and Pinia.

---

## 1. Dependencies & Environment Setup

Install the official Keycloak JS adapter:
```bash
npm install keycloak-js
# or
yarn add keycloak-js
```

Define environment variables in `.env`:
```env
AUTH_URL=https://iam.domain.com/auth/
KEYCLOAK_REALM=meu-realm
KEYCLOAK_CLIENT_ID=painel-atendente
```

Ensure `quasar.config.ts` loads environment variables and registers the `auth` boot file:
```typescript
// quasar.config.ts
export default defineConfig(() => {
  return {
    boot: ['auth.ts'],
    build: {
      env: {
        ...dotEnv.config().parsed,
      },
    },
  };
});
```

---

## 2. Boot File Implementation (`src/boot/auth.ts`)

Create `src/boot/auth.ts` to initialize Keycloak before the Vue application mounts:

```typescript
import { defineBoot } from '#q-app/wrappers';
import Keycloak from 'keycloak-js';

let auth: Keycloak;

const keycloak = new Keycloak({
  url: process.env.AUTH_URL as string,
  realm: process.env.KEYCLOAK_REALM as string || 'meu-realm',
  clientId: process.env.KEYCLOAK_CLIENT_ID as string || 'painel-atendente',
});

export default defineBoot(async ({ app }) => {
  const REFRESH_MIN_VALIDITY = 70; // Refresh if expiring within 70 seconds
  const REFRESH_INTERVAL_MS = 60_000; // Check every 60 seconds

  const saveToken = () => {
    if (keycloak.token) {
      localStorage.setItem('access_token', keycloak.token);
    }
    if (keycloak.tokenParsed?.session_state) {
      localStorage.setItem('session_state', keycloak.tokenParsed.session_state);
    }
    if (keycloak.tokenParsed?.sub) {
      localStorage.setItem('uuid_usuario', keycloak.tokenParsed.sub);
    }
    app.config.globalProperties.$auth = keycloak;
  };

  // Initialize Keycloak SSO
  await keycloak.init({
    onLoad: 'check-sso',
    pkceMethod: 'S256',
    enableLogging: process.env.NODE_ENV !== 'production',
    scope: 'openid profile email',
  });

  auth = keycloak;
  saveToken();

  // Keycloak Event Listeners
  keycloak.onAuthSuccess = () => {
    saveToken();
  };

  keycloak.onAuthRefreshSuccess = () => {
    saveToken();
  };

  keycloak.onAuthRefreshError = () => {
    console.error('Keycloak: Failed to refresh access token');
  };

  keycloak.onTokenExpired = () => {
    keycloak.updateToken(REFRESH_MIN_VALIDITY)
      .then((refreshed) => {
        if (refreshed) saveToken();
      })
      .catch((err) => {
        console.error('Keycloak: Error renewing expired token', err);
      });
  };

  // Proactive background refresh interval
  setInterval(() => {
    if (!keycloak.authenticated) return;

    keycloak.updateToken(REFRESH_MIN_VALIDITY)
      .then((refreshed) => {
        if (refreshed) {
          saveToken();
        }
      })
      .catch((err) => {
        console.error('Keycloak: Interval token update failed', err);
      });
  }, REFRESH_INTERVAL_MS);
});

export { auth, keycloak };
```

---

## 3. Route Guard (`src/router/index.ts`)

Protect routes requiring authentication in `src/router/index.ts`:

```typescript
import { defineRouter } from '#q-app/wrappers';
import { createRouter, createWebHistory } from 'vue-router';
import routes from './routes';
import { auth } from 'src/boot/auth';

export default defineRouter(function () {
  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,
    history: createWebHistory(),
  });

  Router.beforeEach(async (to, from, next) => {
    if (to.matched.some((route) => route.meta.requiresAuth)) {
      if (auth && auth.authenticated) {
        next();
      } else {
        await auth.login();
      }
    } else {
      next();
    }
  });

  return Router;
});
```

Flag protected routes in `src/router/routes.ts`:
```typescript
const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'Home', component: () => import('pages/IndexPage.vue') },
    ],
  },
];
```

---

## 4. User Store & JWT Decoding (`src/stores/user.ts`)

Create a Pinia store to manage user profile claims and state:

```typescript
import { defineStore } from 'pinia';
import UtilsJWT from 'src/utils/jwttoken.utils';

export const useUserStore = defineStore('user', {
  state: () => ({
    user: {
      access_token: localStorage.getItem('access_token') || '',
    },
  }),
  getters: {
    userData(state) {
      if (!state.user.access_token) return {};
      const decoded = UtilsJWT.decodeToken(state.user.access_token);
      if (!decoded) return {};
      const payload = JSON.parse(decoded);
      return {
        name: payload.name,
        email: payload.email,
        uuid: payload.sub,
        preferred_username: payload.preferred_username,
        roles: payload.realm_access?.roles || [],
        clientRoles: payload.resource_access || {},
      };
    },
    hasRole: (state) => (role: string) => {
      const roles = state.userData.roles || [];
      return roles.includes(role);
    },
  },
});
```

JWT Helper (`src/utils/jwttoken.utils.ts`):
```typescript
function decodeToken(token: string): string | undefined {
  if (!token) return;
  const parts = token.split('.');
  if (parts.length !== 3) return;
  
  let base64Url = parts[1];
  let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  const pad = base64.length % 4;
  if (pad) {
    base64 += '='.repeat(4 - pad);
  }
  
  const decoded = window.atob(base64);
  return decodeURIComponent(escape(decoded));
}

export default { decodeToken };
```

---

## 5. Attaching Tokens to HTTP Requests

Inject Bearer token into all backend requests (`src/utils/headers.utils.ts`):

```typescript
export const DEFAULT_HEADERS = () => new Headers({
  'Content-Type': 'application/json; charset=UTF-8',
  'Authorization': `Bearer ${localStorage.getItem('access_token') || ''}`,
});
```

For Axios clients:
```typescript
import axios from 'axios';
import { keycloak } from 'src/boot/auth';

const api = axios.create({ baseURL: process.env.BASE_URL });

api.interceptors.request.use(async (config) => {
  if (keycloak && keycloak.authenticated) {
    // Ensure token is valid for at least 30 more seconds before sending request
    await keycloak.updateToken(30).catch(() => keycloak.login());
    config.headers.Authorization = `Bearer ${keycloak.token}`;
  }
  return config;
});

export default api;
```

---

## 6. Main Layout & Logout Flow (`src/layouts/MainLayout.vue`)

```vue
<template>
  <q-layout view="hHh Lpr lFf">
    <q-header class="bg-primary text-white">
      <q-toolbar>
        <q-toolbar-title>
          Olá, <strong>{{ userStore.userData.name }}</strong>
        </q-toolbar-title>
        <q-btn flat round dense icon="mdi-logout" label="Sair" @click="handleLogout" />
      </q-toolbar>
    </q-header>
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { keycloak } from 'src/boot/auth';
import { useUserStore } from 'src/stores/user';

const userStore = useUserStore();

function handleLogout() {
  localStorage.clear();
  sessionStorage.clear();
  keycloak.logout({
    redirectUri: window.location.origin,
  });
}
</script>
```
