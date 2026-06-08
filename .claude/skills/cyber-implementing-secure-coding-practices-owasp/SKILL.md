---
name: implementing-secure-coding-practices-owasp
description: Implement secure coding practices based on OWASP Secure Coding Practices Quick Reference Guide, OWASP Top 10, and CWE/SANS Top 25 to prevent common vulnerabilities in web applications
domain: cybersecurity
subdomain: application-security
tags: [owasp, secure-coding, cwe, sans-top-25, input-validation, authentication, authorization, session-management, xss-prevention, sql-injection-prevention]
version: "1.0"
author: deivithi
license: Apache-2.0
---

# Implementing Secure Coding Practices (OWASP)

## 1. Overview

Secure coding is the practice of writing software that is resistant to attack by design, rather than relying on perimeter defenses alone. The **shift-left philosophy** moves security from a post-deployment afterthought to an integral part of every development phase — requirements, design, implementation, testing, and deployment.

### Why Secure Coding Matters

- **80% of breaches** exploit application-layer vulnerabilities, not network or infrastructure flaws (Verizon DBIR).
- The cost of fixing a vulnerability **increases 30x** when found in production versus during development (NIST).
- Regulatory frameworks (GDPR, PCI DSS, LGPD, SOC 2) mandate secure development practices.
- Supply chain attacks (Log4Shell, SolarWinds) demonstrate that every dependency is an attack surface.

### Guiding Frameworks

| Framework | Purpose | Link |
|-----------|---------|------|
| OWASP Top 10 (2021) | Top web application risks | https://owasp.org/Top10/ |
| OWASP Secure Coding Practices | Quick reference checklist | https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/ |
| CWE/SANS Top 25 | Most dangerous software weaknesses | https://cwe.mitre.org/top25/ |
| OWASP ASVS | Application Security Verification Standard | https://owasp.org/www-project-application-security-verification-standard/ |
| OWASP Cheat Sheet Series | Practical prevention guides | https://cheatsheetseries.owasp.org/ |

### Core Principles

1. **Defense in Depth** — Multiple layers of security controls.
2. **Least Privilege** — Grant only the minimum access required.
3. **Fail Securely** — Errors must not expose sensitive data or grant access.
4. **Don't Trust Any Input** — All external data is untrusted until validated.
5. **Separation of Duties** — No single user or process should control all aspects.
6. **Keep Security Simple** — Complex designs breed vulnerabilities.
7. **Fix Security Issues Correctly** — Understand root cause, test the fix, review similar code.

---

## 2. Prerequisites

### IDE Plugins

| Plugin | IDE | Purpose |
|--------|-----|---------|
| SonarLint | VS Code, IntelliJ, Eclipse | Real-time SAST feedback |
| Semgrep | VS Code, IntelliJ | Pattern-based vulnerability detection |
| ESLint Security Plugin | VS Code | JavaScript/TypeScript security rules |
| Bandit (Python) | VS Code, PyCharm | Python security linter |
| SpotBugs + Find Security Bugs | IntelliJ, Eclipse | Java security analysis |
| Snyk | VS Code, IntelliJ | Dependency vulnerability scanning |
| GitLens + Gitleaks | VS Code | Secret detection in commits |

### SAST Tools

| Tool | Languages | Open Source |
|------|-----------|-------------|
| Semgrep | 30+ languages | Yes |
| SonarQube | 27+ languages | Community Edition free |
| CodeQL (GitHub) | 10+ languages | Free for public repos |
| Bandit | Python | Yes |
| Gosec | Go | Yes |
| Brakeman | Ruby on Rails | Yes |

### DAST Tools

| Tool | Type | Open Source |
|------|------|-------------|
| OWASP ZAP | Web app scanner | Yes |
| Nuclei | Template-based scanner | Yes |
| Burp Suite Community | Web proxy/scanner | Free edition |

### SCA (Software Composition Analysis)

| Tool | Purpose | Open Source |
|------|---------|-------------|
| OWASP Dependency-Check | Known CVE detection | Yes |
| npm audit / pip-audit | Package manager native | Yes |
| Trivy | Multi-target scanner | Yes |
| Grype | Container + filesystem | Yes |

---

## 3. OWASP Top 10 (2021)

### A01:2021 — Broken Access Control

**CWE:** CWE-200, CWE-284, CWE-285, CWE-352, CWE-639

Access control enforces that users cannot act outside their intended permissions. This moved from #5 to #1 — 94% of applications tested had some form of broken access control.

**Vulnerable Code (Node.js/Express):**

```javascript
// VULNERABLE: No authorization check — any authenticated user can access any profile
app.get('/api/users/:id/profile', authenticateToken, async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user); // IDOR: user can access any user's profile by changing the ID
});

// VULNERABLE: Relying on client-side role check
app.delete('/api/users/:id', authenticateToken, async (req, res) => {
  // No server-side role verification
  await User.findByIdAndDelete(req.params.id);
  res.json({ message: 'User deleted' });
});
```

**Secure Code:**

```javascript
// SECURE: Authorization check ensures users can only access their own profile
app.get('/api/users/:id/profile', authenticateToken, async (req, res) => {
  // Verify the authenticated user is requesting their own data
  if (req.user.id !== req.params.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Access denied' });
  }
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ error: 'Not found' });
  res.json(user);
});

// SECURE: Server-side role enforcement with middleware
const requireRole = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({ error: 'Insufficient permissions' });
  }
  next();
};

app.delete('/api/users/:id', authenticateToken, requireRole('admin'), async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  auditLog.info({ action: 'user_deleted', targetId: req.params.id, by: req.user.id });
  res.json({ message: 'User deleted' });
});
```

**Prevention Patterns:**
- Deny by default — every endpoint requires explicit authorization.
- Enforce ownership checks on every data access (IDOR prevention).
- Use server-side role/permission checks, never rely on client-side.
- Disable directory listing and ensure metadata files (.git, .env) are not accessible.
- Rate-limit APIs to reduce automated exploitation.
- Log and alert on access control failures.

---

### A02:2021 — Cryptographic Failures

**CWE:** CWE-259, CWE-327, CWE-328, CWE-330, CWE-331

Previously "Sensitive Data Exposure." Focuses on failures related to cryptography that lead to data exposure.

**Vulnerable Code (Python):**

```python
# VULNERABLE: MD5 for password hashing, hardcoded key, ECB mode
import hashlib
from Crypto.Cipher import AES

def hash_password(password):
    return hashlib.md5(password.encode()).hexdigest()  # MD5 is broken

def encrypt_data(data):
    key = "mysecretkey12345"  # Hardcoded key
    cipher = AES.new(key.encode(), AES.MODE_ECB)  # ECB mode is insecure
    return cipher.encrypt(data.ljust(16).encode())
```

**Secure Code:**

```python
# SECURE: Argon2 for passwords, AES-256-GCM for encryption, key from vault
import argon2
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

# Password hashing with Argon2id
ph = argon2.PasswordHasher(
    time_cost=3,
    memory_cost=65536,  # 64MB
    parallelism=4,
    hash_len=32,
    type=argon2.Type.ID  # Argon2id: resistant to side-channel and GPU attacks
)

def hash_password(password: str) -> str:
    return ph.hash(password)

def verify_password(stored_hash: str, password: str) -> bool:
    try:
        return ph.verify(stored_hash, password)
    except argon2.exceptions.VerifyMismatchError:
        return False

# Encryption with AES-256-GCM (authenticated encryption)
def encrypt_data(plaintext: bytes, key: bytes) -> bytes:
    """Key must be 32 bytes, loaded from a secrets manager (e.g., AWS KMS, HashiCorp Vault)."""
    nonce = os.urandom(12)  # 96-bit nonce, unique per encryption
    aesgcm = AESGCM(key)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    return nonce + ciphertext  # Prepend nonce for decryption

def decrypt_data(data: bytes, key: bytes) -> bytes:
    nonce, ciphertext = data[:12], data[12:]
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ciphertext, None)
```

**Prevention Patterns:**
- Classify data by sensitivity; apply encryption controls accordingly.
- Use TLS 1.2+ for all data in transit (disable TLS 1.0/1.1).
- Use AES-256-GCM or ChaCha20-Poly1305 for symmetric encryption.
- Use Argon2id, bcrypt, or scrypt for password hashing — never MD5/SHA1/SHA256.
- Generate keys with cryptographic randomness (`os.urandom`, `crypto.randomBytes`).
- Store keys in a secrets manager, never in source code.
- Rotate encryption keys on a schedule with key versioning.

---

### A03:2021 — Injection

**CWE:** CWE-79 (XSS), CWE-89 (SQLi), CWE-77 (Command Injection), CWE-917 (Expression Language Injection)

Injection occurs when untrusted data is sent to an interpreter as part of a command or query.

**Vulnerable Code (Java — SQL Injection):**

```java
// VULNERABLE: String concatenation in SQL query
public User getUser(String username) {
    String query = "SELECT * FROM users WHERE username = '" + username + "'";
    Statement stmt = connection.createStatement();
    ResultSet rs = stmt.executeQuery(query);  // Attacker input: ' OR '1'='1
    return mapUser(rs);
}
```

**Secure Code (Java — Parameterized Query):**

```java
// SECURE: Parameterized query with PreparedStatement
public User getUser(String username) {
    String query = "SELECT * FROM users WHERE username = ?";
    PreparedStatement pstmt = connection.prepareStatement(query);
    pstmt.setString(1, username);  // Parameter binding prevents injection
    ResultSet rs = pstmt.executeQuery();
    return mapUser(rs);
}

// SECURE: Using JPA/Hibernate named parameters
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    @Query("SELECT u FROM User u WHERE u.username = :username")
    Optional<User> findByUsername(@Param("username") String username);
}
```

**Vulnerable Code (Node.js — Command Injection):**

```javascript
// VULNERABLE: User input passed directly to shell command
app.get('/api/ping', (req, res) => {
  const host = req.query.host;
  exec(`ping -c 4 ${host}`, (error, stdout) => {  // host = "8.8.8.8; rm -rf /"
    res.send(stdout);
  });
});
```

**Secure Code (Node.js):**

```javascript
// SECURE: Input validation + execFile with argument array (no shell interpolation)
import { execFile } from 'child_process';
import { isIP } from 'net';

app.get('/api/ping', (req, res) => {
  const host = req.query.host;

  // Allowlist validation: only valid IP addresses
  if (!isIP(host)) {
    return res.status(400).json({ error: 'Invalid IP address' });
  }

  // execFile does NOT spawn a shell — arguments are passed directly
  execFile('ping', ['-c', '4', host], { timeout: 10000 }, (error, stdout) => {
    if (error) return res.status(500).json({ error: 'Ping failed' });
    res.send(stdout);
  });
});
```

**Prevention Patterns:**
- Use parameterized queries / prepared statements for ALL database access.
- Use ORM frameworks that handle escaping automatically.
- For shell commands, use `execFile` (not `exec`) and pass arguments as arrays.
- Validate all input against an allowlist of expected patterns.
- Apply context-appropriate output encoding (HTML, URL, JavaScript, CSS, LDAP).
- Use LIMIT in SQL queries to prevent mass data disclosure on injection.

---

### A04:2021 — Insecure Design

**CWE:** CWE-209, CWE-256, CWE-501, CWE-522

A new category focusing on design and architectural flaws. No amount of secure implementation fixes a flawed design.

**Example — Insecure Design (No Rate Limit on OTP):**

```python
# VULNERABLE DESIGN: No rate limiting, no lockout on OTP verification
@app.post("/verify-otp")
def verify_otp(phone: str, otp: str):
    stored_otp = redis.get(f"otp:{phone}")
    if otp == stored_otp:
        return {"status": "verified"}
    return {"status": "invalid"}
# Attacker can brute-force all 4-digit OTPs (10,000 attempts) in seconds
```

**Secure Design:**

```python
# SECURE DESIGN: Rate limiting, lockout, expiry, length, audit logging
from slowapi import Limiter
from slowapi.util import get_remote_address
import secrets

limiter = Limiter(key_func=get_remote_address)

def generate_otp() -> str:
    """Generate cryptographically secure 6-digit OTP."""
    return f"{secrets.randbelow(1000000):06d}"

def send_otp(phone: str):
    otp = generate_otp()
    redis.setex(f"otp:{phone}", 300, otp)         # Expires in 5 minutes
    redis.setex(f"otp_attempts:{phone}", 300, 0)    # Track attempts
    sms_service.send(phone, f"Your code: {otp}")

@app.post("/verify-otp")
@limiter.limit("5/minute")  # Rate limit per IP
def verify_otp(phone: str, otp: str):
    attempts_key = f"otp_attempts:{phone}"
    attempts = int(redis.get(attempts_key) or 0)

    if attempts >= 3:
        redis.delete(f"otp:{phone}")  # Invalidate OTP after 3 failures
        audit_log.warning(f"OTP lockout for {phone}")
        return {"status": "locked", "message": "Too many attempts. Request a new code."}

    stored_otp = redis.get(f"otp:{phone}")
    if not stored_otp:
        return {"status": "expired"}

    if not secrets.compare_digest(otp, stored_otp.decode()):
        redis.incr(attempts_key)
        return {"status": "invalid"}

    redis.delete(f"otp:{phone}")
    redis.delete(attempts_key)
    return {"status": "verified"}
```

**Prevention Patterns:**
- Use threat modeling (STRIDE, PASTA) during design phase.
- Establish secure design patterns library for the team.
- Integrate abuse case / misuse case testing in user stories.
- Apply rate limiting, lockout, and monitoring to all authentication flows.
- Design with the assumption that attackers know your system.

---

### A05:2021 — Security Misconfiguration

**CWE:** CWE-16, CWE-611 (XXE)

Includes missing security hardening, unnecessary features enabled, default accounts, overly permissive CORS, verbose error messages.

**Vulnerable Configuration (Express.js):**

```javascript
// VULNERABLE: Exposes stack traces, no security headers, permissive CORS
const app = express();

app.use(cors());  // Allows ALL origins
app.use(express.json({ limit: '50mb' }));  // Excessive body size

// Default error handler exposes internals
app.use((err, req, res, next) => {
  res.status(500).json({
    error: err.message,
    stack: err.stack,  // Exposes internal paths and dependencies
    query: req.query   // Reflects user input
  });
});
```

**Secure Configuration:**

```javascript
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';

const app = express();

// Security headers via Helmet
app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:", "https:"],
    connectSrc: ["'self'"],
    frameSrc: ["'none'"],
    objectSrc: ["'none'"],
    upgradeInsecureRequests: [],
  }
}));

// Restrictive CORS
app.use(cors({
  origin: ['https://app.example.com', 'https://admin.example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400,
}));

// Rate limiting
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
}));

// Reasonable body size
app.use(express.json({ limit: '1mb' }));

// Remove fingerprinting headers
app.disable('x-powered-by');

// Secure error handler — no internal details leaked
app.use((err, req, res, next) => {
  const errorId = crypto.randomUUID();
  logger.error({ errorId, error: err.message, stack: err.stack, path: req.path });
  res.status(500).json({
    error: 'An unexpected error occurred',
    errorId,  // Allows support team to correlate with logs
  });
});
```

**Prevention Patterns:**
- Automate hardening with infrastructure-as-code (Terraform, Ansible).
- Disable unused HTTP methods, directory listing, and admin consoles.
- Review cloud permissions (S3 bucket policies, IAM roles) regularly.
- Use security headers: CSP, HSTS, X-Content-Type-Options, X-Frame-Options.
- Remove default credentials before deployment.
- Regularly scan configurations with tools like ScoutSuite, Prowler, or CIS Benchmarks.

---

### A06:2021 — Vulnerable and Outdated Components

**CWE:** CWE-1104

Using components with known vulnerabilities. This includes libraries, frameworks, and other software modules.

**Prevention Patterns:**
- Maintain a Software Bill of Materials (SBOM) for every project.
- Run SCA scans in CI/CD: `npm audit`, `pip-audit`, `trivy fs .`, `grype .`.
- Subscribe to security advisories (GitHub Dependabot, Snyk alerts).
- Pin dependency versions with lockfiles and verify integrity hashes.
- Remove unused dependencies regularly (`depcheck`, `pip-extra-reqs`).
- Establish a patching SLA: Critical CVEs < 48h, High < 7 days, Medium < 30 days.

---

### A07:2021 — Identification and Authentication Failures

**CWE:** CWE-287, CWE-384, CWE-798

Confirmation of identity, authentication, and session management are critical. Weaknesses allow attackers to impersonate users.

See Section 5 (Authentication & Session Management) for detailed code examples and patterns.

---

### A08:2021 — Software and Data Integrity Failures

**CWE:** CWE-502 (Deserialization), CWE-829

Failures related to code and infrastructure that does not protect against integrity violations — insecure deserialization, untrusted CI/CD pipelines, auto-updates without signature verification.

**Vulnerable Code (Python — Insecure Deserialization):**

```python
# VULNERABLE: pickle can execute arbitrary code during deserialization
import pickle

def load_session(data: bytes):
    return pickle.loads(data)  # Attacker sends crafted pickle payload = RCE
```

**Secure Code:**

```python
# SECURE: Use JSON for data interchange; validate schema
import json
from pydantic import BaseModel, validator

class SessionData(BaseModel):
    user_id: str
    role: str
    expires_at: int

    @validator('role')
    def validate_role(cls, v):
        allowed = {'user', 'admin', 'moderator'}
        if v not in allowed:
            raise ValueError(f'Invalid role: {v}')
        return v

def load_session(data: str) -> SessionData:
    parsed = json.loads(data)  # JSON cannot execute code
    return SessionData(**parsed)  # Pydantic validates schema + types
```

**Prevention Patterns:**
- Never use `pickle`, `Marshal`, `ObjectInputStream` for untrusted data.
- Use JSON/Protobuf with strict schema validation.
- Verify digital signatures on software updates and dependencies.
- Ensure CI/CD pipelines have integrity controls (signed commits, protected branches).
- Implement Subresource Integrity (SRI) for CDN-hosted scripts.

---

### A09:2021 — Security Logging and Monitoring Failures

**CWE:** CWE-117, CWE-223, CWE-532, CWE-778

Without logging and monitoring, breaches cannot be detected. Average time to detect a breach is **287 days** (IBM Cost of a Data Breach 2023).

See Section 9 (Error Handling & Logging) for detailed implementation.

---

### A10:2021 — Server-Side Request Forgery (SSRF)

**CWE:** CWE-918

SSRF occurs when a web application fetches a remote resource without validating the user-supplied URL.

**Vulnerable Code (Python):**

```python
# VULNERABLE: Fetches any URL the user provides — can access internal services
@app.get("/api/fetch-url")
def fetch_url(url: str):
    response = requests.get(url)  # url = "http://169.254.169.254/latest/meta-data/"
    return response.text           # Leaks AWS instance metadata (IAM credentials)
```

**Secure Code:**

```python
import ipaddress
from urllib.parse import urlparse
import socket

ALLOWED_SCHEMES = {'https'}
BLOCKED_NETWORKS = [
    ipaddress.ip_network('10.0.0.0/8'),
    ipaddress.ip_network('172.16.0.0/12'),
    ipaddress.ip_network('192.168.0.0/16'),
    ipaddress.ip_network('169.254.0.0/16'),   # Link-local (AWS metadata)
    ipaddress.ip_network('127.0.0.0/8'),       # Loopback
    ipaddress.ip_network('0.0.0.0/8'),
    ipaddress.ip_network('::1/128'),           # IPv6 loopback
    ipaddress.ip_network('fc00::/7'),          # IPv6 private
]

def is_safe_url(url: str) -> bool:
    """Validate URL is safe to fetch — no internal/private IPs."""
    parsed = urlparse(url)

    if parsed.scheme not in ALLOWED_SCHEMES:
        return False

    if not parsed.hostname:
        return False

    # Resolve DNS to catch rebinding attacks
    try:
        resolved_ip = socket.getaddrinfo(parsed.hostname, None)[0][4][0]
        ip = ipaddress.ip_address(resolved_ip)
    except (socket.gaierror, ValueError):
        return False

    for network in BLOCKED_NETWORKS:
        if ip in network:
            return False

    return True

@app.get("/api/fetch-url")
def fetch_url(url: str):
    if not is_safe_url(url):
        return {"error": "URL not allowed"}, 400

    response = requests.get(url, timeout=5, allow_redirects=False)
    return response.text
```

**Prevention Patterns:**
- Validate and sanitize all user-supplied URLs.
- Block requests to private/internal IP ranges at the application layer.
- Use allowlists for permitted domains when possible.
- Disable HTTP redirects or re-validate after each redirect.
- Use network-level controls (firewall egress rules) as defense in depth.
- On AWS, use IMDSv2 (require token-based metadata access).

---

## 4. Input Validation

Input validation is the first line of defense. All data from external sources — users, APIs, files, databases, environment variables — must be treated as untrusted.

### Strategy: Allowlist Over Denylist

```javascript
// WRONG: Denylist approach — easy to bypass
function sanitizeInput(input) {
  return input.replace(/<script>/gi, '');  // Attacker uses <ScRiPt> or <script >
}

// RIGHT: Allowlist approach — only permit known-good patterns
function validateUsername(input) {
  const pattern = /^[a-zA-Z0-9_]{3,30}$/;
  if (!pattern.test(input)) {
    throw new ValidationError('Username must be 3-30 alphanumeric characters or underscores');
  }
  return input;
}
```

### Comprehensive Validation Library (Node.js with Zod)

```typescript
import { z } from 'zod';

// Define strict schemas for all API inputs
const CreateUserSchema = z.object({
  username: z.string()
    .min(3).max(30)
    .regex(/^[a-zA-Z0-9_]+$/, 'Alphanumeric and underscores only'),
  email: z.string()
    .email()
    .max(254)
    .transform(v => v.toLowerCase().trim()),
  password: z.string()
    .min(12, 'Minimum 12 characters')
    .max(128)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/[0-9]/, 'Must contain digit')
    .regex(/[^A-Za-z0-9]/, 'Must contain special character'),
  age: z.number()
    .int()
    .min(13).max(150)
    .optional(),
  role: z.enum(['user', 'moderator']),  // Allowlist of valid roles
});

// Usage in Express route
app.post('/api/users', async (req, res) => {
  const result = CreateUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({
      error: 'Validation failed',
      details: result.error.flatten(),
    });
  }
  const validatedData = result.data;  // Type-safe, validated data
  // ... proceed with creation
});
```

### Parameterized Queries (Multi-Language)

```python
# Python (SQLAlchemy)
from sqlalchemy import text

result = db.execute(
    text("SELECT * FROM users WHERE email = :email AND status = :status"),
    {"email": user_email, "status": "active"}
)
```

```java
// Java (JDBC PreparedStatement)
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM users WHERE email = ? AND status = ?"
);
ps.setString(1, userEmail);
ps.setString(2, "active");
ResultSet rs = ps.executeQuery();
```

```go
// Go (database/sql)
row := db.QueryRow(
    "SELECT id, name FROM users WHERE email = $1 AND status = $2",
    userEmail, "active",
)
```

### File Upload Validation

```python
import magic  # python-magic library
from pathlib import Path

ALLOWED_MIME_TYPES = {'image/jpeg', 'image/png', 'image/webp', 'application/pdf'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB

def validate_upload(file_data: bytes, filename: str) -> bool:
    # 1. Check file size
    if len(file_data) > MAX_FILE_SIZE:
        raise ValueError("File too large")

    # 2. Validate MIME type from content (not extension)
    mime = magic.from_buffer(file_data[:2048], mime=True)
    if mime not in ALLOWED_MIME_TYPES:
        raise ValueError(f"File type {mime} not allowed")

    # 3. Validate extension matches content type
    ext = Path(filename).suffix.lower()
    expected_exts = {
        'image/jpeg': {'.jpg', '.jpeg'},
        'image/png': {'.png'},
        'image/webp': {'.webp'},
        'application/pdf': {'.pdf'},
    }
    if ext not in expected_exts.get(mime, set()):
        raise ValueError("Extension does not match content type")

    # 4. Sanitize filename — remove path traversal
    safe_name = Path(filename).name  # Strip directory components
    safe_name = re.sub(r'[^\w.\-]', '_', safe_name)  # Remove special chars

    return True
```

---

## 5. Authentication & Session Management

### Secure Password Storage

```python
# RECOMMENDED: Argon2id (winner of Password Hashing Competition)
import argon2

hasher = argon2.PasswordHasher(
    time_cost=3,        # Number of iterations
    memory_cost=65536,  # 64 MB
    parallelism=4,      # Number of threads
    hash_len=32,
    type=argon2.Type.ID
)

# Hash on registration
hashed = hasher.hash(password)
# Verify on login
try:
    hasher.verify(stored_hash, provided_password)
    # Check if rehash needed (params changed)
    if hasher.check_needs_rehash(stored_hash):
        new_hash = hasher.hash(provided_password)
        update_stored_hash(user_id, new_hash)
except argon2.exceptions.VerifyMismatchError:
    raise AuthenticationError("Invalid credentials")
```

```javascript
// ALTERNATIVE: bcrypt (widely supported, battle-tested)
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;  // Minimum 10, recommended 12+

async function hashPassword(password) {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);  // Constant-time comparison built-in
}
```

### Password Policy Enforcement

```python
import re
from zxcvbn import zxcvbn  # Realistic password strength estimation

def validate_password(password: str, user_context: dict) -> dict:
    errors = []

    if len(password) < 12:
        errors.append("Minimum 12 characters required")
    if len(password) > 128:
        errors.append("Maximum 128 characters")

    # Check against breached passwords (k-anonymity model)
    if is_pwned_password(password):
        errors.append("This password has appeared in a data breach")

    # Context-specific checks: reject username/email in password
    lower_pw = password.lower()
    if user_context.get('username', '').lower() in lower_pw:
        errors.append("Password must not contain your username")
    if user_context.get('email', '').split('@')[0].lower() in lower_pw:
        errors.append("Password must not contain your email")

    # Strength estimation
    result = zxcvbn(password)
    if result['score'] < 3:  # 0-4 scale
        errors.append(f"Password is too weak: {result['feedback']['warning']}")

    return {"valid": len(errors) == 0, "errors": errors}
```

### Multi-Factor Authentication (TOTP)

```python
import pyotp
import qrcode

def setup_mfa(user_id: str) -> dict:
    """Generate TOTP secret and provisioning URI."""
    secret = pyotp.random_base32()
    totp = pyotp.TOTP(secret)
    uri = totp.provisioning_uri(
        name=user_email,
        issuer_name="MyApp"
    )
    # Store encrypted secret — DO NOT store in plaintext
    store_encrypted_mfa_secret(user_id, secret)
    return {"secret": secret, "qr_uri": uri}

def verify_mfa(user_id: str, token: str) -> bool:
    """Verify TOTP token with +-1 time step tolerance."""
    secret = get_encrypted_mfa_secret(user_id)
    totp = pyotp.TOTP(secret)
    return totp.verify(token, valid_window=1)
```

### JWT Best Practices

```javascript
import jwt from 'jsonwebtoken';

// SECURE JWT configuration
const JWT_CONFIG = {
  accessTokenSecret: process.env.JWT_ACCESS_SECRET,   // 256-bit minimum, from secrets manager
  refreshTokenSecret: process.env.JWT_REFRESH_SECRET,
  accessTokenExpiry: '15m',      // Short-lived access tokens
  refreshTokenExpiry: '7d',      // Longer refresh tokens
  algorithm: 'HS256',            // Or RS256 for asymmetric
  issuer: 'myapp.example.com',
  audience: 'myapp-api',
};

function generateTokenPair(user) {
  const payload = {
    sub: user.id,           // Subject — user identifier
    role: user.role,
    // DO NOT include sensitive data (email, name) in JWT payload
  };

  const accessToken = jwt.sign(payload, JWT_CONFIG.accessTokenSecret, {
    expiresIn: JWT_CONFIG.accessTokenExpiry,
    algorithm: JWT_CONFIG.algorithm,
    issuer: JWT_CONFIG.issuer,
    audience: JWT_CONFIG.audience,
  });

  const refreshToken = jwt.sign(
    { sub: user.id, type: 'refresh' },
    JWT_CONFIG.refreshTokenSecret,
    { expiresIn: JWT_CONFIG.refreshTokenExpiry, algorithm: JWT_CONFIG.algorithm }
  );

  return { accessToken, refreshToken };
}

function verifyAccessToken(token) {
  try {
    return jwt.verify(token, JWT_CONFIG.accessTokenSecret, {
      algorithms: [JWT_CONFIG.algorithm],  // CRITICAL: Restrict algorithms to prevent alg:none attack
      issuer: JWT_CONFIG.issuer,
      audience: JWT_CONFIG.audience,
    });
  } catch (err) {
    throw new AuthenticationError('Invalid or expired token');
  }
}
```

### Session Security Checklist

- Generate session IDs with at least 128 bits of entropy (`crypto.randomBytes(32)`).
- Regenerate session ID after authentication (prevent session fixation).
- Set cookie flags: `Secure`, `HttpOnly`, `SameSite=Strict`, `Path=/`.
- Implement absolute timeout (e.g., 12h) and idle timeout (e.g., 30min).
- Store sessions server-side (Redis/DB) — not in the JWT alone.
- Implement token revocation for logout and password change.

---

## 6. Authorization

### Role-Based Access Control (RBAC)

```typescript
// Define permissions per role
const PERMISSIONS = {
  admin:     ['users:read', 'users:write', 'users:delete', 'reports:read', 'settings:write'],
  manager:   ['users:read', 'users:write', 'reports:read'],
  analyst:   ['reports:read'],
  user:      ['users:read:own'],  // Can only read own data
} as const;

type Role = keyof typeof PERMISSIONS;
type Permission = typeof PERMISSIONS[Role][number];

function hasPermission(userRole: Role, requiredPermission: Permission): boolean {
  return PERMISSIONS[userRole]?.includes(requiredPermission) ?? false;
}

// Express middleware
function authorize(...requiredPermissions: Permission[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const userRole = req.user?.role as Role;

    const hasAll = requiredPermissions.every(perm => hasPermission(userRole, perm));
    if (!hasAll) {
      auditLog.warn({
        event: 'authorization_denied',
        userId: req.user?.id,
        role: userRole,
        requiredPermissions,
        path: req.path,
        ip: req.ip,
      });
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
}

// Usage
app.delete('/api/users/:id', authenticate, authorize('users:delete'), deleteUserHandler);
app.get('/api/reports', authenticate, authorize('reports:read'), getReportsHandler);
```

### Attribute-Based Access Control (ABAC)

```python
from dataclasses import dataclass
from datetime import datetime, time

@dataclass
class AccessContext:
    user_id: str
    user_role: str
    user_department: str
    resource_owner_id: str
    resource_classification: str  # 'public', 'internal', 'confidential', 'restricted'
    request_time: datetime
    source_ip: str

def evaluate_access(ctx: AccessContext) -> bool:
    """ABAC policy engine — evaluates multiple attributes."""

    # Rule 1: Users can always access their own resources
    if ctx.user_id == ctx.resource_owner_id:
        return True

    # Rule 2: Only admins can access restricted data
    if ctx.resource_classification == 'restricted' and ctx.user_role != 'admin':
        return False

    # Rule 3: Confidential data requires same department
    if ctx.resource_classification == 'confidential':
        if ctx.user_department != get_resource_department(ctx.resource_owner_id):
            return False

    # Rule 4: No access to sensitive data outside business hours (optional)
    if ctx.resource_classification in ('confidential', 'restricted'):
        hour = ctx.request_time.hour
        if hour < 6 or hour > 22:
            audit_log.warning(f"Off-hours access attempt by {ctx.user_id}")
            return False

    return True
```

### Broken Access Control Prevention Checklist

1. Deny access by default — explicitly grant, never implicitly allow.
2. Implement access control centrally and reuse across the application.
3. Enforce record ownership on every data access (prevent IDOR).
4. Disable CORS for endpoints that don't need cross-origin access.
5. Enforce authorization on every request, including internal API calls.
6. Use UUIDs instead of sequential IDs for resource identifiers.
7. Log all access control failures and alert on anomalies.
8. Perform authorization checks on the server, never only on the client.

---

## 7. Output Encoding

### XSS Prevention

```javascript
// Template engines with auto-escaping (EJS, Handlebars, Nunjucks)
// Always use the escaping syntax, never raw output

// EJS
// VULNERABLE: <%- userInput %>   (raw, unescaped)
// SECURE:    <%= userInput %>    (HTML-escaped)

// React: JSX auto-escapes by default
// VULNERABLE:
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // Never use with untrusted data

// SECURE:
<div>{userInput}</div>  // React escapes automatically
```

### Context-Aware Encoding

```javascript
import { encode } from 'he';  // HTML entity encoder
import createDOMPurify from 'dompurify';
import { JSDOM } from 'jsdom';

const window = new JSDOM('').window;
const DOMPurify = createDOMPurify(window);

// HTML context — encode HTML entities
function encodeForHTML(input) {
  return encode(input);
  // <script>alert(1)</script>  →  &lt;script&gt;alert(1)&lt;/script&gt;
}

// HTML attribute context
function encodeForAttribute(input) {
  return input.replace(/[&<>"'`=\/]/g, (char) => `&#${char.charCodeAt(0)};`);
}

// JavaScript string context
function encodeForJS(input) {
  return JSON.stringify(input);
  // Wraps in quotes and escapes special characters
}

// URL parameter context
function encodeForURL(input) {
  return encodeURIComponent(input);
}

// Rich text (allow safe HTML subset)
function sanitizeRichText(html) {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: ['href', 'title'],
    ALLOW_DATA_ATTR: false,
  });
}
```

### Content-Security-Policy (CSP)

```
# Strong CSP header — adjust based on application needs
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{random}';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self';
  connect-src 'self' https://api.example.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
  upgrade-insecure-requests;
```

```javascript
// Express CSP with nonce-based script loading
import crypto from 'crypto';

app.use((req, res, next) => {
  const nonce = crypto.randomBytes(16).toString('base64');
  res.locals.nonce = nonce;

  res.setHeader('Content-Security-Policy', [
    "default-src 'self'",
    `script-src 'self' 'nonce-${nonce}'`,
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data: https:",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'",
  ].join('; '));

  next();
});

// In templates: <script nonce="<%= nonce %>">...</script>
```

---

## 8. Cryptographic Practices

### Algorithm Selection Guide

| Purpose | Recommended | Avoid |
|---------|-------------|-------|
| Password hashing | Argon2id, bcrypt, scrypt | MD5, SHA1, SHA256 (unsalted) |
| Symmetric encryption | AES-256-GCM, ChaCha20-Poly1305 | AES-ECB, DES, 3DES, RC4 |
| Asymmetric encryption | RSA-OAEP (4096-bit), ECIES | RSA-PKCS1v15 (< 2048-bit) |
| Digital signatures | Ed25519, ECDSA (P-256), RSA-PSS (4096) | RSA-PKCS1v15 (< 2048-bit), DSA |
| Key exchange | X25519, ECDH (P-256) | DH (< 2048-bit) |
| Hashing (non-password) | SHA-256, SHA-3, BLAKE3 | MD5, SHA1 |
| Random generation | `os.urandom`, `crypto.randomBytes`, `SecureRandom` | `Math.random`, `random.random` |
| TLS version | TLS 1.3, TLS 1.2 | TLS 1.0, TLS 1.1, SSLv3 |

### Key Management Principles

```python
# WRONG: Key in source code
ENCRYPTION_KEY = "my-secret-key-12345"

# RIGHT: Key from environment / secrets manager
import os
from base64 import b64decode

def get_encryption_key() -> bytes:
    """Load encryption key from environment (set by secrets manager)."""
    key_b64 = os.environ.get('ENCRYPTION_KEY')
    if not key_b64:
        raise RuntimeError("ENCRYPTION_KEY environment variable not set")
    key = b64decode(key_b64)
    if len(key) != 32:  # 256 bits
        raise RuntimeError("Invalid key length")
    return key

# Key rotation pattern
def encrypt_with_versioned_key(plaintext: bytes) -> dict:
    """Encrypt with current key version; store version for later decryption."""
    current_version = os.environ.get('ENCRYPTION_KEY_VERSION', 'v1')
    key = get_encryption_key()

    nonce = os.urandom(12)
    aesgcm = AESGCM(key)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)

    return {
        'key_version': current_version,
        'nonce': nonce.hex(),
        'ciphertext': ciphertext.hex(),
    }
```

### Rules for Cryptographic Practices

1. **Never roll your own crypto.** Use established libraries (`cryptography`, `libsodium`, `Web Crypto API`).
2. **Always use authenticated encryption** (GCM, Poly1305) — not just encryption.
3. **Never reuse nonces/IVs** with the same key.
4. **Generate keys with CSPRNGs**, never derive from passwords without a KDF.
5. **Store keys in secrets managers** (AWS KMS, HashiCorp Vault, Azure Key Vault), never in code/config.
6. **Implement key rotation** with version tracking.
7. **Use constant-time comparison** for MAC/hash verification (`hmac.compare_digest`, `crypto.timingSafeEqual`).

---

## 9. Error Handling & Logging

### Secure Error Messages

```javascript
// WRONG: Exposes implementation details
app.post('/api/login', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE email = $1', [req.body.email]);
    if (!user) return res.status(404).json({ error: 'User not found' });
    // ^ Reveals that the email doesn't exist (user enumeration)

    const valid = await bcrypt.compare(req.body.password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Wrong password' });
    // ^ Confirms the email exists but password is wrong
  } catch (err) {
    return res.status(500).json({ error: err.message, stack: err.stack });
    // ^ Exposes internal error details
  }
});

// RIGHT: Generic messages externally, detailed logs internally
app.post('/api/login', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE email = $1', [req.body.email]);

    // Constant-time-like behavior: always hash even if user not found
    const storedHash = user?.password_hash || '$2b$12$invalidhashplaceholderxxx';
    const valid = user && await bcrypt.compare(req.body.password, storedHash);

    if (!valid) {
      logger.info({
        event: 'login_failed',
        email: req.body.email,
        reason: user ? 'wrong_password' : 'user_not_found',
        ip: req.ip,
      });
      // Generic message — same for wrong email OR wrong password
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    logger.info({ event: 'login_success', userId: user.id, ip: req.ip });
    // ... generate token
  } catch (err) {
    const errorId = crypto.randomUUID();
    logger.error({ errorId, event: 'login_error', error: err.message, stack: err.stack });
    return res.status(500).json({ error: 'An error occurred', errorId });
  }
});
```

### Structured Security Logging

```python
import structlog
import re

# PII redaction processor
SENSITIVE_PATTERNS = {
    'email': re.compile(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    'ssn': re.compile(r'\b\d{3}-\d{2}-\d{4}\b'),
    'credit_card': re.compile(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
    'phone': re.compile(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
}

def redact_pii(_, __, event_dict):
    """Redact PII from log messages."""
    for key, value in event_dict.items():
        if isinstance(value, str):
            for pii_type, pattern in SENSITIVE_PATTERNS.items():
                value = pattern.sub(f'[REDACTED-{pii_type.upper()}]', value)
            event_dict[key] = value
    return event_dict

# Configure structured logger
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        redact_pii,
        structlog.processors.JSONRenderer(),
    ]
)

logger = structlog.get_logger()

# Security event logging
def log_security_event(event_type: str, **kwargs):
    """Standardized security event logging for SIEM integration."""
    logger.info(
        "security_event",
        event_type=event_type,
        **kwargs
    )

# Usage
log_security_event(
    "authentication_failure",
    user_id="user-123",
    ip_address="192.168.1.1",
    user_agent="Mozilla/5.0...",
    failure_reason="invalid_password",
    attempt_count=3,
)
```

### What to Log (Security Events)

| Event | Required Fields |
|-------|----------------|
| Authentication success/failure | user_id, ip, user_agent, method |
| Authorization failure | user_id, resource, permission, ip |
| Input validation failure | endpoint, field, violation_type, ip |
| Privilege escalation attempt | user_id, from_role, attempted_role |
| Session events (create/destroy/timeout) | session_id, user_id, reason |
| Data access (sensitive resources) | user_id, resource_type, resource_id, action |
| Configuration changes | user_id, setting, old_value, new_value |
| API rate limit exceeded | ip, endpoint, limit |

### What NOT to Log

- Passwords (even hashed)
- Session tokens, JWTs, API keys
- Credit card numbers, SSNs
- Full request/response bodies containing PII
- Encryption keys or secrets

---

## 10. Data Protection

### Encryption at Rest

```python
# Database field-level encryption for sensitive columns
from cryptography.fernet import Fernet
import os

class FieldEncryptor:
    """Encrypt sensitive database fields with key rotation support."""

    def __init__(self):
        # Support multiple keys for rotation
        keys = os.environ['FIELD_ENCRYPTION_KEYS'].split(',')
        self.fernets = [Fernet(k.encode()) for k in keys]
        self.primary = self.fernets[0]  # Current key for encryption

    def encrypt(self, plaintext: str) -> str:
        return self.primary.encrypt(plaintext.encode()).decode()

    def decrypt(self, ciphertext: str) -> str:
        # Try all keys (supports rotation)
        for fernet in self.fernets:
            try:
                return fernet.decrypt(ciphertext.encode()).decode()
            except Exception:
                continue
        raise ValueError("Decryption failed with all available keys")

encryptor = FieldEncryptor()

# Usage in ORM model
class User(Base):
    __tablename__ = 'users'
    id = Column(UUID, primary_key=True)
    email = Column(String)  # Searchable, hashed index
    _ssn_encrypted = Column('ssn', String)  # Encrypted at rest

    @property
    def ssn(self):
        return encryptor.decrypt(self._ssn_encrypted) if self._ssn_encrypted else None

    @ssn.setter
    def ssn(self, value):
        self._ssn_encrypted = encryptor.encrypt(value) if value else None
```

### Data Classification

| Level | Examples | Controls |
|-------|----------|----------|
| **Public** | Marketing content, docs | None required |
| **Internal** | Internal tools, policies | Authentication required |
| **Confidential** | PII, financial data, emails | Encryption + access control + audit logging |
| **Restricted** | Credentials, encryption keys, health data | Encryption + strict RBAC + MFA + audit + retention policy |

### Secrets Management

```yaml
# docker-compose.yml — use Docker secrets or external vault
services:
  app:
    environment:
      # WRONG: Secrets in environment (visible in `docker inspect`)
      # DB_PASSWORD: "my-secret-password"

      # RIGHT: Reference secrets from vault
      DB_PASSWORD_FILE: /run/secrets/db_password
      VAULT_ADDR: https://vault.internal:8200
    secrets:
      - db_password

secrets:
  db_password:
    external: true  # Managed by Docker Swarm or external secrets manager
```

```javascript
// Application-level secrets loading pattern
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

class SecretsLoader {
  constructor() {
    this.client = new SecretsManagerClient({ region: process.env.AWS_REGION });
    this.cache = new Map();
    this.ttl = 3600000; // 1 hour cache
  }

  async getSecret(secretName) {
    const cached = this.cache.get(secretName);
    if (cached && Date.now() - cached.timestamp < this.ttl) {
      return cached.value;
    }

    const command = new GetSecretValueCommand({ SecretId: secretName });
    const response = await this.client.send(command);
    const value = JSON.parse(response.SecretString);

    this.cache.set(secretName, { value, timestamp: Date.now() });
    return value;
  }
}

// Usage
const secrets = new SecretsLoader();
const dbConfig = await secrets.getSecret('prod/database/credentials');
```

---

## 11. API Security Patterns

### Rate Limiting

```javascript
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

// Tiered rate limiting
const globalLimiter = rateLimit({
  store: new RedisStore({ sendCommand: (...args) => redis.call(...args) }),
  windowMs: 15 * 60 * 1000,
  max: 1000,
  standardHeaders: true,
  message: { error: 'Too many requests' },
});

const authLimiter = rateLimit({
  store: new RedisStore({ sendCommand: (...args) => redis.call(...args) }),
  windowMs: 15 * 60 * 1000,
  max: 10,  // Strict limit for auth endpoints
  keyGenerator: (req) => `auth:${req.ip}:${req.body?.email || 'unknown'}`,
  message: { error: 'Too many login attempts. Try again later.' },
});

const apiLimiter = rateLimit({
  store: new RedisStore({ sendCommand: (...args) => redis.call(...args) }),
  windowMs: 60 * 1000,
  max: 100,
  keyGenerator: (req) => `api:${req.user?.id || req.ip}`,
});

app.use(globalLimiter);
app.use('/api/auth', authLimiter);
app.use('/api', apiLimiter);
```

### API Input Validation Middleware

```typescript
import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';

function validateRequest(schema: {
  body?: z.ZodSchema;
  params?: z.ZodSchema;
  query?: z.ZodSchema;
}) {
  return (req: Request, res: Response, next: NextFunction) => {
    const errors: Record<string, any> = {};

    if (schema.body) {
      const result = schema.body.safeParse(req.body);
      if (!result.success) errors.body = result.error.flatten();
      else req.body = result.data;
    }

    if (schema.params) {
      const result = schema.params.safeParse(req.params);
      if (!result.success) errors.params = result.error.flatten();
      else req.params = result.data as any;
    }

    if (schema.query) {
      const result = schema.query.safeParse(req.query);
      if (!result.success) errors.query = result.error.flatten();
      else req.query = result.data as any;
    }

    if (Object.keys(errors).length > 0) {
      return res.status(400).json({ error: 'Validation failed', details: errors });
    }

    next();
  };
}

// Usage
app.get('/api/users',
  authenticate,
  authorize('users:read'),
  validateRequest({
    query: z.object({
      page: z.coerce.number().int().min(1).default(1),
      limit: z.coerce.number().int().min(1).max(100).default(20),
      sort: z.enum(['name', 'created_at', 'email']).default('created_at'),
    }),
  }),
  listUsersHandler
);
```

### CORS Configuration

```javascript
import cors from 'cors';

// SECURE: Explicit origin allowlist, restricted methods
const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = [
      'https://app.example.com',
      'https://admin.example.com',
    ];
    // Allow requests with no origin (mobile apps, curl) OR from allowlist
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  exposedHeaders: ['X-Request-ID', 'X-RateLimit-Remaining'],
  credentials: true,
  maxAge: 86400,  // Preflight cache: 24 hours
};

app.use(cors(corsOptions));
```

### BOLA (Broken Object Level Authorization) Prevention

```javascript
// BOLA is the #1 API vulnerability (OWASP API Top 10)

// VULNERABLE: No ownership check
app.get('/api/orders/:orderId', authenticate, async (req, res) => {
  const order = await Order.findById(req.params.orderId);
  res.json(order);  // Any user can access any order
});

// SECURE: Ownership enforcement
app.get('/api/orders/:orderId', authenticate, async (req, res) => {
  const order = await Order.findOne({
    _id: req.params.orderId,
    userId: req.user.id,  // Filter by authenticated user
  });
  if (!order) return res.status(404).json({ error: 'Order not found' });
  res.json(order);
});

// PATTERN: Generic ownership middleware
function enforceOwnership(model, ownerField = 'userId') {
  return async (req, res, next) => {
    const resource = await model.findById(req.params.id);
    if (!resource) return res.status(404).json({ error: 'Not found' });

    if (resource[ownerField].toString() !== req.user.id && req.user.role !== 'admin') {
      auditLog.warn({
        event: 'bola_attempt',
        userId: req.user.id,
        resourceId: req.params.id,
        model: model.modelName,
      });
      return res.status(403).json({ error: 'Access denied' });
    }

    req.resource = resource;
    next();
  };
}
```

---

## 12. Dependency Management

### SCA Scanning in CI/CD

```yaml
# GitHub Actions workflow for dependency security
name: Dependency Security Scan
on:
  push:
    paths: ['package*.json', 'requirements*.txt', 'go.sum', 'pom.xml']
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6 AM

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Node.js
      - name: npm audit
        run: npm audit --audit-level=high
        continue-on-error: false

      # Multi-language with Trivy
      - name: Trivy filesystem scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      # SBOM generation
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          format: spdx-json
          output-file: sbom.spdx.json
```

### Lockfile Verification

```bash
# Verify lockfile integrity before installing
# Node.js
npm ci --ignore-scripts  # Uses lockfile exactly, skips arbitrary scripts

# Python
pip install --require-hashes -r requirements.txt

# Go
go mod verify  # Verifies checksums against go.sum
```

### SBOM Generation

```bash
# Generate Software Bill of Materials
# Using syft (multi-ecosystem)
syft . -o spdx-json > sbom.spdx.json
syft . -o cyclonedx-json > sbom.cdx.json

# Scan SBOM for vulnerabilities
grype sbom:sbom.cdx.json --fail-on high
```

### Dependency Hygiene Checklist

1. Pin all dependency versions in lockfiles.
2. Run `npm audit` / `pip-audit` / `trivy fs .` in every CI build.
3. Enable Dependabot / Renovate for automated security updates.
4. Review changelogs before upgrading major versions.
5. Remove unused dependencies (`depcheck`, `pip-extra-reqs`).
6. Verify package integrity hashes on install.
7. Block packages with known malicious versions (Socket.dev, npm provenance).
8. Generate and store SBOMs for every release.

---

## 13. Code Review Security Checklist

Use this 20-item checklist for every security-focused code review:

### Authentication & Session

- [ ] 1. Passwords hashed with Argon2id/bcrypt (cost factor >= 12)?
- [ ] 2. Session tokens regenerated after authentication?
- [ ] 3. JWT algorithm restricted (no `alg: none`), expiry set, claims validated?
- [ ] 4. MFA enforced for privileged operations?

### Authorization

- [ ] 5. Every endpoint has explicit authorization checks (deny by default)?
- [ ] 6. Object-level authorization enforced (no IDOR/BOLA)?
- [ ] 7. Role/permission checks happen server-side only?
- [ ] 8. Admin functions protected with additional authentication step?

### Input & Output

- [ ] 9. All inputs validated with allowlist patterns or schema validation?
- [ ] 10. SQL queries use parameterized statements (no string concatenation)?
- [ ] 11. Output encoding applied in correct context (HTML, JS, URL, CSS)?
- [ ] 12. File uploads validated by content type, size limited, stored safely?

### Data Protection

- [ ] 13. Sensitive data encrypted at rest (AES-256-GCM or equivalent)?
- [ ] 14. All external communications use TLS 1.2+?
- [ ] 15. No secrets, keys, or credentials in source code or config files?
- [ ] 16. PII redacted from logs?

### Error Handling & Logging

- [ ] 17. Error messages do not expose internal details (stack traces, SQL, paths)?
- [ ] 18. Security events logged with sufficient context for investigation?
- [ ] 19. Failed access attempts logged and monitored?

### Dependencies & Configuration

- [ ] 20. No known vulnerable dependencies (SCA scan passing)?

---

## 14. Language-Specific Guides

### Node.js / TypeScript

| Area | Recommendation |
|------|---------------|
| Input validation | Use `zod`, `joi`, or `class-validator` |
| SQL | Use Prisma, Knex (parameterized), or TypeORM |
| XSS prevention | Use React (auto-escapes), or `DOMPurify` for raw HTML |
| Password hashing | `bcrypt` (12+ rounds) or `argon2` |
| CSRF | `csurf` middleware or double-submit cookie pattern |
| Rate limiting | `express-rate-limit` with Redis store |
| Security headers | `helmet` middleware |
| Secrets | `dotenv` for dev, AWS Secrets Manager / Vault for prod |
| Logging | `pino` or `winston` with PII redaction |
| Dependency scan | `npm audit`, Snyk, Socket.dev |

```javascript
// Minimal secure Express setup
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { pinoHttp } from 'pino-http';

const app = express();
app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(','), credentials: true }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
app.use(express.json({ limit: '1mb' }));
app.use(pinoHttp({ redact: ['req.headers.authorization', 'req.headers.cookie'] }));
app.disable('x-powered-by');
```

### Python

| Area | Recommendation |
|------|---------------|
| Input validation | `pydantic` (v2), `marshmallow`, `cerberus` |
| SQL | SQLAlchemy with bound parameters, Django ORM |
| XSS prevention | Django templates (auto-escape), Jinja2 `|e` filter |
| Password hashing | `argon2-cffi`, `passlib[bcrypt]` |
| CSRF | Django CSRF middleware, Flask-WTF |
| Rate limiting | `slowapi` (FastAPI), `django-ratelimit` |
| Security headers | `django-csp`, `secure` |
| Secrets | `python-dotenv` dev, AWS Secrets Manager prod |
| Logging | `structlog` with PII filter |
| Dependency scan | `pip-audit`, `safety`, `bandit` |

```python
# Minimal secure FastAPI setup
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
from secure import SecureHeaders

app = FastAPI(docs_url=None, redoc_url=None)  # Disable docs in production
secure_headers = SecureHeaders()

app.add_middleware(HTTPSRedirectMiddleware)
app.add_middleware(CORSMiddleware,
    allow_origins=["https://app.example.com"],
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
    allow_credentials=True,
)

limiter = Limiter(key_func=lambda req: req.client.host)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.middleware("http")
async def set_secure_headers(request, call_next):
    response = await call_next(request)
    secure_headers.framework.fastapi(response)
    return response
```

### Java / Spring Boot

| Area | Recommendation |
|------|---------------|
| Input validation | Bean Validation (JSR 380), `@Valid` |
| SQL | Spring Data JPA (named params), `JdbcTemplate` |
| XSS prevention | Thymeleaf (auto-escape), OWASP Java Encoder |
| Password hashing | Spring Security `BCryptPasswordEncoder` (strength=12) |
| CSRF | Spring Security CSRF (enabled by default) |
| Rate limiting | Bucket4j, Resilience4j |
| Security headers | Spring Security headers configuration |
| Secrets | Spring Cloud Vault, AWS Secrets Manager |
| Logging | SLF4J + Logback with PII masking |
| Dependency scan | OWASP Dependency-Check Maven plugin, Snyk |

```java
// Spring Security configuration
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .headers(headers -> headers
                .contentSecurityPolicy(csp -> csp.policyDirectives("default-src 'self'"))
                .frameOptions(fo -> fo.deny())
                .httpStrictTransportSecurity(hsts -> hsts.maxAgeInSeconds(31536000).includeSubDomains(true))
            )
            .csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse()))
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            );
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
```

### Go

| Area | Recommendation |
|------|---------------|
| Input validation | `go-playground/validator`, manual checks |
| SQL | `database/sql` with `$1` params, `sqlx`, `GORM` |
| XSS prevention | `html/template` (auto-escape), `bluemonday` |
| Password hashing | `golang.org/x/crypto/bcrypt` or `argon2` |
| CSRF | `gorilla/csrf`, `nosurf` |
| Rate limiting | `golang.org/x/time/rate`, `ulule/limiter` |
| Security headers | Custom middleware |
| Secrets | `hashicorp/vault` SDK, AWS SDK |
| Logging | `zerolog`, `zap` with field redaction |
| Dependency scan | `govulncheck`, `nancy`, `trivy` |

```go
// Secure HTTP server configuration
package main

import (
    "crypto/tls"
    "net/http"
    "time"
)

func main() {
    mux := http.NewServeMux()
    // ... register handlers

    srv := &http.Server{
        Addr:         ":8443",
        Handler:      securityHeaders(mux),
        ReadTimeout:  5 * time.Second,
        WriteTimeout: 10 * time.Second,
        IdleTimeout:  120 * time.Second,
        TLSConfig: &tls.Config{
            MinVersion:               tls.VersionTLS12,
            PreferServerCipherSuites: true,
            CurvePreferences:         []tls.CurveID{tls.X25519, tls.CurveP256},
        },
    }
    srv.ListenAndServeTLS("cert.pem", "key.pem")
}

func securityHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("Content-Security-Policy", "default-src 'self'")
        w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
        w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
        next.ServeHTTP(w, r)
    })
}
```

---

## 15. Verification

### SAST with Semgrep

```bash
# Install
pip install semgrep

# Run OWASP rules
semgrep --config "p/owasp-top-ten" .
semgrep --config "p/security-audit" .
semgrep --config "p/secrets" .

# Language-specific
semgrep --config "p/javascript" --config "p/typescript" .
semgrep --config "p/python" .
semgrep --config "p/java" .
semgrep --config "p/golang" .
```

### Custom Semgrep Rules

```yaml
# .semgrep/custom-rules.yml
rules:
  - id: no-exec-with-user-input
    patterns:
      - pattern: exec($CMD)
      - pattern-not: execFile(...)
    message: "Use execFile() instead of exec() to prevent command injection"
    languages: [javascript, typescript]
    severity: ERROR
    metadata:
      cwe: ["CWE-78"]
      owasp: ["A03:2021"]

  - id: no-raw-sql-concat
    patterns:
      - pattern: |
          $QUERY = "..." + $VAR + "..."
      - metavariable-regex:
          metavariable: $QUERY
          regex: ".*(SELECT|INSERT|UPDATE|DELETE|DROP).*"
    message: "SQL string concatenation detected. Use parameterized queries."
    languages: [javascript, typescript, python, java]
    severity: ERROR
    metadata:
      cwe: ["CWE-89"]
      owasp: ["A03:2021"]

  - id: no-md5-sha1-passwords
    patterns:
      - pattern-either:
          - pattern: hashlib.md5(...)
          - pattern: hashlib.sha1(...)
          - pattern: crypto.createHash("md5")
          - pattern: crypto.createHash("sha1")
          - pattern: MessageDigest.getInstance("MD5")
          - pattern: MessageDigest.getInstance("SHA-1")
    message: "Do not use MD5/SHA1 for password hashing. Use Argon2id or bcrypt."
    languages: [python, javascript, java]
    severity: ERROR
    metadata:
      cwe: ["CWE-328"]
      owasp: ["A02:2021"]

  - id: no-hardcoded-secrets
    patterns:
      - pattern-either:
          - pattern: |
              $KEY = "AKIA..."
          - pattern: |
              password = "..."
          - pattern: |
              api_key = "..."
          - pattern: |
              secret = "..."
    message: "Possible hardcoded secret detected. Use a secrets manager."
    languages: [python, javascript, typescript, java, go]
    severity: ERROR
    metadata:
      cwe: ["CWE-798"]
      owasp: ["A07:2021"]
```

### DAST with OWASP ZAP

```bash
# Quick scan with ZAP Docker
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t https://staging.example.com \
  -r report.html

# Full scan (more thorough, takes longer)
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py \
  -t https://staging.example.com \
  -r full-report.html

# API scan with OpenAPI spec
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t https://staging.example.com/openapi.json \
  -f openapi \
  -r api-report.html
```

### Manual Review Focus Areas

When automated tools are not enough, focus manual review on:

1. **Business logic flaws** — Pricing manipulation, workflow bypass, race conditions.
2. **Authorization edge cases** — Multi-tenant isolation, role transitions, delegated access.
3. **State management** — Session handling, concurrent request behavior, idempotency.
4. **Cryptographic implementation** — Key handling, nonce reuse, timing attacks.
5. **Third-party integrations** — Webhook validation, OAuth flows, callback URLs.

### Verification Matrix

| Layer | Tool | Frequency | Gate |
|-------|------|-----------|------|
| SAST | Semgrep, SonarQube | Every commit | Block on HIGH/CRITICAL |
| SCA | Trivy, npm audit | Every commit | Block on HIGH/CRITICAL |
| Secrets | Gitleaks, TruffleHog | Every commit (pre-commit hook) | Block on any finding |
| DAST | OWASP ZAP | Weekly + pre-release | Block on HIGH |
| Manual review | Security champion | Every PR with auth/crypto changes | Required approval |
| Penetration test | External firm | Quarterly / annually | Remediation SLA |

---

## References

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP Secure Coding Practices Quick Reference Guide](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [OWASP Application Security Verification Standard (ASVS)](https://owasp.org/www-project-application-security-verification-standard/)
- [OWASP API Security Top 10](https://owasp.org/API-Security/)
- [CWE/SANS Top 25 Most Dangerous Software Weaknesses](https://cwe.mitre.org/top25/)
- [NIST Secure Software Development Framework (SSDF)](https://csrc.nist.gov/projects/ssdf)
- [Semgrep Rules Registry](https://semgrep.dev/explore)
- [OWASP ZAP Documentation](https://www.zaproxy.org/docs/)
