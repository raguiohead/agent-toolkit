# Keycloak Troubleshooting & Production Hardening Guide

This document details failure modes, runtime error diagnosis, exponential backoff remedies, and production hardening recommendations for Keycloak.

## 1. Runtime Error Diagnosis & Failure Modes

### 1.1 Invalid API Keys / Client Secrets (`401 Unauthorized` / `invalid_client`)
- **Error Response**:
  ```json
  {
    "error": "unauthorized_client",
    "error_description": "Invalid client secret"
  }
  ```
- **Diagnostic Steps**:
  1. Confirm whether `client_secret` matches the client secret displayed under Keycloak Console -> Realm -> Clients -> [Client ID] -> Credentials.
  2. Verify that the client access type is `CONFIDENTIAL`. If set to `PUBLIC`, keycloak rejects client secrets.
  3. Ensure headers are correctly formatted: `Authorization: Basic <base64(client_id:client_secret)>` OR included as body parameter `client_secret=...`.

### 1.2 Network Timeouts & Resiliency Remedies
- **Symptom**: `ConnectionRefusedError`, `ReadTimeout`, `504 Gateway Timeout` during peak authentication loads or network hiccups.
- **Remedy Pattern (Exponential Backoff with Jitter in Python)**:
  ```python
  import time
  import random
  import requests
  from requests.exceptions import RequestException

  def call_keycloak_with_retry(url, payload, max_retries=4):
      base_delay = 1.0  # initial delay in seconds
      
      for attempt in range(max_retries):
          try:
              response = requests.post(url, data=payload, timeout=5.0)
              response.raise_for_status()
              return response.json()
          except (RequestException, requests.exceptions.HTTPError) as e:
              # Do not retry on client errors (4xx) except 429 Too Many Requests
              if isinstance(e, requests.exceptions.HTTPError) and e.response is not None:
                  if 400 <= e.response.status_code < 500 and e.response.status_code != 429:
                      raise e

              if attempt == max_retries - 1:
                  raise e
              
              # Calculate exponential backoff with full jitter
              sleep_time = (base_delay * (2 ** attempt)) + random.uniform(0, 0.5)
              print(f"Keycloak request failed (attempt {attempt + 1}/{max_retries}). Retrying in {sleep_time:.2f}s...")
              time.sleep(sleep_time)
  ```

### 1.3 CORS Errors (`Origin http://localhost:3000 is not allowed by Access-Control-Allow-Origin`)
- **Diagnostic Steps**:
  1. Open Keycloak Admin Console.
  2. Navigate to Clients -> [Your SPA Client ID].
  3. Set **Web Origins** to include `https://myapp.example.com` (or `+` to inherit all origins from Valid Redirect URIs).
  4. Ensure `Access-Control-Allow-Credentials` is enabled if cross-origin cookies or iframe SSO checks are required.

### 1.4 Invalid `redirect_uri` (`Invalid parameter: redirect_uri`)
- **Cause**: Exact string comparison failed between the `redirect_uri` parameter in authorization code request and the patterns listed in **Valid Redirect URIs**.
- **Fix**:
  - Trailing slashes matter (`https://app.com/callback` vs `https://app.com/callback/`).
  - Wildcards (`https://app.com/*`) are supported but should be restricted in production.
  - HTTP vs HTTPS mismatch.

### 1.5 Token Signature Failure & Key Rotation (`401 Invalid Token`)
- **Cause**: Keycloak rotated realm signing keys (RS256) and the backend API cached an outdated public key.
- **Fix**:
  - Use dynamic **JWKS URI fetching** (`/realms/{realm}/protocol/openid-connect/certs`) with dynamic key rotation instead of hardcoding static public keys.
  - Implement a 24-hour cache TTL on JWKS keys with fallback to re-query JWKS endpoint on verification failure.

---

## 2. Production Hardening & Pre-Deploy Checklist

### 2.1 Reverse Proxy Setup (Nginx / HAProxy / Traefik)
Keycloak must receive correct `X-Forwarded-For`, `X-Forwarded-Proto`, and `X-Forwarded-Host` headers to construct valid redirect URIs.

**Keycloak Environment Variables (Keycloak 20+)**:
```bash
KC_PROXY_HEADERS=xforwarded
KC_HOSTNAME_STRICT=true
KC_HOSTNAME=https://auth.example.com
```

**Nginx Configuration snippet**:
```nginx
server {
    listen 443 ssl http2;
    server_name auth.example.com;

    ssl_certificate /etc/letsencrypt/live/auth.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/auth.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

### 2.2 Rate Limiting & Brute Force Prevention
1. **Enable Realm Brute Force Protection**:
   - Go to Realm Settings -> Security Defenses -> Brute Force Detection.
   - Set **Max Login Failures** (e.g. 5 failures).
   - Set **Wait Increment** (e.g. 1 minute).
   - Set **Quick Login Check Milliseconds** (e.g. 1000ms).
2. **Reverse Proxy Rate Limiting**:
   - Limit requests to `/realms/*/protocol/openid-connect/token` to prevent credential stuffing attacks.

### 2.3 Health Monitoring & Probes
- **Liveness Probe**: `GET http://localhost:9000/health/live` (HTTP 200 OK)
- **Readiness Probe**: `GET http://localhost:9000/health/ready` (HTTP 200 OK when database and caches are connected)

### 2.4 Pre-Deploy Checklist Table

| Audit Area | Recommendation / Requirement | Status |
|---|---|---|
| **HTTPS Only** | Enforce HTTPS (`KC_HOSTNAME_STRICT_HTTPS=true`). Disable HTTP. | [ ] |
| **Secrets Management** | Store `client_secret` and database passwords in Secret Managers (AWS Secrets Manager / Vault / Env Vars). | [ ] |
| **Database Pool** | Configure production DB connection pool (e.g. PostgreSQL max pool 50-100). | [ ] |
| **Master Realm** | Disable user registration in `master` realm. Restrict admin user access. | [ ] |
| **Token Expiration** | Set Access Token lifespan to 5-15 mins; Refresh Token lifespan to 8-24 hours with revocation enabled. | [ ] |
| **Logging** | Set root log level to `INFO`. Disable verbose debug logging of headers containing tokens. | [ ] |
| **Audit Events** | Turn ON Realm Event Listening for `LOGIN`, `LOGIN_ERROR`, `REGISTER_ERROR`, and `CODE_TO_TOKEN_ERROR`. | [ ] |
