---
name: security-review
description: "Deep security and efficiency audit for code changes, PRs, or full repositories. Identifies OWASP Top 10 vulnerabilities, auth/authz bypasses, data leaks, concurrency race conditions, and performance/DoS bottlenecks with high confidence and actionable fixes."
---

# Security & Efficiency Code Review

Perform a deep, high-confidence security and efficiency audit on code changes, pull requests, or specific modules. This skill emphasizes identifying real, exploitable vulnerabilities and performance traps rather than noisy theoretical warnings.

---

## 🎯 Audit Scope & Principles

1. **High Signal-to-Noise**: Only report findings that have a plausible attack vector or tangible efficiency impact.
2. **Context-Aware Verification**: Before flagging an issue, check framework defenses, middleware, ORM behaviors, and sanitizers to eliminate false positives.
3. **Data Flow & Taint Analysis**: Trace untrusted inputs from sources (HTTP requests, message queues, external APIs, file uploads) to sinks (databases, shell executions, file systems, network calls).
4. **Efficiency & Resource Defense**: Identify performance traps that can lead to Denial of Service (DoS), connection pool exhaustion, memory leaks, or N+1 query cascades.

---

## 🔍 Core Audit Vectors

### 1. Injection & Input Handling
- **SQL / HQL / JPQL / NoSQL Injection**: Check for string concatenation or unparameterized queries.
- **Command Injection**: Check execution of OS commands (`Runtime.getRuntime().exec`, `ProcessBuilder`, `child_process`).
- **Path Traversal**: Validate file access, uploads, or downloads against arbitrary directory escapes (`../`).
- **SSRF (Server-Side Request Forgery)**: Validate outbound URLs against internal metadata services or internal IP ranges (`127.0.0.1`, `10.x`, `172.16.x`, `169.254.x`).
- **XXE & Insecure Deserialization**: Verify XML parsers have disabled external entities and object deserialization is strictly typed.

### 2. Authentication & Authorization (Broken Access Control)
- **IDOR / BOLA (Broken Object Level Authorization)**: Verify that records fetched by ID (e.g. `GET /api/orders/{id}`) validate ownership against the authenticated principal.
- **Privilege Escalation**: Check role enforcement (`@PreAuthorize`, `@RolesAllowed`, role checks) on sensitive operations.
- **Token & Session Hygiene**: Validate JWT expiration, signature verification, algorithm confusion protection, and proper secret handling.

### 3. Sensitive Data & Cryptography
- **Secret Hardcoding**: Flag API keys, private certificates, DB passwords, or tokens in source code.
- **Data Leakage in Logs**: Ensure PII, credit card numbers, passwords, and authorization headers are masked before logging.
- **Weak Cryptography**: Avoid deprecated algorithms (MD5, SHA1 for hashing passwords, DES, ECB mode). Ensure constant-time comparisons for HMAC/hashes to prevent timing attacks.

### 4. Concurrency & State Mutation
- **Race Conditions / TOCTOU (Time-of-Check to Time-of-Use)**: Verify atomic updates for inventory, balances, or state flags.
- **Thread Safety**: Check shared mutable state in singletons, Spring beans, or global handlers.

### 5. Efficiency & DoS Vulnerabilities
- **Unbounded Queries & Pagination**: Ensure endpoints querying collections enforce strict maximum `limit`/`size` to prevent out-of-memory errors.
- **N+1 Queries**: Identify database query loops within iterations or lazy-loading entity relationships.
- **Resource Leaks**: Verify streams, database connections, sockets, and file handles use `try-with-resources` / proper closing semantics.
- **ReDoS (Regular Expression Denial of Service)**: Audit complex regexes with nested quantifiers evaluated on untrusted inputs.

---

## 📋 Execution Workflow

### Step 1: Discover Scope
- Identify the target files or diff:
  - If a branch/commit is provided, inspect `git diff`.
  - If specific files are given, analyze their dependencies and usage.

### Step 2: Trace Data Flows & Defenses
- Map entry points (controllers, handlers, listeners).
- Follow variable flow through services and DAOs.
- Check active security filters (e.g., Spring Security filter chain, CORS configuration, rate limiters).

### Step 3: Classify Findings
For each finding, categorize by severity:
- 🔴 **CRITICAL**: Remotely exploitable vulnerability without authentication, or critical data breach risk.
- 🟠 **HIGH**: Exploitable with standard authentication (e.g. BOLA/IDOR, SQLi behind auth, privilege escalation).
- 🟡 **MEDIUM**: Resource leak, lack of rate limiting on sensitive endpoint, weak cryptographic setting, or severe N+1 performance bottleneck.
- 🔵 **LOW / DEFENSE-IN-DEPTH**: Missing security headers, verbose error messages, suboptimal query patterns.

### Step 4: Report Findings
Generate a structured report following this format:

```markdown
# 🛡️ Security & Efficiency Review Report

## Executive Summary
- **Overall Risk Rating**: [Critical / High / Medium / Low / Clean]
- **Key Highlights**: Short summary of primary risks or efficiency bottlenecks.

---

## 🚨 Detailed Findings

### [SEV-LEVEL] Finding Title
- **Location**: `path/to/file.ext:L123-L145`
- **Category**: [Injection / Access Control / Data Leak / Performance / Concurrency]
- **Vulnerability / Efficiency Risk**:
  Explain how this can be exploited or cause performance degradation.
- **Proof of Concept / Attack Vector**:
  Step-by-step trigger or scenario.
- **Remediation**:
  ```diff
  - vulnerable_code()
  + secure_and_efficient_code()
  ```

---

## ✅ Positive Security & Performance Patterns Observed
- List good practices detected in the codebase (e.g. parameterized queries, strict DTO validation).
```
