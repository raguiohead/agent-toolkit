# JavaScript & TypeScript Keycloak Integration Reference

This document provides quick-start examples and production patterns for integrating Keycloak in Browser applications (React, Vue, SPA) and Server-side Node.js applications (Express, Next.js).

## 1. Browser / SPA Integration (`keycloak-js`)

Official Keycloak client library for Single Page Applications (React, Vue, Angular, Vanilla JS).

### Installation
```bash
npm install keycloak-js
```

### Initialization with Authorization Code + PKCE
```typescript
import Keycloak from 'keycloak-js';

const keycloakConfig = {
  url: 'https://keycloak.example.com/',
  realm: 'my-realm',
  clientId: 'my-frontend-app'
};

const keycloak = new Keycloak(keycloakConfig);

export async function initAuth() {
  try {
    const authenticated = await keycloak.init({
      onLoad: 'check-sso',
      pkceMethod: 'S256', // Always use PKCE for public frontend clients
      silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
      checkLoginIframe: false
    });

    if (authenticated) {
      console.log('User authenticated successfully');
      setupTokenRefresh();
    } else {
      console.log('User not authenticated');
    }

    return authenticated;
  } catch (error) {
    console.error('Failed to initialize Keycloak', error);
  }
}

// Automatic Token Refresh
function setupTokenRefresh() {
  setInterval(async () => {
    try {
      // Refresh token if it expires in less than 70 seconds
      const refreshed = await keycloak.updateToken(70);
      if (refreshed) {
        console.log('Token successfully refreshed');
      }
    } catch (error) {
      console.error('Failed to refresh token, redirecting to login', error);
      keycloak.login();
    }
  }, 30000);
}
```

### Attaching Bearer Token to HTTP Requests (Fetch / Axios)
```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.example.com'
});

api.interceptors.request.use(async (config) => {
  if (keycloak.token) {
    // Ensure token is fresh before sending request
    await keycloak.updateToken(30);
    config.headers.Authorization = `Bearer ${keycloak.token}`;
  }
  return config;
}, (error) => Promise.reject(error));
```

---

## 2. Node.js & Express Middleware (Server-Side Verification)

Using `openid-client` or `jose` for verifying Bearer tokens in Node.js backend services.

### Installation
```bash
npm install jose express
```

### Token Verification Middleware using JWKS (`jose`)
```javascript
const express = require('express');
const { createRemoteJWKSet, jwtVerify } = require('jose');

const app = express();

const KEYCLOAK_URL = 'https://keycloak.example.com';
const REALM = 'my-realm';

// Remote JWKS endpoint for public key discovery & automatic rotation
const JWKS = createRemoteJWKSet(
  new URL(`${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/certs`)
);

async function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or malformed Authorization header' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `${KEYCLOAK_URL}/realms/${REALM}`,
      algorithms: ['RS256']
    });

    req.user = payload;
    next();
  } catch (err) {
    console.error('JWT Verification failed:', err.message);
    return res.status(401).json({ error: 'Invalid or expired token', details: err.message });
  }
}

app.get('/api/protected', authenticateToken, (req, res) => {
  res.json({
    message: 'Access granted to protected endpoint',
    user: req.user.preferred_username,
    roles: req.user.realm_access?.roles || []
  });
});

app.listen(3000, () => console.log('API listening on port 3000'));
```
