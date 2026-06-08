---
name: designing-secure-api-architecture
description: Comprehensive guide to designing secure API architectures covering authentication, authorization, input validation, rate limiting, CORS, error handling, API gateway patterns, OWASP API Security Top 10 (2023), GraphQL security, and webhook hardening.
domain: cybersecurity
subdomain: api-security
tags: [api-design, oauth2, openapi, rate-limiting, input-validation, cors, authentication, authorization]
version: "1.0"
author: deivithi
license: Apache-2.0
---
# Designing Secure API Architecture

## Overview
APIs are the primary attack surface for modern applications. A single misconfigured endpoint can expose millions of records, enable account takeover, or allow unauthorized actions. This skill provides a security-first approach to API design — covering authentication and authorization patterns, input validation, rate limiting, error handling, logging, and defense against the OWASP API Security Top 10. It includes practical guidance for REST APIs, GraphQL, webhooks, and API gateway architectures.

## Prerequisites
- Familiarity with HTTP protocol, REST conventions, and JSON
- Understanding of OAuth 2.0 / OpenID Connect concepts
- Experience with at least one API framework (Express, FastAPI, Spring Boot, etc.)
- Basic knowledge of TLS, certificates, and cryptographic primitives
- Awareness of the OWASP Top 10 (web application version)

## Core Concepts

### Security-First API Design Principles

| Principle | Description |
|-----------|-------------|
| **Defense in Depth** | Never rely on a single control. Layer authentication, authorization, validation, and monitoring |
| **Least Privilege** | Every API consumer receives only the minimum permissions needed for its function |
| **Fail Secure** | When a security control fails, deny access by default rather than granting it |
| **Zero Trust** | Authenticate and authorize every request regardless of network origin |
| **Minimize Attack Surface** | Expose only necessary endpoints. Disable introspection, debug routes, and unnecessary HTTP methods |
| **Secure by Default** | Default configurations must be restrictive. Security should not require opt-in |
| **Auditability** | Every security-relevant action must produce an audit trail |

## Authentication Patterns

### API Keys

**Use case:** Machine-to-machine communication, low-sensitivity read-only APIs, metering.

```
# Request with API key in header (preferred over query params)
GET /api/v1/data HTTP/1.1
Host: api.example.com
X-API-Key: sk_live_abc123def456
```

**Security considerations:**
| Practice | Rationale |
|----------|-----------|
| Transmit in headers only | Query params are logged in access logs, browser history, and proxies |
| Hash keys before storage | Treat API keys like passwords — store only bcrypt/SHA-256 hashes |
| Enforce rotation | Maximum lifetime of 90 days; support overlap period for migration |
| Scope keys | Bind each key to specific endpoints, methods, and IP ranges |
| Rate limit per key | Prevent abuse if a key is compromised |
| Never embed in client-side code | API keys in JavaScript bundles are immediately exposed |

### OAuth 2.1

OAuth 2.1 consolidates OAuth 2.0 best practices into a single specification, deprecating insecure flows.

**Recommended flows:**

| Flow | Use Case | Notes |
|------|----------|-------|
| Authorization Code + PKCE | Web apps, SPAs, mobile apps | **Default choice.** PKCE is mandatory for all clients |
| Client Credentials | Machine-to-machine (M2M) | Service accounts; no user context |
| Device Authorization | IoT, smart TVs, CLIs | For devices without browsers |

**Deprecated in OAuth 2.1:**
- Implicit flow (token in URL fragment — vulnerable to leakage)
- Resource Owner Password Credentials (ROPC) — direct credential handling

```python
# FastAPI OAuth 2.1 with PKCE enforcement example
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2AuthorizationCodeBearer

oauth2_scheme = OAuth2AuthorizationCodeBearer(
    authorizationUrl="https://auth.example.com/authorize",
    tokenUrl="https://auth.example.com/token",
    scopes={
        "read:data": "Read data",
        "write:data": "Write data",
    }
)

async def get_current_user(token: str = Depends(oauth2_scheme)):
    """Validate access token and extract user claims."""
    try:
        payload = jwt.decode(
            token,
            key=PUBLIC_KEY,
            algorithms=["RS256"],
            audience="https://api.example.com",
            issuer="https://auth.example.com"
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload
```

### OpenID Connect (OIDC)

OIDC adds an identity layer on top of OAuth 2.0, providing standardized user identity claims via ID Tokens.

**Critical validations for ID Tokens:**
1. Verify signature against the IdP's JWKS endpoint
2. Validate `iss` (issuer) matches expected IdP
3. Validate `aud` (audience) contains your client ID
4. Check `exp` (expiration) is in the future
5. Check `iat` (issued at) is reasonable
6. Validate `nonce` if one was sent in the auth request

### Mutual TLS (mTLS)

**Use case:** Zero-trust service mesh, high-security internal APIs, certificate-bound access tokens.

```nginx
# Nginx mTLS configuration
server {
    listen 443 ssl;

    ssl_certificate         /etc/ssl/server.crt;
    ssl_certificate_key     /etc/ssl/server.key;
    ssl_client_certificate  /etc/ssl/ca.crt;
    ssl_verify_client       on;
    ssl_verify_depth        2;

    # Extract client certificate CN for authorization
    set $client_cn $ssl_client_s_dn_cn;

    location /api/ {
        proxy_pass http://backend;
        proxy_set_header X-Client-CN $client_cn;
    }
}
```

### JWT Best Practices

| Practice | Rationale |
|----------|-----------|
| Use asymmetric signing (RS256, ES256) | Allows token verification without sharing the signing key |
| **Never** use `alg: none` | Disables signature verification entirely |
| Set short expiration (5-15 minutes) | Limits window of abuse for stolen tokens |
| Use `aud` claim | Prevents token reuse across services |
| Use `jti` claim for revocation | Unique token ID enables blocklisting |
| Don't store sensitive data in payload | JWTs are base64-encoded, not encrypted |
| Validate `typ` header | Prevent JWT confusion attacks (e.g., using a refresh token as an access token) |
| Pin expected algorithm on server | Reject tokens using unexpected algorithms |

```python
# Secure JWT validation (Python - PyJWT)
import jwt

def validate_token(token: str) -> dict:
    """Validate JWT with strict security settings."""
    return jwt.decode(
        token,
        key=get_public_key(),           # Fetch from JWKS
        algorithms=["RS256"],            # Pin expected algorithm
        audience="https://api.example.com",
        issuer="https://auth.example.com",
        options={
            "require": ["exp", "iss", "aud", "sub", "iat"],
            "verify_exp": True,
            "verify_iss": True,
            "verify_aud": True,
        }
    )
```

## Authorization

### Role-Based Access Control (RBAC)

```python
# RBAC middleware example
from enum import Enum
from functools import wraps

class Role(str, Enum):
    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"

ROLE_PERMISSIONS = {
    Role.ADMIN:  {"read", "write", "delete", "admin"},
    Role.EDITOR: {"read", "write"},
    Role.VIEWER: {"read"},
}

def require_permission(permission: str):
    """Decorator to enforce RBAC permission check."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, current_user=None, **kwargs):
            user_role = Role(current_user.get("role", "viewer"))
            if permission not in ROLE_PERMISSIONS.get(user_role, set()):
                raise HTTPException(status_code=403, detail="Insufficient permissions")
            return await func(*args, current_user=current_user, **kwargs)
        return wrapper
    return decorator

@app.get("/api/v1/users")
@require_permission("read")
async def list_users(current_user=Depends(get_current_user)):
    return await fetch_users()
```

### Attribute-Based Access Control (ABAC)

ABAC evaluates policies based on attributes of the subject, resource, action, and context.

```python
# ABAC policy evaluation example
def evaluate_abac_policy(subject: dict, resource: dict, action: str, context: dict) -> bool:
    """
    Evaluate ABAC policy.
    Subject: user attributes (role, department, clearance)
    Resource: object attributes (owner, classification, department)
    Action: requested operation
    Context: environmental (time, IP, device)
    """
    # Policy: Users can only edit resources in their own department
    if action == "edit":
        if subject["department"] != resource["department"]:
            return False

    # Policy: Confidential resources require elevated clearance
    if resource.get("classification") == "confidential":
        if subject.get("clearance_level", 0) < 3:
            return False

    # Policy: Write access only during business hours
    if action in ("create", "edit", "delete"):
        hour = context.get("request_hour", 0)
        if not (8 <= hour <= 18):
            return False

    return True
```

### Scope-Based Authorization (OAuth)

```python
# Scope enforcement for OAuth tokens
def require_scope(required_scope: str):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, current_user=None, **kwargs):
            token_scopes = current_user.get("scope", "").split()
            if required_scope not in token_scopes:
                raise HTTPException(
                    status_code=403,
                    detail=f"Token missing required scope: {required_scope}"
                )
            return await func(*args, current_user=current_user, **kwargs)
        return wrapper
    return decorator

@app.delete("/api/v1/records/{record_id}")
@require_scope("delete:records")
async def delete_record(record_id: str, current_user=Depends(get_current_user)):
    # Also verify resource-level ownership
    record = await get_record(record_id)
    if record["owner_id"] != current_user["sub"] and "admin" not in current_user.get("roles", []):
        raise HTTPException(status_code=403, detail="Cannot delete another user's record")
    await remove_record(record_id)
```

### Resource-Level Authorization

**Always enforce resource-level checks** — never rely solely on role or scope.

```python
# Resource-level authorization (preventing BOLA/IDOR)
async def get_resource_with_authz(resource_id: str, current_user: dict):
    """Fetch resource and verify the current user has access."""
    resource = await db.get(resource_id)
    if not resource:
        raise HTTPException(status_code=404)  # Don't reveal existence

    # Check ownership or explicit sharing
    if resource["owner_id"] != current_user["sub"]:
        if current_user["sub"] not in resource.get("shared_with", []):
            if "admin" not in current_user.get("roles", []):
                raise HTTPException(status_code=404)  # 404, not 403

    return resource
```

## Input Validation and Serialization

### JSON Schema Validation

```python
# Input validation with Pydantic (FastAPI)
from pydantic import BaseModel, Field, field_validator, EmailStr
from typing import Optional
import re

class CreateUserRequest(BaseModel):
    """Strictly validated user creation request."""
    name: str = Field(
        ...,
        min_length=1,
        max_length=100,
        pattern=r'^[\w\s\-\.]+$',   # Whitelist allowed characters
        description="User's display name"
    )
    email: EmailStr
    role: str = Field(
        default="viewer",
        pattern=r'^(admin|editor|viewer)$'
    )
    age: Optional[int] = Field(default=None, ge=13, le=150)

    @field_validator('name')
    @classmethod
    def sanitize_name(cls, v: str) -> str:
        """Prevent injection via name field."""
        if any(char in v for char in ['<', '>', '"', "'", '&', ';']):
            raise ValueError('Name contains prohibited characters')
        return v.strip()

    class Config:
        # Reject any extra fields not defined in the model
        extra = "forbid"
        # Strip whitespace from string fields
        str_strip_whitespace = True
```

### OpenAPI Validation

```yaml
# OpenAPI 3.1 schema with security constraints
openapi: "3.1.0"
paths:
  /api/v1/users:
    post:
      summary: Create a user
      security:
        - bearerAuth: [write:users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [name, email]
              additionalProperties: false   # Reject unknown fields
              properties:
                name:
                  type: string
                  minLength: 1
                  maxLength: 100
                  pattern: '^[\w\s\-\.]+$'
                email:
                  type: string
                  format: email
                  maxLength: 254
                role:
                  type: string
                  enum: [admin, editor, viewer]
                  default: viewer
```

### Input Validation Rules

| Rule | Implementation |
|------|---------------|
| Validate all input on the server | Never trust client-side validation alone |
| Use allowlists over blocklists | Define what IS allowed, not what isn't |
| Enforce type, length, range, pattern | Reject before processing |
| Reject unknown fields | Set `additionalProperties: false` in JSON Schema |
| Sanitize for the output context | HTML-encode for web, parameterize for SQL |
| Limit request body size | Configure max payload (e.g., 1MB) at the gateway/framework level |
| Validate Content-Type | Reject requests with unexpected Content-Type headers |
| Canonicalize before validation | Normalize Unicode, decode URL encoding before applying rules |

## Rate Limiting and Throttle Strategies

### Rate Limiting Approaches

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Fixed Window** | N requests per time window (e.g., 100/min) | Simple, easy to implement |
| **Sliding Window** | Weighted average of current and previous window | Smoother rate enforcement |
| **Token Bucket** | Tokens replenish at fixed rate; burst allowed up to bucket size | Best balance of burst tolerance and steady-state limiting |
| **Leaky Bucket** | Requests processed at fixed rate; excess queued or dropped | Smoothest output rate |
| **Concurrent Request Limiting** | Max N in-flight requests per client | Protects against slow-loris and resource exhaustion |

### Implementation Headers

```
# Standard rate limit response headers (IETF draft)
RateLimit-Limit: 100
RateLimit-Remaining: 42
RateLimit-Reset: 1672531200

# When rate limited, return 429 with Retry-After
HTTP/1.1 429 Too Many Requests
Retry-After: 30
Content-Type: application/json

{
  "error": "rate_limit_exceeded",
  "message": "Too many requests. Please retry after 30 seconds.",
  "retry_after": 30
}
```

### Tiered Rate Limits

```python
# Rate limiting configuration by tier
RATE_LIMITS = {
    "anonymous":    {"requests": 20,    "window": 60,  "burst": 5},
    "free":         {"requests": 100,   "window": 60,  "burst": 20},
    "pro":          {"requests": 1000,  "window": 60,  "burst": 100},
    "enterprise":   {"requests": 10000, "window": 60,  "burst": 1000},
}

# Rate limit by: API key, user ID, IP (fallback)
# Apply different limits for:
# - Authentication endpoints (stricter: 5/min for login)
# - Write endpoints (stricter than read)
# - Search/query endpoints (moderate)
# - Read endpoints (most permissive)
```

## CORS Configuration

### Secure CORS Defaults

```python
# FastAPI CORS configuration
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://app.example.com",
        "https://admin.example.com",
    ],  # NEVER use ["*"] in production
    allow_methods=["GET", "POST", "PUT", "DELETE"],  # Explicit methods only
    allow_headers=["Authorization", "Content-Type", "X-Request-ID"],
    allow_credentials=True,
    max_age=3600,  # Preflight cache duration
    expose_headers=["X-Request-ID", "RateLimit-Remaining"],
)
```

**CORS Security Rules:**

| Rule | Rationale |
|------|-----------|
| Never use `Access-Control-Allow-Origin: *` with credentials | Browsers block this combination, but misconfigurations in proxies can bypass it |
| Never reflect the `Origin` header back without validation | Equivalent to wildcard — allows any origin |
| Maintain an explicit allowlist | Only trusted origins should be permitted |
| Restrict `Access-Control-Allow-Methods` | Only allow methods actually needed |
| Restrict `Access-Control-Allow-Headers` | Only allow headers actually used |
| Set `Access-Control-Max-Age` | Reduce preflight request volume |

## Error Handling

### Structured Error Responses (No Data Leakage)

```python
# Secure error response schema
from enum import Enum

class ErrorCode(str, Enum):
    VALIDATION_ERROR = "validation_error"
    AUTHENTICATION_REQUIRED = "authentication_required"
    INSUFFICIENT_PERMISSIONS = "insufficient_permissions"
    RESOURCE_NOT_FOUND = "resource_not_found"
    RATE_LIMIT_EXCEEDED = "rate_limit_exceeded"
    INTERNAL_ERROR = "internal_error"

def create_error_response(
    status_code: int,
    error_code: ErrorCode,
    message: str,
    request_id: str,
    details: list = None
) -> dict:
    """Create a consistent, secure error response."""
    response = {
        "error": {
            "code": error_code.value,
            "message": message,
            "request_id": request_id,  # For support correlation
        }
    }
    if details and status_code == 422:  # Only include details for validation errors
        response["error"]["details"] = details
    return response

# Examples:
# 401: {"error": {"code": "authentication_required", "message": "Valid authentication is required", "request_id": "req_abc123"}}
# 403: {"error": {"code": "insufficient_permissions", "message": "You don't have access to this resource", "request_id": "req_abc123"}}
# 404: {"error": {"code": "resource_not_found", "message": "The requested resource was not found", "request_id": "req_abc123"}}
# 500: {"error": {"code": "internal_error", "message": "An unexpected error occurred", "request_id": "req_abc123"}}
```

**Error handling rules:**

| Rule | Description |
|------|-------------|
| Never expose stack traces | Internal errors return generic message + request ID |
| Never reveal database errors | SQL errors, table names, column names are internal |
| Never reveal technology stack | Don't expose framework names, versions, or server headers |
| Use 404 instead of 403 for authz | Prevents enumeration — don't reveal that a resource exists |
| Include request ID in every error | Enables log correlation without exposing internals |
| Use consistent error schema | Same structure for all error responses across the API |
| Log full details server-side | Correlate via request_id for debugging |

## Logging and Audit Trails

### Security-Relevant Events to Log

```python
# API audit logging
import structlog

logger = structlog.get_logger()

# Log structure for security events
def log_security_event(
    event_type: str,
    request_id: str,
    user_id: str = None,
    resource: str = None,
    action: str = None,
    outcome: str = None,  # "success" | "failure" | "denied"
    reason: str = None,
    ip_address: str = None,
    user_agent: str = None,
    metadata: dict = None,
):
    logger.info(
        "security_event",
        event_type=event_type,
        request_id=request_id,
        user_id=user_id,
        resource=resource,
        action=action,
        outcome=outcome,
        reason=reason,
        ip_address=ip_address,
        user_agent=user_agent,
        metadata=metadata or {},
    )

# Events that MUST be logged:
# - Authentication success/failure
# - Authorization denial
# - Token creation, refresh, revocation
# - Resource creation, modification, deletion
# - Admin actions (role changes, config changes)
# - Rate limit hits
# - Input validation failures (potential attack signals)
# - API key creation, rotation, revocation
```

**Logging security rules:**

| Rule | Rationale |
|------|-----------|
| Never log secrets, tokens, or passwords | Even in error contexts |
| Never log full request bodies with PII | Log content type and size instead |
| Mask sensitive fields | Show `card: ****1234`, not full number |
| Use structured logging (JSON) | Machine-parseable for SIEM ingestion |
| Include correlation IDs | Trace requests across services |
| Set retention policies | Balance forensics needs vs. data minimization |

## API Versioning Security Implications

| Strategy | Security Consideration |
|----------|----------------------|
| **URL path** (`/v1/`, `/v2/`) | Simplest; ensure old versions are decommissioned and don't silently bypass new security controls |
| **Header** (`Accept: application/vnd.api.v2+json`) | Harder to discover; ensure default version is the latest/most secure |
| **Query param** (`?version=2`) | Logged in access logs; avoid for security-sensitive APIs |

**Critical:** When deprecating API versions, ensure the old version receives security patches until fully retired. Never leave unpatched API versions running.

## OpenAPI/Swagger Security Annotations

```yaml
# Security scheme definitions
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: "OAuth 2.1 access token"

    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/authorize
          tokenUrl: https://auth.example.com/token
          scopes:
            read:users: Read user data
            write:users: Create or modify users
            delete:users: Delete users
            admin: Full administrative access

    apiKey:
      type: apiKey
      in: header
      name: X-API-Key

# Apply globally
security:
  - bearerAuth: []

# Override per endpoint
paths:
  /api/v1/admin/users:
    delete:
      security:
        - oauth2: [admin, delete:users]
      x-rate-limit: 10/minute
```

## API Gateway Security Patterns

### Gateway as Security Enforcement Point

```
┌─────────┐     ┌──────────────────┐     ┌──────────────┐
│  Client  │────▶│   API Gateway    │────▶│  Backend API │
│          │     │                  │     │              │
│          │     │ ✓ TLS termination│     │ (no public   │
│          │     │ ✓ Authentication │     │  exposure)   │
│          │     │ ✓ Rate limiting  │     │              │
│          │     │ ✓ Input size     │     │              │
│          │     │ ✓ IP allowlist   │     │              │
│          │     │ ✓ Request logging│     │              │
│          │     │ ✓ CORS           │     │              │
│          │     │ ✓ WAF rules      │     │              │
└─────────┘     └──────────────────┘     └──────────────┘
```

### Kong Gateway Security Plugins

```yaml
# Kong declarative configuration
_format_version: "3.0"
services:
  - name: my-api
    url: http://backend:8080
    routes:
      - name: api-route
        paths:
          - /api/v1
    plugins:
      - name: jwt
        config:
          claims_to_verify: [exp]
          key_claim_name: iss
      - name: rate-limiting
        config:
          minute: 100
          policy: redis
          redis_host: redis
      - name: cors
        config:
          origins: ["https://app.example.com"]
          methods: ["GET", "POST", "PUT", "DELETE"]
          headers: ["Authorization", "Content-Type"]
          credentials: true
          max_age: 3600
      - name: request-size-limiting
        config:
          allowed_payload_size: 1  # MB
      - name: ip-restriction
        config:
          allow: ["10.0.0.0/8"]   # Internal network only
      - name: bot-detection
        config: {}
```

### AWS API Gateway Security

```yaml
# AWS SAM template with security configuration
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  MyApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod
      Auth:
        DefaultAuthorizer: CognitoAuthorizer
        Authorizers:
          CognitoAuthorizer:
            UserPoolArn: !GetAtt UserPool.Arn
        ResourcePolicy:
          CustomStatements:
            - Effect: Allow
              Principal: "*"
              Action: execute-api:Invoke
              Resource: execute-api:/*
              Condition:
                IpAddress:
                  aws:SourceIp: ["203.0.113.0/24"]
      MethodSettings:
        - HttpMethod: "*"
          ResourcePath: "/*"
          ThrottlingBurstLimit: 100
          ThrottlingRateLimit: 50
          LoggingLevel: INFO
          DataTraceEnabled: false  # Don't log request/response bodies
```

## OWASP API Security Top 10 (2023)

### API1:2023 — Broken Object Level Authorization (BOLA)

**Description:** APIs expose endpoints that handle object identifiers (IDs). Attackers replace IDs to access other users' data.

**Prevention:**
```python
# ALWAYS verify ownership/access before returning data
@app.get("/api/v1/orders/{order_id}")
async def get_order(order_id: str, user = Depends(get_current_user)):
    order = await db.orders.find_one({"_id": order_id})
    if not order:
        raise HTTPException(status_code=404)
    # Authorization check — the critical line
    if order["user_id"] != user["sub"] and "admin" not in user.get("roles", []):
        raise HTTPException(status_code=404)  # 404, not 403
    return order
```

- Use UUIDs instead of sequential IDs
- Implement authorization checks in a centralized middleware
- Write automated tests that verify cross-user access is denied

### API2:2023 — Broken Authentication

**Description:** Weak authentication mechanisms allow attackers to compromise tokens, keys, or passwords.

**Prevention:**
- Enforce OAuth 2.1 with PKCE for all flows
- Implement account lockout after 5 failed attempts
- Use strong password policies and credential stuffing protection
- Rotate API keys regularly; revoke on suspected compromise
- Implement token binding to prevent stolen token reuse

### API3:2023 — Broken Object Property Level Authorization

**Description:** APIs expose object properties that users should not be able to read or modify (mass assignment).

**Prevention:**
```python
# Explicit response schema — never return raw database objects
class OrderResponse(BaseModel):
    id: str
    status: str
    total: float
    created_at: datetime
    # Fields like internal_notes, cost_price, admin_flags are EXCLUDED

# Explicit update schema — only allow modifiable fields
class OrderUpdateRequest(BaseModel):
    shipping_address: Optional[str] = None
    # Fields like status, total, user_id are NOT in this model
    class Config:
        extra = "forbid"  # Reject unknown fields
```

### API4:2023 — Unrestricted Resource Consumption

**Description:** APIs that don't limit resource consumption enable DoS, brute force, and cost exhaustion.

**Prevention:**
- Implement rate limiting at multiple levels (global, per-user, per-endpoint)
- Limit request payload size
- Limit query complexity (pagination max, batch size)
- Set execution timeouts for all operations
- Implement cost-based rate limiting for expensive operations (search, export)

### API5:2023 — Broken Function Level Authorization

**Description:** APIs fail to enforce role-based access on administrative functions.

**Prevention:**
```python
# Centralized function-level authorization
ENDPOINT_PERMISSIONS = {
    ("GET",    "/api/v1/users"):          ["admin", "manager"],
    ("POST",   "/api/v1/users"):          ["admin"],
    ("DELETE",  "/api/v1/users/{id}"):    ["admin"],
    ("POST",   "/api/v1/reports/export"): ["admin", "analyst"],
}

@app.middleware("http")
async def check_function_authorization(request, call_next):
    user = request.state.user
    route_key = (request.method, request.url.path)
    required_roles = ENDPOINT_PERMISSIONS.get(route_key)
    if required_roles and not any(r in user.get("roles", []) for r in required_roles):
        return JSONResponse(status_code=404, content={"error": "not_found"})
    return await call_next(request)
```

### API6:2023 — Unrestricted Access to Sensitive Business Flows

**Description:** APIs expose business flows (e.g., purchasing, posting) without protections against automated abuse.

**Prevention:**
- Implement CAPTCHA or proof-of-work for sensitive flows
- Add velocity checks (e.g., max 3 purchases per minute)
- Detect and block bot patterns (device fingerprinting, behavioral analysis)
- Implement step-up authentication for high-risk actions

### API7:2023 — Server Side Request Forgery (SSRF)

**Description:** APIs that fetch external resources based on user input can be exploited to access internal services.

**Prevention:**
```python
# SSRF prevention for user-supplied URLs
import ipaddress
from urllib.parse import urlparse

BLOCKED_NETWORKS = [
    ipaddress.ip_network("10.0.0.0/8"),
    ipaddress.ip_network("172.16.0.0/12"),
    ipaddress.ip_network("192.168.0.0/16"),
    ipaddress.ip_network("127.0.0.0/8"),
    ipaddress.ip_network("169.254.0.0/16"),  # Link-local / cloud metadata
    ipaddress.ip_network("::1/128"),
]

def validate_url(url: str) -> bool:
    parsed = urlparse(url)
    if parsed.scheme not in ("https",):  # Only allow HTTPS
        return False
    try:
        ip = ipaddress.ip_address(socket.gethostbyname(parsed.hostname))
        for network in BLOCKED_NETWORKS:
            if ip in network:
                return False
    except (socket.gaierror, ValueError):
        return False
    return True
```

### API8:2023 — Security Misconfiguration

**Description:** Default configurations, unnecessary features, verbose errors, and missing security headers.

**Prevention:**
- Disable debug mode, stack traces, and verbose errors in production
- Remove unnecessary HTTP methods (TRACE, OPTIONS if unused)
- Set security headers: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`
- Disable server version headers (`Server`, `X-Powered-By`)
- Harden CORS to specific origins
- Review and harden all default configurations

### API9:2023 — Improper Inventory Management

**Description:** Outdated, unpatched, or shadow API versions remain accessible.

**Prevention:**
- Maintain a machine-readable API inventory (OpenAPI specs in a catalog)
- Decommission deprecated API versions with a clear timeline
- Monitor for undocumented endpoints (shadow APIs)
- Use API gateways to enforce routing only to known endpoints
- Run periodic API discovery scans

### API10:2023 — Unsafe Consumption of APIs

**Description:** Developers trust data from third-party APIs without validation.

**Prevention:**
- Validate and sanitize all data received from external APIs
- Apply the same input validation to third-party responses as you do to user input
- Enforce timeouts and circuit breakers for external API calls
- Use allowlists for expected response schemas
- Verify TLS certificates when calling external APIs (no `verify=False`)

## GraphQL-Specific Security

### Query Depth Limiting

```python
# graphql-core depth limiting
from graphql import parse
from graphql.language.visitor import Visitor, visit

class DepthLimitVisitor(Visitor):
    def __init__(self, max_depth: int):
        self.max_depth = max_depth
        self.current_depth = 0

    def enter_field(self, node, *args):
        self.current_depth += 1
        if self.current_depth > self.max_depth:
            raise Exception(f"Query depth {self.current_depth} exceeds maximum {self.max_depth}")

    def leave_field(self, node, *args):
        self.current_depth -= 1

def validate_query_depth(query: str, max_depth: int = 5):
    document = parse(query)
    visitor = DepthLimitVisitor(max_depth)
    visit(document, visitor)
```

### Query Cost Analysis

```python
# Assign cost to fields and limit total query cost
FIELD_COSTS = {
    "users": 10,       # List queries are expensive
    "orders": 10,
    "analytics": 50,   # Aggregation queries
    "name": 1,         # Scalar fields are cheap
    "email": 1,
}

MAX_QUERY_COST = 1000

def calculate_query_cost(query_ast) -> int:
    """Calculate the cost of a GraphQL query based on field weights."""
    total_cost = 0
    # Walk the AST and sum field costs, multiplied by pagination limits
    # e.g., users(first: 100) { orders(first: 50) { ... } }
    # cost = 100 * (10 + 50 * 10) = 51,000 — would be rejected
    return total_cost
```

### Introspection Control

```python
# Disable introspection in production
from graphql import GraphQLSchema

# Option 1: Disable at schema level
schema = GraphQLSchema(
    query=QueryType,
    mutation=MutationType,
    # Remove __schema and __type from production
)

# Option 2: Middleware to block introspection queries
@app.middleware("http")
async def block_introspection(request, call_next):
    if request.url.path == "/graphql":
        body = await request.body()
        if b"__schema" in body or b"__type" in body:
            if not is_development_environment():
                return JSONResponse(
                    status_code=400,
                    content={"error": "Introspection is disabled"}
                )
    return await call_next(request)
```

### Field-Level Authorization

```python
# GraphQL field-level auth with directives
# Schema definition
"""
type User {
    id: ID!
    name: String!
    email: String! @auth(requires: OWNER)
    ssn: String @auth(requires: ADMIN)
    salary: Float @auth(requires: [ADMIN, HR])
}
"""

# Resolver with field-level authorization
def resolve_user_email(user, info):
    current_user = info.context["user"]
    if current_user["sub"] != user["id"] and "admin" not in current_user["roles"]:
        return None  # Or raise an error
    return user["email"]
```

### GraphQL Security Checklist

| Control | Implementation |
|---------|---------------|
| Depth limiting | Max depth 5-10 depending on schema |
| Cost analysis | Reject queries exceeding cost threshold |
| Disable introspection | Block `__schema` and `__type` in production |
| Persisted queries | Only allow pre-registered query hashes |
| Field-level auth | Enforce authorization per resolver |
| Batch limiting | Limit array size in batched queries |
| Timeout | Kill queries exceeding execution time limit |
| Alias limiting | Prevent alias-based DoS (e.g., 1000 aliases for the same field) |

## Webhook Security

### HMAC Signature Verification

```python
import hmac
import hashlib
import time

# Webhook sender: sign the payload
def sign_webhook(payload: bytes, secret: str, timestamp: int) -> str:
    """Generate HMAC-SHA256 signature for webhook payload."""
    message = f"{timestamp}.{payload.decode()}"
    signature = hmac.new(
        secret.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()
    return f"v1={signature}"

# Webhook receiver: verify the signature
def verify_webhook(
    payload: bytes,
    signature_header: str,
    timestamp_header: str,
    secret: str,
    tolerance_seconds: int = 300,  # 5-minute replay window
) -> bool:
    """Verify webhook HMAC signature with replay protection."""
    # 1. Check timestamp freshness (replay protection)
    try:
        timestamp = int(timestamp_header)
    except (ValueError, TypeError):
        return False

    if abs(time.time() - timestamp) > tolerance_seconds:
        return False  # Reject stale webhooks

    # 2. Compute expected signature
    message = f"{timestamp}.{payload.decode()}"
    expected = hmac.new(
        secret.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()
    expected_signature = f"v1={expected}"

    # 3. Constant-time comparison (prevent timing attacks)
    return hmac.compare_digest(signature_header, expected_signature)

# Webhook endpoint
@app.post("/webhooks/payment")
async def receive_webhook(request: Request):
    payload = await request.body()
    signature = request.headers.get("X-Webhook-Signature")
    timestamp = request.headers.get("X-Webhook-Timestamp")

    if not verify_webhook(payload, signature, timestamp, WEBHOOK_SECRET):
        raise HTTPException(status_code=401, detail="Invalid signature")

    # Process webhook idempotently
    event = json.loads(payload)
    await process_event_idempotently(event["id"], event)
    return {"status": "received"}
```

### Webhook Security Checklist

| Control | Description |
|---------|-------------|
| HMAC signature verification | Verify every webhook using a shared secret |
| Timestamp validation | Reject webhooks older than 5 minutes (replay protection) |
| Constant-time comparison | Use `hmac.compare_digest()` to prevent timing attacks |
| Idempotency | Process each webhook event ID only once |
| HTTPS only | Only accept webhooks over TLS |
| IP allowlisting | Restrict webhook sources to known IP ranges when possible |
| Retry handling | Return 2xx immediately; process asynchronously |
| Secret rotation | Support multiple active secrets during rotation periods |

## Implementation Steps

### Phase 1: Foundation (Weeks 1-4)
1. Define authentication strategy (OAuth 2.1 + API keys)
2. Implement TLS everywhere — no exceptions
3. Set up centralized API gateway with security plugins
4. Define and enforce input validation schemas (OpenAPI 3.1)
5. Implement structured error responses
6. Configure CORS with explicit allowlists

### Phase 2: Authorization and Rate Limiting (Weeks 5-8)
1. Implement RBAC/scope-based authorization
2. Add resource-level authorization checks to all endpoints
3. Deploy rate limiting at gateway and application layers
4. Implement request size limits and timeout controls
5. Set up API key management (issuance, rotation, revocation)

### Phase 3: Observability and Hardening (Weeks 9-12)
1. Deploy structured audit logging for all security events
2. Integrate with SIEM for security monitoring
3. Disable introspection, debug endpoints, and unnecessary features
4. Run automated security scans (OWASP ZAP, Burp Suite)
5. Implement webhook signing for all outbound events
6. Perform penetration testing against OWASP API Top 10

### Phase 4: Ongoing Operations (Continuous)
1. API inventory management — discover and document all APIs
2. Regular security testing (DAST, manual pen test)
3. Monitor for anomalous API usage patterns
4. Deprecate and decommission old API versions
5. Review and rotate secrets, keys, and certificates
6. Update dependency libraries and patch vulnerabilities

## Key Artifacts
- OpenAPI 3.1 specification with security annotations
- API gateway configuration (Kong, AWS, or equivalent)
- Authentication and authorization middleware/libraries
- Rate limiting configuration and tiering documentation
- Error response schema and error code registry
- Audit logging schema and SIEM integration configuration
- Webhook signing implementation and key management procedures
- OWASP API Top 10 compliance checklist with evidence

## Common Pitfalls
- Relying on API keys as the sole authentication mechanism for sensitive operations
- Checking authorization at the role level but not at the resource/object level (BOLA)
- Returning 403 instead of 404 for unauthorized resource access — enables enumeration
- Trusting client-side validation without server-side enforcement
- Exposing raw database errors or stack traces in API responses
- Implementing rate limiting only at the gateway, missing application-level abuse patterns
- Using wildcard CORS (`*`) with credentials
- Leaving GraphQL introspection enabled in production
- Not validating data received from third-party APIs and webhooks
- Logging access tokens, API keys, or credentials in plain text
- Failing to version APIs, leaving unpatched old versions accessible
- Implementing webhook receivers without HMAC verification

## References
- OWASP API Security Top 10 (2023): https://owasp.org/API-Security/
- OAuth 2.1 Draft Specification: https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-11
- OpenAPI Specification 3.1: https://spec.openapis.org/oas/v3.1.0
- NIST SP 800-204 — Security Strategies for Microservices-based Applications: https://csrc.nist.gov/publications/detail/sp/800-204/final
- NIST SP 800-204B — Attribute-based Access Control for Microservices: https://csrc.nist.gov/publications/detail/sp/800-204b/final
- RFC 6749 — OAuth 2.0 Authorization Framework: https://datatracker.ietf.org/doc/html/rfc6749
- RFC 7519 — JSON Web Token (JWT): https://datatracker.ietf.org/doc/html/rfc7519
- Kong Gateway Security Plugins: https://docs.konghq.com/hub/#security
- GraphQL Security Best Practices: https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html
- OWASP REST Security Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html
