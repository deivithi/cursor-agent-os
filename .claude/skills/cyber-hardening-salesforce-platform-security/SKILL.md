---
name: hardening-salesforce-platform-security
description: >
  Comprehensive security hardening for Salesforce orgs covering access controls, data protection,
  API security, custom code review, and compliance controls for Sales, Service, Experience, and
  Marketing Cloud. Designed for Product Owners and Salesforce administrators responsible for
  org-level security posture, governance, and regulatory compliance.
domain: cybersecurity
subdomain: application-security
tags: [salesforce, crm-security, field-level-security, sharing-rules, profiles-permissions, apex-security, soql-injection, experience-cloud, marketing-cloud, shield, event-monitoring]
version: "1.0"
author: deivithi
license: Apache-2.0
---

# Hardening Salesforce Platform Security

## When to Use

- When performing a security assessment or hardening review of a Salesforce org (Production or Sandbox)
- When onboarding a new Salesforce org or post-merger integration requires security baseline validation
- When preparing for compliance audits (SOX, LGPD/GDPR, PCI DSS, ISO 27001) involving Salesforce data
- When the Security Health Check score is below 90% and needs remediation planning
- When investigating suspicious login activity, data exfiltration risks, or API abuse
- When launching or reviewing Experience Cloud sites, Marketing Cloud integrations, or new Connected Apps
- When reviewing custom Apex/LWC/Visualforce code for security vulnerabilities before deployment

**Do not use** for Salesforce infrastructure-level security (managed by Salesforce Trust), for MuleSoft or Heroku-specific hardening (separate skills), or for real-time SOC monitoring (use Shield Event Monitoring with a SIEM integration).

## Prerequisites

- **Salesforce Admin access** with System Administrator profile or equivalent permissions in the target org
- **Security Health Check** tool access (Setup > Security > Health Check)
- **Salesforce Optimizer** installed from AppExchange (free)
- **Shield Platform Encryption** license (required for encryption and event monitoring sections)
- **Salesforce CLI (sf/sfdx)** installed and authenticated (`sf org login web -a TARGET_ORG`)
- **PMD Source Code Analyzer** with Apex ruleset for static code analysis
- **Access to Setup Audit Trail** and **Login History** (standard in all editions)

---

## 1. Overview: Salesforce Shared Responsibility Model

Salesforce operates on a **Shared Responsibility Model**:

| Responsibility | Owner | Examples |
|---------------|-------|---------|
| Physical infrastructure, network, hypervisor | **Salesforce** | Data center security, patching Salesforce platform code, DDoS protection |
| Application-level configuration and data | **Customer** | Profiles, permission sets, sharing rules, OWD, FLS, custom code security |
| Identity and access management | **Shared** | Salesforce provides MFA, SSO capabilities; customer must configure and enforce them |
| Data classification and encryption | **Shared** | Salesforce provides Shield Encryption; customer must classify data and enable encryption on sensitive fields |
| Compliance and governance | **Customer** | Mapping Salesforce controls to regulatory requirements (SOX, LGPD, GDPR) |

**Why hardening matters:** Salesforce ships with permissive defaults to accelerate adoption. Out-of-the-box configurations prioritize usability over security. A fresh org with default OWD (Public Read/Write), no MFA, and the standard System Administrator profile grants excessive access. Every Salesforce org requires deliberate hardening to reduce attack surface.

---

## 2. Prerequisites Deep Dive

### Security Health Check

```
Setup > Security > Health Check
```

The Health Check compares your org settings against Salesforce's recommended baseline. Target score: **90% or higher**. Any setting rated HIGH or CRITICAL risk must be remediated.

### Salesforce Optimizer

```
Setup > Optimizer > Run Optimizer
```

Identifies unused profiles, permission sets, custom fields, and configuration drift. Use this alongside Health Check for a complete picture.

### Shield License Components

| Component | Purpose |
|-----------|---------|
| Platform Encryption | Encrypt fields, files, and attachments at rest with customer-managed keys |
| Event Monitoring | 50+ event types for user activity tracking (API calls, report exports, logins) |
| Field Audit Trail | Retain field history beyond the standard 18-month limit (up to 10 years) |

---

## 3. Identity & Access Controls

### Step 3.1: Profile and Permission Set Architecture

Enforce the **Principle of Least Privilege** by migrating from Profiles to Permission Sets and Permission Set Groups.

```
# Audit current profile assignments via SOQL (Developer Console or Salesforce CLI)
SELECT Profile.Name, COUNT(Id)
FROM User
WHERE IsActive = true
GROUP BY Profile.Name
ORDER BY COUNT(Id) DESC
```

```
# Find users with "Modify All Data" permission (critical overprivilege)
SELECT Id, Username, Profile.Name
FROM User
WHERE IsActive = true
AND Profile.PermissionsModifyAllData = true
```

```
# Find users with "View All Data" permission
SELECT Id, Username, Profile.Name
FROM User
WHERE IsActive = true
AND Profile.PermissionsViewAllData = true
```

**Architecture recommendations:**

| Practice | Description |
|----------|-------------|
| Minimum Viable Profile | Create profiles with **minimum** permissions. Use only for login and page layout assignments |
| Permission Set Groups | Bundle permission sets into logical groups by job function (e.g., "Sales Rep," "Service Agent") |
| Muting Permission Sets | Use muting permission sets within groups to **remove** specific permissions without creating new groups |
| Regular review | Audit permission assignments quarterly; remove unused permission sets |

### Step 3.2: MFA Enforcement

As of **February 1, 2022**, Salesforce contractually requires MFA for all users accessing Salesforce products via the UI.

```
# Check MFA enforcement status
Setup > Identity > Multi-Factor Authentication
Setup > Session Settings > Session Security Levels
```

```
# Find users without MFA verification methods registered
SELECT Id, Username, Profile.Name
FROM User
WHERE IsActive = true
AND Id NOT IN (
    SELECT UserId FROM TwoFactorInfo WHERE IsActive = true
)
```

**MFA Configuration Checklist:**

- [ ] Enable "Multi-Factor Authentication for User Interface Logins" permission in all profiles/permission sets
- [ ] Set Session Security Level to "High Assurance" for MFA-verified sessions
- [ ] Configure "High Assurance session required for" sensitive operations (Reports Export, Connected App access)
- [ ] Deploy Salesforce Authenticator or TOTP-based authenticator apps
- [ ] Disable SMS-based verification (vulnerable to SIM-swap attacks)
- [ ] Create break-glass admin accounts with hardware security keys (YubiKey)

### Step 3.3: Session Settings

```
Setup > Session Settings
```

| Setting | Recommended Value | Rationale |
|---------|-------------------|-----------|
| Session Timeout | 2 hours (or less for sensitive orgs) | Reduce window for session hijacking |
| Lock sessions to the IP address from which they originated | **Enabled** | Prevents session token reuse from different IPs |
| Lock sessions to the domain in which they were first used | **Enabled** | Prevents cross-domain session abuse |
| Force logout on session timeout | **Enabled** | No persistent sessions |
| Require HttpOnly attribute | **Enabled** | Prevents JavaScript access to session cookies |
| Require Secure Connections (HTTPS) | **Enabled** (default in modern orgs) | No plaintext HTTP |
| Enable Clickjack Protection | **Enabled for all pages** | Prevents UI redress attacks |
| Enable Content Security Policy (CSP) | **Enabled** | Mitigates XSS and injection attacks |
| Enable HSTS | **Enabled** | Forces HTTPS for all browser requests |

### Step 3.4: Login IP Ranges and Login Hours

```
# Restrict login IP ranges per profile
Setup > Profiles > [Profile Name] > Login IP Ranges

# Restrict login hours per profile
Setup > Profiles > [Profile Name] > Login Hours
```

**Best practices:**
- Restrict admin profiles to corporate VPN IP ranges only
- Set login hours for non-admin users to business hours
- Use **Login Flows** for conditional logic (e.g., block login from non-approved countries)

### Step 3.5: SSO Integration

```
Setup > Identity > Single Sign-On Settings
```

| Protocol | Use Case |
|----------|----------|
| SAML 2.0 | Enterprise SSO with IdP (Okta, Azure AD, Ping Identity) |
| OpenID Connect | Modern web/mobile SSO |
| OAuth 2.0 | API authentication, Connected App access |

**SSO hardening:**
- Disable direct username/password login for all non-admin users after SSO is enabled
- Maintain 2-3 break-glass admin accounts with direct login (with MFA + IP restriction)
- Set `Is Registration Enabled` to **false** on Auth Providers unless explicitly needed
- Validate SAML assertion signatures and configure `Issuer` and `Entity ID` correctly
- Set "Identity Type" to **Federation ID** (not Username) for decoupled identity mapping

---

## 4. Data Security

### Step 4.1: Organization-Wide Defaults (OWD)

OWD is the **foundation** of Salesforce data security. It defines the baseline access level for every object.

```
Setup > Sharing Settings > Organization-Wide Defaults
```

| OWD Setting | When to Use |
|-------------|-------------|
| **Private** | Default for all sensitive objects (Opportunity, Case, Lead, Custom Objects with PII) |
| **Public Read Only** | Objects where users need visibility but not edit access (e.g., Knowledge articles) |
| **Public Read/Write** | Only for truly public data with no sensitivity (rare in production) |
| **Controlled by Parent** | Detail objects in master-detail relationships inherit parent sharing |

```
# Audit current OWD settings via Metadata API
sf project retrieve start --metadata SharingRules --target-org TARGET_ORG
```

**Critical rule:** Start with **Private** for all objects and open access through sharing rules, role hierarchy, and permission sets. Never start with Public Read/Write and try to restrict — Salesforce does not support "negative" sharing.

### Step 4.2: Sharing Rules and Role Hierarchy

```
# Review sharing rules
SELECT Id, DeveloperName, SObjectType
FROM SharingRule
ORDER BY SObjectType

# Review role hierarchy
SELECT Id, Name, ParentRoleId, DeveloperName
FROM UserRole
ORDER BY ParentRoleId
```

**Sharing architecture hardening:**

- [ ] Role hierarchy should mirror reporting structure, not org chart
- [ ] Avoid using "Grant Access Using Hierarchies" on sensitive custom objects (can be disabled per object)
- [ ] Prefer **criteria-based sharing rules** over owner-based for auditability
- [ ] Avoid manual sharing for anything systematic — use sharing rules or Apex managed sharing
- [ ] Limit sharing rule count per object (performance degrades above 200+ rules)
- [ ] Review sharing rules quarterly for stale or overly broad access grants

### Step 4.3: Field-Level Security (FLS) Audit

```
# Find fields accessible to a specific profile
SELECT SObjectType, Field, PermissionsRead, PermissionsEdit
FROM FieldPermissions
WHERE Parent.Profile.Name = 'Standard User'
AND PermissionsRead = true
ORDER BY SObjectType, Field

# Find sensitive fields with broad access (e.g., SSN, Tax ID)
SELECT SObjectType, Field, Parent.Profile.Name, PermissionsRead, PermissionsEdit
FROM FieldPermissions
WHERE Field LIKE '%SSN%' OR Field LIKE '%Tax%' OR Field LIKE '%CPF%'
ORDER BY SObjectType
```

**FLS best practices:**
- SSN, CPF, financial data, health records: **restrict to specific permission sets only**
- Audit FLS on all PII/PCI fields across every profile and permission set
- Use **Data Classification** metadata on fields (`SecurityClassification`, `ComplianceGroup`) to tag sensitivity
- Never rely on page layout removal alone for security — API access bypasses layouts

### Step 4.4: Platform Encryption (Shield)

```
Setup > Platform Encryption > Encryption Policy
```

| What to Encrypt | Method |
|-----------------|--------|
| PII fields (Name, Email, Phone, Address) | Deterministic or Probabilistic Encryption |
| Attachments, Files, CMS Content | File Encryption |
| Search Index | Encrypt Search Index |
| Custom fields with sensitive data | Field-level encryption (Shield) |

**Encryption key management:**
- Rotate tenant secrets on a defined schedule (quarterly recommended)
- Use **Bring Your Own Key (BYOK)** or **Cache-Only Keys** for maximum control
- Never encrypt fields used in WHERE clauses unless using Deterministic Encryption
- Test encryption impact on formulas, validation rules, and SOQL queries before enabling

### Step 4.5: Data Mask for Sandboxes

```
Setup > Data Mask > Create Data Mask
```

- Mask all PII/sensitive fields when refreshing sandboxes
- Use Data Mask (or third-party tools) to prevent production data leakage to developer/QA sandboxes
- Map masking rules to Data Classification metadata
- Automate masking as part of sandbox refresh process

---

## 5. API Security

### Step 5.1: Connected App Security

```
Setup > App Manager > [Connected App] > Manage
```

```
# List all Connected Apps via SOQL
SELECT Id, Name, Description, CreatedDate, CreatedBy.Name
FROM ConnectedApplication
ORDER BY CreatedDate DESC
```

| Setting | Recommended Configuration |
|---------|--------------------------|
| OAuth Scopes | **Minimum required** — never grant `full` scope unless necessary |
| IP Relaxation | **Enforce IP restrictions** — do not relax IP ranges |
| Refresh Token Policy | Expire refresh tokens after defined period (e.g., 90 days) |
| Permitted Users | **Admin approved users are pre-authorized** — do not allow all users |
| Session Policies | Require High Assurance session for sensitive apps |
| Callback URL | Use exact URLs — no wildcards |

### Step 5.2: API-Only Users

```
# Create dedicated integration users with API-only permissions
SELECT Id, Username, Profile.Name, UserType
FROM User
WHERE Profile.Name LIKE '%Integration%'
AND IsActive = true
```

- [ ] Create dedicated integration user accounts per external system
- [ ] Assign the **"API Only User"** permission
- [ ] Use **Permission Sets** (not profiles) to grant minimum object/field access
- [ ] Set Login IP Ranges to integration server IPs only
- [ ] Monitor API call volumes per integration user

### Step 5.3: Named Credentials

```
Setup > Named Credentials
```

**Critical rule: NEVER hardcode credentials, tokens, or secrets in Apex code, Custom Settings, or Custom Metadata.** Always use Named Credentials or External Credentials.

```apex
// BAD - hardcoded credentials
HttpRequest req = new HttpRequest();
req.setHeader('Authorization', 'Bearer sk-1234567890ABCDEF'); // NEVER DO THIS

// GOOD - Named Credential
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:My_Named_Credential/api/v1/resource');
// Salesforce injects auth header automatically
```

### Step 5.4: API Rate Limiting Awareness

| Limit | Value (Enterprise Edition) |
|-------|--------------------------|
| Total API requests per 24 hours | 100,000 (base) + per-license allocation |
| Concurrent API requests (long-running) | 25 |
| Bulk API batches per 24 hours | 15,000 |
| Streaming API concurrent clients | 2,000 |

- Monitor API usage: `Setup > Company Information > API Requests, Last 24 Hours`
- Set up **API Usage Notifications** to alert at 70% and 90% threshold
- Implement exponential backoff in integrations to handle rate limits gracefully

---

## 6. Custom Code Security (Apex / LWC / Visualforce)

### Step 6.1: SOQL Injection Prevention

```apex
// VULNERABLE - Dynamic SOQL with user input concatenation
String query = 'SELECT Id, Name FROM Account WHERE Name = \'' + userInput + '\'';
List<Account> results = Database.query(query); // SOQL INJECTION RISK

// SECURE - Bind variables (preferred)
String accountName = userInput;
List<Account> results = [SELECT Id, Name FROM Account WHERE Name = :accountName];

// SECURE - String.escapeSingleQuotes for dynamic SOQL when bind variables cannot be used
String query = 'SELECT Id, Name FROM Account WHERE Name = \''
    + String.escapeSingleQuotes(userInput) + '\'';
List<Account> results = Database.query(query);
```

### Step 6.2: CRUD/FLS Enforcement in Apex

Apex runs in **system mode** by default — it ignores user permissions. You MUST enforce CRUD/FLS manually.

```apex
// METHOD 1: WITH SECURITY_ENFORCED (throws exception if user lacks access)
List<Account> accts = [
    SELECT Id, Name, Phone
    FROM Account
    WITH SECURITY_ENFORCED
];

// METHOD 2: WITH USER_MODE (respects all user permissions including sharing)
List<Account> accts = [
    SELECT Id, Name, Phone
    FROM Account
    WITH USER_MODE
];

// METHOD 3: stripInaccessible (removes inaccessible fields silently)
List<Account> accts = [SELECT Id, Name, Phone, Revenue__c FROM Account];
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE, accts
);
List<Account> sanitizedAccounts = decision.getRecords();
// Check which fields were removed
Set<String> removedFields = decision.getRemovedFields().get('Account');

// METHOD 4: Schema Describe checks (legacy but still valid)
if (Schema.sObjectType.Account.isAccessible() &&
    Schema.sObjectType.Account.fields.Phone.isAccessible()) {
    // proceed with query
}
```

**Recommended approach:** Use `WITH USER_MODE` for new development (Spring '23+). Use `stripInaccessible` when you need to gracefully handle missing permissions without throwing exceptions.

### Step 6.3: XSS Prevention

```html
<!-- VULNERABLE Visualforce - unescaped output -->
<apex:outputText value="{!userInput}" escape="false" />

<!-- SECURE Visualforce - escaped by default -->
<apex:outputText value="{!userInput}" />

<!-- SECURE - JSENCODE for JavaScript context -->
<script>
    var name = '{!JSENCODE(accountName)}';
</script>

<!-- SECURE - URLENCODE for URL context -->
<a href="/apex/page?id={!URLENCODE(recordId)}">Link</a>
```

**LWC Security:**
- LWC uses Shadow DOM (Lightning Locker / Lightning Web Security) for component isolation
- Never use `innerHTML` — use template expressions instead
- Sanitize user input before rendering via `lightning-formatted-*` components
- CSP is enforced automatically in LWC — do not attempt to bypass

### Step 6.4: CSRF Protection

- Salesforce provides built-in CSRF protection via anti-CSRF tokens on all standard forms
- **Never disable** the CSRF token in Visualforce pages
- For custom REST endpoints (HttpPost in Apex REST), implement your own CSRF token validation
- Use `@AuraEnabled(cacheable=true)` for read-only operations (no state change)
- Use `@AuraEnabled` without cacheable for DML operations (includes CSRF protection in Lightning)

### Step 6.5: Static Code Analysis

```bash
# Install PMD with Apex support
# Run PMD scanner against Apex classes
pmd check --dir ./force-app/main/default/classes \
    --rulesets apex-security,apex-bestpractices,apex-errorprone \
    --format text \
    --report-file pmd-apex-report.txt

# Review critical findings
cat pmd-apex-report.txt | grep -E "(ApexSOQLInjection|ApexCRUDViolation|ApexXSSFromURLParam|ApexInsecureEndpoint)"
```

**Additional scanners:**
- **Checkmarx for Salesforce** — commercial SAST scanner for Apex, Visualforce, LWC
- **Salesforce Code Analyzer (sf scanner)** — Salesforce's official CLI-based scanner
- **Clayton** — SaaS-based Salesforce code quality and security scanner

```bash
# Salesforce Code Analyzer (official)
sf scanner run --target ./force-app --format table --engine pmd,eslint
```

### Step 6.6: Lightning Locker / Lightning Web Security (LWS)

| Feature | Locker Service (Legacy) | Lightning Web Security (LWS) |
|---------|------------------------|------------------------------|
| Isolation | iframe-based sandbox | JavaScript Sandboxing (Distortion) |
| DOM Access | Restricted to own namespace | Restricted to own namespace |
| Global objects | Wrapped secure versions | Virtualized environment |
| Performance | Slower due to iframe overhead | Faster, native-like |
| Cross-namespace | Blocked | Controlled via MessageChannel |

- Enable LWS for new development: `Setup > Session Settings > Use Lightning Web Security`
- Test all custom components after enabling LWS migration
- Never bypass Locker/LWS restrictions using eval(), Function(), or DOM manipulation workarounds

---

## 7. Experience Cloud Security

### Step 7.1: Guest User Hardening

Since **Spring '21**, Salesforce has progressively restricted guest user access. Guest user misconfigurations are the #1 source of Salesforce data leaks.

```
# Audit guest user permissions
SELECT Id, Name, Profile.Name, Profile.PermissionsApiEnabled
FROM User
WHERE UserType = 'Guest' AND IsActive = true

# Check guest user object access
SELECT SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete
FROM ObjectPermissions
WHERE Parent.Profile.Name LIKE '%Guest%'
AND (PermissionsRead = true OR PermissionsCreate = true)
ORDER BY SObjectType
```

**Guest user hardening checklist:**

- [ ] **Disable API access** for all guest user profiles
- [ ] Set OWD to **Private** for all objects accessible to guest users
- [ ] Remove **View All** and **Modify All** permissions from guest profiles
- [ ] Audit all sharing rules that grant guest user access to records
- [ ] Enable **Secure guest user record access** (Setup > Sharing Settings)
- [ ] Review and restrict **Guest User Sharing Rules** (only criteria-based allowed since Spring '21)
- [ ] Remove access to objects not explicitly needed for the site's functionality
- [ ] Disable **"Let guest users see other members of this site"** in community settings
- [ ] Test unauthenticated access by browsing the site in incognito mode

### Step 7.2: Experience Cloud Configuration

```
Setup > Digital Experiences > All Sites > [Site] > Administration
```

| Setting | Recommended |
|---------|-------------|
| Allow internal users to view the site | Disable (unless needed) |
| Public Access | Restrict to minimum pages/components |
| SEO indexing | Disable for non-public portals |
| Self-registration | Disable unless explicitly required; add CAPTCHA |
| Login page | Custom login page with branding; hide "Forgot Password" for internal portals |

### Step 7.3: CORS and CSP for Experience Cloud

```
Setup > CORS > Allowed Origins List
Setup > CSP Trusted Sites
```

- Add only explicitly required external origins to CORS allowlist
- Never use wildcard (`*`) in CORS origins
- Configure CSP headers to restrict script, style, and connect sources
- Use `Strict-Transport-Security` headers via CDN or custom server configuration

---

## 8. Marketing Cloud Security

### Step 8.1: API User Permissions

- Create dedicated API integration users with **minimum role permissions**
- Use Marketing Cloud **Roles and Permissions** to restrict Business Unit access
- Enable **Audit Trail** for all API-initiated actions
- Rotate Marketing Cloud API credentials on a 90-day cycle

### Step 8.2: Data Extension Security

| Control | Implementation |
|---------|----------------|
| Sendable Data Extensions | Restrict to specific Business Units |
| Shared Data Extensions | Audit access across all Business Units; apply "Available in child Business Units" selectively |
| Retention Policies | Set automatic data deletion policies on Data Extensions containing PII |
| Encryption | Enable encryption at rest for Data Extensions with sensitive subscriber data |

### Step 8.3: AMPscript Injection Prevention

```
<!-- VULNERABLE - User input directly in AMPscript -->
%%[
SET @name = RequestParameter("name")
SET @query = CONCAT("SELECT SubscriberKey FROM ENT.DataExtension WHERE Name = '", @name, "'")
]%%

<!-- SECURE - Use Lookup functions instead of dynamic queries -->
%%[
SET @name = RequestParameter("name")
SET @result = Lookup("MyDataExtension", "SubscriberKey", "Name", @name)
]%%
```

- Never use `TreatAsContent()` with user-supplied input
- Validate and sanitize all `RequestParameter()` values
- Use `HTTPRequestHeader()` cautiously — validate expected values
- Avoid exposing Cloud Page URLs that execute privileged AMPscript functions

### Step 8.4: Subscriber Key Management

- Use a **non-guessable subscriber key** (UUID/GUID format preferred)
- Never use email address or sequential IDs as subscriber keys
- Implement subscriber key mapping in Sales Cloud-to-Marketing Cloud connector
- Audit Marketing Cloud Connect permissions (synchronized data access scope)

---

## 9. Monitoring & Audit

### Step 9.1: Event Monitoring (Shield)

```
# Query Event Monitoring logs via SOQL (requires Shield license)
# Login events
SELECT EventDate, UserId, Username, SourceIp, LoginType, Status
FROM LoginEvent
WHERE EventDate = TODAY
ORDER BY EventDate DESC

# API events
SELECT EventDate, UserId, Username, Operation, ApiType, ElapsedTime
FROM ApiEvent
WHERE EventDate = TODAY
ORDER BY EventDate DESC

# Report export events (data exfiltration detection)
SELECT EventDate, UserId, Username, Name, ExportFileFormat, RowsProcessed
FROM ReportExportEvent
WHERE EventDate = TODAY
AND RowsProcessed > 10000

# Lightning page view events
SELECT EventDate, UserId, PageUrl, Duration
FROM LightningPageView
WHERE EventDate = TODAY
```

### Step 9.2: Login History Analysis

```
# Login History (standard — all editions)
SELECT LoginTime, UserId, SourceIp, LoginType, Status, Application, Browser, Platform, CountryIso
FROM LoginHistory
WHERE LoginTime = LAST_N_DAYS:30
AND Status != 'Success'
ORDER BY LoginTime DESC

# Failed logins analysis
SELECT UserId, COUNT(Id) FailedAttempts
FROM LoginHistory
WHERE Status != 'Success'
AND LoginTime = LAST_N_DAYS:7
GROUP BY UserId
HAVING COUNT(Id) > 5
ORDER BY COUNT(Id) DESC
```

### Step 9.3: Setup Audit Trail

```
# Setup Audit Trail (standard — 180 days retained)
SELECT CreatedDate, CreatedBy.Name, Action, Section, Display, DelegateUser
FROM SetupAuditTrail
WHERE CreatedDate = LAST_N_DAYS:30
ORDER BY CreatedDate DESC

# Track permission changes
SELECT CreatedDate, CreatedBy.Name, Action, Display
FROM SetupAuditTrail
WHERE Section = 'Manage Users'
AND CreatedDate = LAST_N_DAYS:7
ORDER BY CreatedDate DESC
```

### Step 9.4: Transaction Security Policies

```
Setup > Transaction Security Policies
```

Create policies to detect and block risky actions in real-time:

| Policy | Trigger | Action |
|--------|---------|--------|
| Large data export | Report export > 10,000 rows | Block + Notify admin |
| Login from new country | Login from country not in allowlist | Require MFA + Notify |
| Bulk API delete | Bulk delete > 1,000 records | Block + Notify admin |
| Session hijack detection | Session IP change mid-session | Terminate session |
| Admin permission escalation | Profile/PermSet change granting Modify All Data | Notify + Require approval |

### Step 9.5: Real-Time Event Monitoring

```
# Subscribe to real-time events via Pub/Sub API
# ApiAnomalyEvent — detects anomalous API behavior
# CredentialStuffingEvent — detects credential stuffing attacks
# SessionHijackingEvent — detects potential session hijacking
# ReportAnomalyEvent — detects unusual report execution patterns

# Example: Streaming subscription for security events
SELECT EventDate, EventIdentifier, SecurityEventData, Summary
FROM ApiAnomalyEventStore
WHERE EventDate = TODAY
```

---

## 10. Compliance

### Step 10.1: Security Health Check

```
Setup > Security > Health Check
```

**Target: Score of 90% or higher.**

The Health Check evaluates settings across these categories:
- Session Settings
- Password Policies
- Network Access
- File Upload/Download Security
- Clickjack Protection
- Cross-Site Scripting (XSS) Protection
- Content Security Policy
- Certificate and Key Management

**Remediation workflow:**
1. Run Health Check and export results
2. Address all **HIGH** and **CRITICAL** risk items first
3. Address **MEDIUM** risk items in the next sprint
4. Re-run Health Check to validate score improvement
5. Schedule monthly Health Check reviews

### Step 10.2: CIS Salesforce Benchmark

The **Center for Internet Security (CIS) Salesforce Benchmark** provides prescriptive hardening guidance. Key controls:

| CIS Control | Description |
|-------------|-------------|
| 1.1 | Ensure "Password Policies" are configured to require minimum length of 12+ characters |
| 1.2 | Ensure MFA is enabled for all user interface logins |
| 2.1 | Ensure "Organization-Wide Defaults" are set to Private for sensitive objects |
| 3.1 | Ensure "Session Timeout" is set to 2 hours or less |
| 4.1 | Ensure "Clickjack Protection" is enabled for all Salesforce pages |
| 5.1 | Ensure "Login IP Ranges" are configured for administrator profiles |
| 6.1 | Ensure "Setup Audit Trail" monitoring is active |
| 7.1 | Ensure Guest User profiles have API access disabled |

Download the full CIS Salesforce Benchmark at: https://www.cisecurity.org/benchmark/salesforce

### Step 10.3: LGPD/GDPR in Salesforce

| Requirement | Salesforce Solution |
|-------------|-------------------|
| Right to access (data portability) | Data Export Service, Reports, API extraction |
| Right to be forgotten (data deletion) | Individual Record Deletion, Privacy Center |
| Consent management | Salesforce Consent Management (Individual object, Contact Point Consent) |
| Data minimization | Data Classification metadata, automated field purging |
| Data breach notification | Event Monitoring + SIEM integration for breach detection |
| Cross-border data transfer | Data Residency (Hyperforce), Shield Platform Encryption |
| Privacy impact assessment | Map data flows using Data Classification + ERDs |

```
# Audit consent records
SELECT Id, IndividualId, DataUsePurpose.Name, CaptureDate, CaptureContactPointType
FROM ContactPointConsent
WHERE IsActive = true
ORDER BY CaptureDate DESC

# Find records without consent
SELECT Id, Name
FROM Individual
WHERE Id NOT IN (
    SELECT IndividualId FROM ContactPointConsent WHERE IsActive = true
)
```

### Step 10.4: SOX Controls for Salesforce

For Sarbanes-Oxley compliance in Salesforce environments:

- **Segregation of Duties:** No single user should have both "Modify All Data" and "View All Data" plus deployment permissions
- **Change Management:** All metadata deployments tracked via change sets or CI/CD with approval gates
- **Access Reviews:** Quarterly user access reviews with manager attestation
- **Audit Trail Retention:** Archive Setup Audit Trail beyond 180 days using Field Audit Trail (Shield)
- **Password Policies:** Minimum 12 characters, password history of 12, maximum 3 login failures before lockout

---

## 11. Hardening Checklist

### Identity & Access (Items 1-10)

- [ ] **1.** Enforce MFA for all UI logins across all profiles
- [ ] **2.** Implement SSO for all non-admin users; maintain 2-3 break-glass admin accounts
- [ ] **3.** Restrict admin profiles to corporate IP ranges via Login IP Ranges
- [ ] **4.** Set Login Hours for non-admin profiles to business hours only
- [ ] **5.** Set session timeout to 2 hours or less; enable "Lock sessions to IP"
- [ ] **6.** Migrate from Profile-based permissions to Permission Set Groups
- [ ] **7.** Remove "Modify All Data" from all profiles except System Administrator
- [ ] **8.** Remove "View All Data" from all non-admin profiles
- [ ] **9.** Disable "API Enabled" on all profiles that do not require API access
- [ ] **10.** Audit and disable all inactive users (no login in 90+ days)

### Data Security (Items 11-18)

- [ ] **11.** Set OWD to **Private** for Opportunity, Lead, Case, and all objects with PII
- [ ] **12.** Audit sharing rules — remove overly broad rules granting org-wide access
- [ ] **13.** Conduct FLS audit on all PII/financial fields across all profiles and permission sets
- [ ] **14.** Enable Shield Platform Encryption for PII fields (Name, Email, Phone, CPF, SSN)
- [ ] **15.** Configure Data Mask for all non-production sandboxes
- [ ] **16.** Apply Data Classification labels to all custom fields containing sensitive data
- [ ] **17.** Disable "Grant Access Using Hierarchies" on objects with highly sensitive data
- [ ] **18.** Review and minimize Sharing Rule counts; remove stale sharing rules

### API & Integration (Items 19-22)

- [ ] **19.** Audit all Connected Apps — restrict OAuth scopes to minimum required
- [ ] **20.** Replace hardcoded credentials in Apex with Named Credentials
- [ ] **21.** Create dedicated API-only integration users per external system
- [ ] **22.** Set up API Usage Notifications at 70% and 90% thresholds

### Code Security (Items 23-26)

- [ ] **23.** Run PMD/Salesforce Code Analyzer on all Apex classes; fix all SOQL injection findings
- [ ] **24.** Ensure all Apex queries use `WITH USER_MODE`, `WITH SECURITY_ENFORCED`, or `stripInaccessible`
- [ ] **25.** Audit Visualforce pages for `escape="false"` usage; fix XSS vulnerabilities
- [ ] **26.** Enable Lightning Web Security (LWS) and test all custom LWC components

### Experience Cloud (Items 27-28)

- [ ] **27.** Harden all Guest User profiles — disable API, remove unnecessary object access
- [ ] **28.** Enable "Secure guest user record access" in Sharing Settings

### Monitoring & Compliance (Items 29-30)

- [ ] **29.** Configure Transaction Security policies for large data exports, new-country logins, bulk deletes
- [ ] **30.** Achieve Security Health Check score of **90% or higher**; schedule monthly reviews

---

## 12. Common Misconfigurations — Top 10 Salesforce Security Mistakes

### 1. Guest User Over-Permission (CRITICAL)

**Mistake:** Experience Cloud guest user profile retains default object access, exposing Accounts, Contacts, or custom objects to unauthenticated users.

**Fix:** Audit guest user profile OWD, object permissions, and sharing rules. Remove all access not explicitly required for public site functionality.

### 2. OWD Set to Public Read/Write on Sensitive Objects (HIGH)

**Mistake:** Opportunity, Lead, or Case OWD set to Public Read/Write, allowing all users to see and edit all records regardless of ownership.

**Fix:** Set OWD to Private. Use sharing rules and role hierarchy to grant access where needed.

### 3. Modify All Data / View All Data Over-Assignment (HIGH)

**Mistake:** Multiple profiles have "Modify All Data" or "View All Data" permissions, effectively bypassing all sharing and FLS controls.

**Fix:** Restrict to System Administrator profile only. Use object-level and field-level permissions for all other profiles.

### 4. Missing CRUD/FLS Enforcement in Apex (HIGH)

**Mistake:** Apex classes query and modify records without checking user permissions, allowing privilege escalation through custom code.

**Fix:** Add `WITH USER_MODE` or `WITH SECURITY_ENFORCED` to all SOQL queries. Use `stripInaccessible` for DML operations.

### 5. Hardcoded Credentials in Apex (CRITICAL)

**Mistake:** API keys, passwords, or tokens stored in Apex classes, Custom Settings, or Custom Labels visible to all admins.

**Fix:** Migrate to Named Credentials or External Credentials. Store secrets in Protected Custom Metadata if Named Credentials are not feasible.

### 6. No MFA Enforcement (HIGH)

**Mistake:** MFA not enforced for all users despite the February 2022 contractual requirement.

**Fix:** Enable MFA for all profiles. Deploy Salesforce Authenticator or TOTP apps. Create exceptions only for API-only users (who cannot use MFA).

### 7. Overly Permissive Connected Apps (MEDIUM)

**Mistake:** Connected Apps configured with `full` OAuth scope, relaxed IP restrictions, and "All users may self-authorize."

**Fix:** Restrict OAuth scopes to minimum needed. Enforce IP restrictions. Set to "Admin approved users are pre-authorized."

### 8. No Session IP Locking (MEDIUM)

**Mistake:** Session settings do not lock sessions to originating IP, allowing session token theft and reuse.

**Fix:** Enable "Lock sessions to the IP address from which they originated" in Session Settings.

### 9. Unmasked Sandbox Data (MEDIUM)

**Mistake:** Full-copy sandboxes contain production PII data without masking, accessible by developers and QA teams.

**Fix:** Implement Data Mask on all non-production sandboxes. Mask PII fields (name, email, phone, CPF/SSN, addresses).

### 10. No Setup Audit Trail Monitoring (MEDIUM)

**Mistake:** Setup Audit Trail exists but no one reviews it. Permission changes, profile modifications, and sharing rule updates go unnoticed.

**Fix:** Establish weekly review of Setup Audit Trail. Set up automated alerts for critical changes (permission escalation, sharing rule modifications, Connected App creation).

---

## Key Concepts

| Term | Definition |
|------|------------|
| Organization-Wide Defaults (OWD) | Baseline record access level for each object that applies to all users before sharing rules, role hierarchy, or manual sharing open access further |
| Field-Level Security (FLS) | Controls that determine which fields are visible and editable per profile or permission set, enforced in the UI but NOT automatically in Apex |
| Shield Platform Encryption | Salesforce add-on that encrypts data at rest using tenant-specific encryption keys, supporting deterministic and probabilistic encryption modes |
| Permission Set Group | A collection of permission sets that can be assigned as a single unit, with optional muting permission sets to suppress specific permissions |
| Security Health Check | Built-in Salesforce tool that compares org security settings against recommended baselines and produces a scored assessment |
| Transaction Security Policy | Configurable policies that monitor events in real-time and can block, notify, or require MFA when triggered by defined conditions |
| Lightning Web Security (LWS) | Modern browser-based JavaScript sandboxing for LWC components, replacing the legacy Locker Service with improved performance and standard compliance |
| Named Credential | Salesforce configuration that stores external endpoint URLs and authentication credentials securely, injecting auth headers at runtime |
| Guest User | Unauthenticated user profile used by Experience Cloud sites for public-facing pages, requiring strict permission lockdown |
| Event Monitoring | Shield feature providing 50+ event types for tracking user activity including logins, API calls, report exports, and Apex execution |

## Tools & Systems

- **Salesforce Security Health Check**: Built-in tool assessing org security settings against Salesforce baselines (Setup > Security > Health Check)
- **Salesforce Optimizer**: AppExchange tool identifying unused features, permission sprawl, and configuration drift
- **Salesforce Shield**: Add-on suite including Platform Encryption, Event Monitoring, and Field Audit Trail
- **Salesforce CLI (sf)**: Command-line interface for metadata retrieval, deployment, and static code analysis
- **PMD Apex Rules**: Open-source static analysis rules for detecting SOQL injection, CRUD violations, and XSS in Apex code
- **Salesforce Code Analyzer**: Official CLI-based scanner combining PMD, ESLint, and RetireJS for Apex and LWC analysis
- **CIS Salesforce Benchmark**: Prescriptive hardening guidance published by the Center for Internet Security
- **Privacy Center (Salesforce)**: Managed package for LGPD/GDPR compliance including data subject access requests and right-to-be-forgotten workflows

## Common Scenarios

### Scenario: Post-Acquisition Salesforce Org Security Assessment

**Context**: After acquiring a company that uses Salesforce, the security team needs to assess the org's security posture before integrating data or granting cross-org access.

**Approach**:
1. Run Security Health Check and export results — target score must be 90%+
2. Audit all profiles with "Modify All Data" or "View All Data" — restrict to System Admin only
3. Review OWD settings — ensure sensitive objects (Opportunity, Lead, Case) are set to Private
4. Verify MFA is enforced for all UI users
5. Audit all Connected Apps and integration users — identify unknown or orphaned integrations
6. Review Experience Cloud sites for guest user over-permissions
7. Run PMD/Code Analyzer on all Apex code for SOQL injection and CRUD/FLS violations
8. Check Shield Event Monitoring for anomalous login or data export patterns in the last 90 days
9. Produce a risk report with prioritized remediation backlog

**Pitfalls**: Acquired orgs often have technical debt in sharing rules (hundreds of rules accumulated over years). Profile cloning creates hidden permission sprawl — always audit cloned profiles individually. Integration users with "Modify All Data" are common in orgs without Named Credentials.

### Scenario: Experience Cloud Site Launch Security Review

**Context**: The team is launching a new customer-facing Experience Cloud portal and needs a security review before go-live.

**Approach**:
1. Audit guest user profile — remove all object and field access not explicitly required
2. Verify OWD is Private for all objects accessible on the site
3. Test unauthenticated access in incognito browser — attempt to access API endpoints, hidden pages, object records
4. Review all sharing rules that include the guest user or site member profiles
5. Validate CORS and CSP configurations — only allow required origins
6. Disable self-registration unless explicitly required; add CAPTCHA if enabled
7. Review all Apex controllers used by site pages for CRUD/FLS enforcement
8. Enable Transaction Security to monitor large data access from community users
9. Conduct a final penetration test (manual or automated) against the site URL

**Pitfalls**: Guest users can access records through sharing rules created before Spring '21 restrictions. Aura-enabled Apex controllers exposed to community pages run in system mode unless explicitly checked. The `@AuraEnabled` annotation makes methods callable from any authenticated community user — not just specific profiles.

## Output Format

```
Salesforce Platform Security Hardening Report
==============================================
Org: acme-corp (Production)
Org ID: 00D5g000007XXXXX
Audit Date: 2026-03-15
Edition: Enterprise Edition
Shield License: Active

SECURITY HEALTH CHECK:
  Current Score:                     72% (Target: >= 90%)
  HIGH Risk Settings:                6
  CRITICAL Risk Settings:            2
  MEDIUM Risk Settings:              11

IDENTITY & ACCESS:
  Total Active Users:                1,247
  Profiles with Modify All Data:     3 (recommended: 1)
  Profiles with View All Data:       5 (recommended: 1)
  Users without MFA:                 89
  Inactive users (90+ days):         134
  Integration users (API-only):      7
  SSO Enabled:                       Yes (Okta SAML)
  Session Timeout:                   4 hours (recommended: <= 2 hours)
  Login IP Restrictions (Admin):     Not configured (CRITICAL)

DATA SECURITY:
  OWD - Opportunity:                 Public Read/Write (should be Private)
  OWD - Lead:                        Public Read Only (should be Private)
  OWD - Case:                        Private (OK)
  Sharing Rules (total):             247 (review for stale rules)
  PII Fields without encryption:     23 (requires Shield remediation)
  Sandboxes without Data Mask:       4 of 5

API & INTEGRATION:
  Connected Apps:                    12
  Connected Apps with full scope:    3 (reduce to minimum scopes)
  Hardcoded credentials in Apex:     2 classes flagged
  Named Credentials in use:          8

CODE SECURITY:
  Apex classes scanned:              342
  SOQL Injection findings:           4 (CRITICAL)
  CRUD/FLS violations:               17 (HIGH)
  XSS findings:                      3 (HIGH)
  PMD rule violations (total):       42

EXPERIENCE CLOUD:
  Active community sites:            2
  Guest user with API access:        1 (CRITICAL - disable immediately)
  Guest user object access:          Account (Read), Contact (Read), Lead (Read/Create)

MONITORING:
  Event Monitoring:                  Active (Shield)
  Transaction Security Policies:     2 configured
  Setup Audit Trail:                 Active (default 180 days)
  Login History anomalies (30d):     12 failed brute-force patterns

CRITICAL FINDINGS:
  1. [CRITICAL] Guest user profile has API access enabled on Customer Portal
  2. [CRITICAL] 2 Apex classes contain hardcoded API credentials
  3. [CRITICAL] Opportunity OWD set to Public Read/Write
  4. [HIGH] 89 users without MFA enforcement
  5. [HIGH] 4 SOQL injection vulnerabilities in Apex controllers
  6. [HIGH] Admin profiles lack Login IP Range restrictions
  7. [HIGH] 17 Apex classes missing CRUD/FLS enforcement
  8. [MEDIUM] Session timeout set to 4 hours (reduce to 2 hours)
  9. [MEDIUM] 4 sandboxes lack Data Mask configuration
  10. [MEDIUM] 3 Connected Apps with overly broad OAuth scopes

REMEDIATION PRIORITY:
  P0 (Immediate):  Items 1-3 (data exposure risk)
  P1 (This Sprint): Items 4-7 (privilege escalation risk)
  P2 (Next Sprint): Items 8-10 (defense-in-depth)
```
