---
name: keycloak
description: This Keycloak skill provides practical, reusable guidance for setting up, integrating, configuring, and automating Keycloak identity and access management in applications. It includes quick-start installation examples for Python and JavaScript, common integration patterns, and configuration guidance for authentication, SSO, OAuth2/OpenID Connect flows, and securing APIs. The skill also documents troubleshooting steps and failure modes (e.g., invalid API keys, network timeouts with retry/backoff remedies), production notes, a pre-deploy checklist (API keys, error handling, rate limiting), and links to official docs and GitHub. Use it to accelerate developer and DevOps tasks such as realm/client/user provisioning automation, runtime error diagnosis, and robust production deployments. Core advantages are reduced integration time, consolidated best practices, and actionable remediation steps for auth-related issues. Trigger this skill whenever working with Keycloak, OpenID Connect (OIDC), OAuth2 auth flows, securing APIs with Keycloak, setting up Keycloak realms/clients/users, or diagnosing authentication errors.
---

# Keycloak IAM Integration & Automation Guide

Comprehensive, production-ready guide for integrating, configuring, automating, and troubleshooting Keycloak Identity & Access Management (IAM) across application stacks.

## Key Resources & Documentation
- **Official Documentation**: [https://keycloak.com/docs](https://keycloak.com/docs) (also [https://www.keycloak.org/documentation](https://www.keycloak.org/documentation))
- **GitHub Repository**: [https://github.com/keycloak](https://github.com/keycloak)

---

## 1. Core Architecture & Concepts

Keycloak is an open-source Identity and Access Management solution supporting OAuth 2.0, OpenID Connect (OIDC 1.0), and SAML 2.0.

- **Realm**: An isolated management domain managing users, roles, groups, and clients. Use a dedicated custom realm for applications (avoid using the `master` realm for production application users).
- **Client**: Entities that can request Keycloak to authenticate a user or deliver tokens (e.g., Frontend SPAs, Confidential Web Apps, Backend APIs, Microservices).
- **Client Types**:
  - *Public Clients*: SPAs, Mobile Apps (cannot keep secrets confidential). Must use **Authorization Code + PKCE**.
  - *Confidential Clients*: Server-side Web Apps, Backend Services (can securely hold a `client_secret`).
  - *Bearer-Only / Service*: Backend APIs validating tokens without performing user login redirects directly.
- **Tokens**:
  - `access_token`: Short-lived JWT used to authorize requests against APIs.
  - `refresh_token`: Longer-lived token used to acquire new access tokens without re-authenticating.
  - `id_token`: OIDC token containing identity information about the authenticated user.

---

## 2. Quick-Start Integration Guide

Detailed code samples for Python and JavaScript can be found in the bundled reference files:
- Python integration details: [python-integration.md](file:///C:/Users/guilhermealves/.gemini/config/skills/keycloak/references/python-integration.md)
- JavaScript / TypeScript details: [javascript-integration.md](file:///C:/Users/guilhermealves/.gemini/config/skills/keycloak/references/javascript-integration.md)

### Quick Summary: Python (FastAPI / Requests)
```python
# Installation
# pip install python-keycloak PyJWT requests

from keycloak import KeycloakOpenID

keycloak_openid = KeycloakOpenID(
    server_url="https://keycloak.example.com/",
    client_id="my-api-client",
    realm_name="my-realm",
    client_secret_key="your-client-secret"  # For confidential clients
)

# Fetch Well-Known OpenID Configuration
config = keycloak_openid.well_known()

# Verify & Decode Access Token (JWT)
def verify_token(token_string):
    KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----\n" + keycloak_openid.public_key() + "\n-----END PUBLIC KEY-----"
    options = {"verify_signature": True, "verify_aud": True, "verify_exp": True}
    return keycloak_openid.decode_token(
        token_string,
        key=KEYCLOAK_PUBLIC_KEY,
        options=options,
        algorithms=["RS256"]
    )
```

### Quick Summary: JavaScript / TypeScript (Node.js & Frontend)
```javascript
// Browser / SPA Integration (keycloak-js)
// npm install keycloak-js
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: 'https://keycloak.example.com/',
  realm: 'my-realm',
  clientId: 'my-frontend-spa'
});

await keycloak.init({
  onLoad: 'check-sso',
  pkceMethod: 'S256',
  checkLoginIframe: false
});

if (keycloak.authenticated) {
  console.log("Access Token:", keycloak.token);
  // Attach token to HTTP headers
  // Authorization: Bearer ${keycloak.token}
} else {
  keycloak.login();
}
```

---

## 3. OAuth2 & OpenID Connect Flow Selection Matrix

| Flow / Grant Type | Target Client Type | Primary Use Case | Key Configuration |
|---|---|---|---|
| **Authorization Code with PKCE** | Public (SPA, Mobile, Desktop) | User login in browser/mobile | `Standard Flow Enabled` = ON, `PKCE Method` = S256 |
| **Client Credentials** | Confidential (Service-to-Service) | Microservice communication, background jobs | `Service Accounts Enabled` = ON, Client Secret required |
| **Resource Owner Password (ROPC)** | Legacy / Internal CLI | Direct username/password exchange | `Direct Access Grants` = ON *(Discouraged for new apps)* |
| **Token Introspection / JWKS** | Backend API | Verifying incoming JWT tokens | Validate signature against `certs` endpoint or local JWKS cache |

---

## 4. Automation & Provisioning (Realm/Client/User)

Automation reference guide: [automation-and-provisioning.md](file:///C:/Users/guilhermealves/.gemini/config/skills/keycloak/references/automation-and-provisioning.md)

- **Keycloak Admin REST API**: Manage realms, clients, users, roles, and client scopes programmatically.
- **Python `keycloak-admin`**:
  ```python
  from keycloak import KeycloakAdmin

  keycloak_admin = KeycloakAdmin(
      server_url="https://keycloak.example.com/",
      username="admin",
      password="admin-password",
      realm_name="master",
      verify=True
  )
  # Create a new user in custom realm
  keycloak_admin.realm_name = "my-realm"
  new_user_id = keycloak_admin.create_user({
      "email": "user@example.com",
      "username": "johndoe",
      "enabled": True,
      "firstName": "John",
      "lastName": "Doe"
  })
  ```
- **Terraform Keycloak Provider (`mrparkers/keycloak`)**: Recommended for Infrastructure as Code (IaC) to maintain declarative realms, client configurations, and roles.

---

## 5. Troubleshooting Steps & Failure Modes

Full troubleshooting guide: [troubleshooting-and-production.md](file:///C:/Users/guilhermealves/.gemini/config/skills/keycloak/references/troubleshooting-and-production.md)

### Common Failure Modes & Solutions

1. **`401 Unauthorized` / `invalid_client` / Invalid API Keys & Client Secrets**:
   - *Cause*: Mismatch in `client_secret` or requesting token for public client with secret enabled.
   - *Fix*: Check Keycloak Console -> Clients -> [Client ID] -> Credentials tab. Regenerate secret if needed.

2. **Network Timeouts & Connection Failures**:
   - *Cause*: Network partition, DNS resolution failure, or Keycloak startup latency.
   - *Remedy*: Implement exponential backoff retry with jitter (e.g. 3 retries with 1s, 2s, 4s delays), configure TCP keep-alive, and set request timeouts (e.g., 5-10s timeout per call).

3. **CORS Errors (`Origin not allowed`)**:
   - *Cause*: Frontend domain missing from Keycloak Client's `Web Origins`.
   - *Fix*: In Keycloak Admin Console, add application URL (e.g. `https://myapp.example.com` or `+` to allow Valid Redirect URIs) to **Web Origins**.

4. **`Invalid parameter: redirect_uri`**:
   - *Cause*: The `redirect_uri` sent in authorization request does not match exact patterns in **Valid Redirect URIs**.
   - *Fix*: Ensure exact URI string matching, including protocol (`https://`), trailing slashes, and port numbers.

5. **Token Expiration / Clock Skew**:
   - *Cause*: Server clock desynchronization between API server and Keycloak.
   - *Fix*: Enable NTP synchronization. Add a clock skew tolerance window (e.g. 30-60 seconds leeway) when validating `exp` and `nbf` claims in backend JWT validators.

---

## 6. Pre-Deploy Checklist & Production Notes

### Pre-Deploy Verification Checklist

- [ ] **Secrets & API Keys**: `client_secret` and admin credentials stored in environment variables / KeyVault / Secrets Manager (never committed in code).
- [ ] **SSL/TLS & HTTPS**: TLS enforced (`KC_HOSTNAME_STRICT_HTTPS=true`). HTTP to HTTPS redirect enabled.
- [ ] **Reverse Proxy Headers**: Keycloak configured with `KC_PROXY_HEADERS=xforwarded` (or `PROXY_ADDRESS_FORWARDING=true` in legacy) when behind Nginx/HAProxy/Traefik/Cloudflare.
- [ ] **Token Expiration Settings**: Access token lifespan tuned (e.g., 5-15 minutes). Refresh token revocation enabled.
- [ ] **Rate Limiting & Brute Force Protection**: Keycloak **Brute Force Detection** enabled in Realm Settings (Max Login Failures, Wait Increment). Reverse proxy rate-limiting active on `/realms/*/protocol/openid-connect/token`.
- [ ] **High Availability**: External database (PostgreSQL / MariaDB) configured with connection pool tuning. Infinispan clustering configured across multi-replica deployments.
- [ ] **Health Monitoring**: Readiness and Liveness probes configured (`GET /health/ready` and `GET /health/live`).
- [ ] **Logging & Auditing**: Admin and user audit events enabled in Realm Settings -> Events. Sensitive tokens and secrets masked in app logs.
