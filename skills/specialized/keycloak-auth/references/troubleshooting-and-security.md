# Keycloak Troubleshooting & Security Hardening Guide

This document covers common issues, edge cases, error resolutions, and security hardening guidelines when working with Keycloak.

---

## 1. Troubleshooting Common Errors

### Symptom: `Invalid parameter: redirect_uri`
- **Cause**: The application redirect URL after login is not listed in the client's **Valid Redirect URIs** in Keycloak Admin Console.
- **Resolution**:
  1. Go to Keycloak Admin Console -> Clients -> Select Client.
  2. Under `Valid Redirect URIs`, add your frontend URI:
     - Development: `http://localhost:8080/*` or `http://localhost:3000/*`
     - Production: `https://app.yourdomain.com/*`
  3. Ensure exact protocol matching (`https://` vs `http://`).

---

### Symptom: CORS Error (`Access-Control-Allow-Origin`)
- **Cause**: Keycloak server blocks requests coming from an unauthorized origin domain, or backend REST API rejects preflight `OPTIONS` requests.
- **Resolution**:
  1. In Keycloak Admin Console -> Clients -> Select Client.
  2. Set `Web Origins` to `*` or specify explicit origins: `https://app.yourdomain.com`, `http://localhost:8080`.
  3. Ensure backend REST API CORS configuration allows `Authorization` header and `OPTIONS` HTTP method.

---

### Symptom: Silent SSO (`check-sso`) Iframe Failure
- **Cause**: Modern browsers (Chrome, Safari, Firefox) block third-party cookies and storage access inside background iframes, breaking silent SSO checks.
- **Resolution**:
  1. Add a `silentCheckSsoRedirectUri` static HTML file in your public folder:
     ```html
     <!-- public/silent-check-sso.html -->
     <!DOCTYPE html>
     <html>
       <body>
         <script>
           parent.postMessage(location.href, location.origin);
         </script>
       </body>
     </html>
     ```
  2. Pass option during Keycloak init:
     ```typescript
     keycloak.init({
       onLoad: 'check-sso',
       silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
     });
     ```
  3. If third-party cookie restrictions still block it, fallback to `onLoad: 'login-required'` or use a Backend-For-Frontend (BFF) pattern.

---

### Symptom: Infinite Token Renewal Loop or 401 Unauthorized Errors
- **Cause**: `updateToken(minValidity)` threshold is set too low (e.g. 5 seconds) or `keycloak.updateToken()` error promise is swallowed without forcing a login.
- **Resolution**:
  1. Increase `minValidity` to at least 60-70 seconds.
  2. Catch refresh errors and trigger `keycloak.login()`:
     ```typescript
     keycloak.updateToken(70).catch((err) => {
       console.error('Token refresh failed, redirecting to login', err);
       keycloak.login();
     });
     ```

---

### Symptom: Clock Skew Error (`Token is not active yet` or `Token expired`)
- **Cause**: Time mismatch between Keycloak server host machine and backend API server.
- **Resolution**:
  1. Synchronize system clock using NTP on server nodes (`timedatectl set-ntp true`).
  2. In Spring Boot or Node.js JWT verifier, allow a 30-60 second clock skew tolerance:
     ```java
     // Spring Security clock skew allowance
     NimbusJwtDecoder jwtDecoder = JwtDecoders.fromIssuerLocation(issuerUri);
     OAuth2TokenValidator<Jwt> defaultValidator = JwtValidators.createDefaultWithIssuer(issuerUri);
     // Set clock skew duration to 60 seconds
     jwtDecoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(defaultValidator));
     ```

---

## 2. Production Security Hardening Checklist

1. **Enforce PKCE (`S256`)**:
   - Verify Keycloak Client Settings: `PKCE Code Challenge Method` = `S256`.
   - Never use `Plain` PKCE method or Implicit Flow.

2. **Configure Short Access Token Lifetimes**:
   - Access tokens should have a short lifespan (5-15 minutes).
   - Refresh tokens should have controlled idle timeouts (30-60 minutes).
   - Configure token lifetimes in Keycloak Admin Console under `Realm Settings` -> `Tokens`.

3. **Strict Origin & Secret Hygiene**:
   - Never commit `client_secret` to source control. Use environment variables (`KEYCLOAK_CLIENT_SECRET`).
   - Remove `*` wildcard from `Valid Redirect URIs` and `Web Origins` in production environments.

4. **BFF (Backend for Frontend) Pattern for High Security**:
   - For enterprise applications requiring immunity to XSS token theft, implement a BFF server (e.g. Next.js server route or Express gateway).
   - The BFF handles Keycloak OAuth2 tokens server-side and exchanges them with the browser via `HttpOnly`, `SameSite=Strict`, `Secure` cookies.
