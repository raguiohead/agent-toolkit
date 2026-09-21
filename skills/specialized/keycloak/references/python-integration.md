# Python Keycloak Integration Reference

This document provides quick-start examples and production patterns for integrating Keycloak in Python applications (FastAPI, Flask, Django, and generic Python services).

## 1. Using `python-keycloak`

`python-keycloak` is the standard library for interacting with Keycloak OpenID Connect and Admin REST API.

### Installation
```bash
pip install python-keycloak PyJWT requests
```

### OIDC Client Initialization
```python
from keycloak import KeycloakOpenID

keycloak_openid = KeycloakOpenID(
    server_url="https://keycloak.example.com/",
    realm_name="my-realm",
    client_id="my-backend-client",
    client_secret_key="your-client-secret"
)
```

### 1.1 Client Credentials Grant (Service-to-Service)
```python
# Acquire access token using service account credentials
token_response = keycloak_openid.token(grant_type="client_credentials")

access_token = token_response["access_token"]
print(f"Acquired Bearer Token: {access_token[:15]}...")
```

### 1.2 Resource Owner Password Credentials (Direct Access Grant)
```python
# Authenticate user directly via username and password
token = keycloak_openid.token("username", "password")
access_token = token["access_token"]
refresh_token = token["refresh_token"]
```

### 1.3 Token Verification & Claims Extraction (FastAPI Middleware example)
```python
import jwt
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from keycloak import KeycloakOpenID

app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

KEYCLOAK_URL = "https://keycloak.example.com/"
REALM = "my-realm"
CLIENT_ID = "my-backend-client"

keycloak_openid = KeycloakOpenID(
    server_url=KEYCLOAK_URL,
    realm_name=REALM,
    client_id=CLIENT_ID
)

# Cache public key
KEYCLOAK_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----\n" + keycloak_openid.public_key() + "\n-----END PUBLIC KEY-----"

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        # Decode and verify JWT
        payload = keycloak_openid.decode_token(
            token,
            key=KEYCLOAK_PUBLIC_KEY,
            options={
                "verify_signature": True,
                "verify_aud": False,  # Set to True if audience mapping is configured
                "verify_exp": True
            },
            algorithms=["RS256"]
        )
        return payload
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )

@app.get("/api/protected")
async def protected_route(user: dict = Depends(get_current_user)):
    user_id = user.get("sub")
    username = user.get("preferred_username")
    roles = user.get("realm_access", {}).get("roles", [])
    return {
        "message": f"Hello {username}!",
        "user_id": user_id,
        "roles": roles
    }
```

### 1.4 Token Refreshing
```python
new_token = keycloak_openid.refresh_token(refresh_token)
new_access_token = new_token["access_token"]
```

### 1.5 User Logout / Token Revocation
```python
keycloak_openid.logout(refresh_token)
```
