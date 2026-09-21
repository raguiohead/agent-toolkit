# Keycloak Automation & Provisioning Reference

This guide covers automating Keycloak realm setup, client provisioning, user management, and role assignments using the Keycloak Admin REST API, CLI (`kcadm.sh`), and Terraform.

## 1. Keycloak Admin REST API (Python)

### Installation
```bash
pip install python-keycloak
```

### Script: Automated Realm & Client Provisioning
```python
from keycloak import KeycloakAdmin

# Authenticate against 'master' realm using admin credentials
keycloak_admin = KeycloakAdmin(
    server_url="https://keycloak.example.com/",
    username="admin-user",
    password="admin-password",
    realm_name="master",
    verify=True
)

# 1. Create a New Realm
realm_payload = {
    "realm": "production-app",
    "enabled": True,
    "displayName": "Production Application Realm",
    "sslRequired": "external",
    "registrationAllowed": False,
    "rememberMe": True,
    "verifyEmail": True,
    "loginWithEmailAllowed": True
}
keycloak_admin.create_realm(payload=realm_payload)

# Switch context to new realm
keycloak_admin.realm_name = "production-app"

# 2. Provision a Public SPA Client (PKCE)
spa_client = {
    "clientId": "frontend-spa",
    "name": "Frontend Single Page App",
    "publicClient": True,
    "standardFlowEnabled": True,
    "implicitFlowEnabled": False,
    "directAccessGrantsEnabled": False,
    "redirectUris": ["https://myapp.example.com/*"],
    "webOrigins": ["https://myapp.example.com"],
    "attributes": {
        "pkce.code.challenge.method": "S256"
    }
}
keycloak_admin.create_client(payload=spa_client)

# 3. Provision a Microservice Backend Client (Service Account)
service_client = {
    "clientId": "inventory-service",
    "name": "Inventory Microservice",
    "publicClient": False,
    "bearerOnly": False,
    "serviceAccountsEnabled": True,
    "standardFlowEnabled": False,
    "secret": "super-secret-service-key-12345"
}
keycloak_admin.create_client(payload=service_client)

# 4. Create Realm Roles
keycloak_admin.create_realm_role(payload={"name": "app-admin", "description": "Administrator Role"})
keycloak_admin.create_realm_role(payload={"name": "app-user", "description": "Regular User Role"})

print("Realm, clients, and roles successfully provisioned!")
```

---

## 2. Infrastructure as Code: Terraform (`mrparkers/keycloak`)

Using Terraform ensures declarative, version-controlled provisioning.

```hcl
terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.keycloak_admin_user
  password  = var.keycloak_admin_password
  url       = "https://keycloak.example.com"
}

# Create Realm
resource "keycloak_realm" "realm" {
  realm   = "my-app-realm"
  enabled = true
  display_name = "My Application Realm"

  smtp_server {
    host = "smtp.example.com"
    port = 587
    from = "auth@example.com"
  }
}

# Public SPA Client
resource "keycloak_openid_client" "spa_client" {
  realm_id  = keycloak_realm.realm.id
  client_id = "my-spa-client"
  name      = "My SPA Client"
  enabled   = true

  access_type = "PUBLIC"
  standard_flow_enabled = true
  pkce_code_challenge_method = "S256"

  valid_redirect_uris = [
    "https://myapp.example.com/callback",
    "http://localhost:3000/callback"
  ]

  web_origins = [
    "https://myapp.example.com",
    "http://localhost:3000"
  ]
}

# Backend Service Account Client
resource "keycloak_openid_client" "backend_service" {
  realm_id  = keycloak_realm.realm.id
  client_id = "backend-service"
  name      = "Backend Service Account"
  enabled   = true

  access_type = "CONFIDENTIAL"
  service_accounts_enabled = true
  standard_flow_enabled    = false
}
```

---

## 3. CLI Automation (`kcadm.sh`)

Keycloak provides a built-in admin CLI script located inside the bin folder (`kcadm.sh` / `kcadm.bat`).

```bash
# Login as admin
/opt/keycloak/bin/kcadm.sh config credentials \
  --server https://keycloak.example.com \
  --realm master \
  --user admin \
  --password secretpassword

# Create Realm
/opt/keycloak/bin/kcadm.sh create realms -s realm=dev-realm -s enabled=true

# Create User
/opt/keycloak/bin/kcadm.sh create users -r dev-realm \
  -s username=testuser \
  -s enabled=true \
  -s email=testuser@example.com

# Set User Password
/opt/keycloak/bin/kcadm.sh set-password -r dev-realm \
  --username testuser \
  --new-password TempPass123! \
  --temporary=false
```
