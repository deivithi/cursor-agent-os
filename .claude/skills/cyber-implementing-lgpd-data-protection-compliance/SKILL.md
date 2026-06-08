---
name: implementing-lgpd-data-protection-compliance
description: Brazil's Lei Geral de Protecao de Dados (LGPD - Law 13.709/2018) is the comprehensive data protection regulation governing the collection, processing, storage, and transfer of personal data in Brazil. This skill covers implementing technical and organizational controls for LGPD compliance, including data mapping, consent management, DPIA (RIPD), data subject rights automation, DPO (Encarregado) obligations, ANPD breach reporting, and Salesforce-specific privacy configurations.
domain: cybersecurity
subdomain: compliance-governance
tags: [compliance, governance, lgpd, brazil, data-protection, privacy, anpd, encarregado, ripd, consent-management, salesforce, latin-america, personal-data, sensitive-data]
version: "1.0"
author: deivithi
license: Apache-2.0
---
# Implementing LGPD Data Protection Compliance

## Overview
The Lei Geral de Protecao de Dados Pessoais (LGPD), enacted as Law 13.709/2018 and effective since September 2020, is Brazil's comprehensive data protection framework. It applies to any organization — regardless of location — that processes personal data of individuals located in Brazil, or where the data processing itself occurs in Brazil. The Autoridade Nacional de Protecao de Dados (ANPD) is the supervisory authority responsible for enforcement.

This skill covers the end-to-end implementation of LGPD compliance: legal basis mapping, technical controls, data subject rights workflows, RIPD (Data Protection Impact Reports), breach notification procedures, and platform-specific configurations for Salesforce environments.

## Prerequisites
- Understanding of Brazilian data protection law and its territorial scope (Art. 3)
- Knowledge of personal data processing activities within the organization
- Familiarity with data architecture, databases, CRM systems (especially Salesforce)
- Understanding of data flows including international transfers
- Awareness of ANPD resolutions and regulatory guidance

## Core Concepts

### LGPD Foundational Principles (Art. 6)

| Principle | Description |
|-----------|-------------|
| Finalidade (Purpose) | Processing for legitimate, specific, explicit purposes informed to the data subject |
| Adequacao (Adequacy) | Processing compatible with the stated purposes |
| Necessidade (Necessity) | Limited to the minimum data required for the purpose (data minimization) |
| Livre Acesso (Free Access) | Easy and free consultation about the form and duration of processing |
| Qualidade dos Dados (Data Quality) | Accuracy, clarity, relevance, and currency of data |
| Transparencia (Transparency) | Clear, precise, and accessible information about processing |
| Seguranca (Security) | Technical and administrative measures to protect personal data |
| Prevencao (Prevention) | Measures to prevent damage from data processing |
| Nao Discriminacao (Non-Discrimination) | Processing cannot be used for unlawful discriminatory purposes |
| Responsabilizacao e Prestacao de Contas (Accountability) | Demonstration of effective compliance measures |

### Legal Bases for Processing (Art. 7)

| Legal Basis | Article | Use Case |
|-------------|---------|----------|
| Consent | Art. 7, I | Marketing communications, non-essential cookies |
| Legal obligation | Art. 7, II | Tax records, employment law compliance |
| Public administration | Art. 7, III | Public policy execution by government bodies |
| Research by research body | Art. 7, IV | Academic or statistical research (anonymized when possible) |
| Contract execution | Art. 7, V | Order fulfillment, service delivery |
| Exercise of rights in judicial/arbitral proceedings | Art. 7, VI | Litigation support, regulatory defense |
| Protection of life or physical safety | Art. 7, VII | Emergency health situations |
| Health protection | Art. 7, VIII | Health procedures by health professionals or authorities |
| Legitimate interest | Art. 7, IX | Fraud prevention, security, CRM analytics (requires LIA) |
| Credit protection | Art. 7, X | Credit scoring and financial risk assessment |

> **Important:** Sensitive personal data (Art. 11) has a more restrictive set of legal bases. Legitimate interest and credit protection do NOT apply to sensitive data.

### Key LGPD Articles and Technical Implications

| Article | Requirement | Technical Implication |
|---------|-------------|----------------------|
| Art. 5 | Definitions (personal data, sensitive data, anonymization) | Data classification taxonomy; anonymization pipelines |
| Art. 6 | Processing principles (10 principles) | Privacy-by-design architecture; data minimization at collection |
| Art. 7 | Legal bases for processing | Consent management platform; legal basis registry per processing activity |
| Art. 8 | Consent requirements (free, informed, unambiguous) | Granular consent UI; audit trail; easy withdrawal mechanism |
| Art. 11 | Sensitive data processing (health, biometrics, religion, etc.) | Enhanced encryption; stricter access controls; separate storage |
| Art. 12-14 | Information and transparency to data subjects | Privacy notices; layered consent; clear data collection forms |
| Art. 15-16 | Termination of processing and data deletion | Automated retention policies; deletion cascades across systems |
| Art. 17-22 | Data subject rights (18 rights enumerated in Art. 18) | DSR portal; automated workflows; SLA tracking |
| Art. 33-36 | International data transfers | Transfer impact assessments; SCCs; adequacy verification |
| Art. 37-39 | Data Protection Impact Report (RIPD) | RIPD templates; risk scoring; ANPD submission workflow |
| Art. 41 | DPO / Encarregado appointment | Public contact channel; ANPD registration |
| Art. 46 | Security measures (technical and administrative) | Encryption, access controls, audit logs, DLP |
| Art. 48 | Breach notification to ANPD | Incident response playbook; 72-hour notification workflow |
| Art. 52 | Administrative sanctions | Compliance monitoring dashboard; remediation tracking |

### Data Subject Rights (Art. 18)

| Right | Description | SLA Recommendation |
|-------|-------------|-------------------|
| Confirmation of processing | Confirm whether personal data is being processed | 15 days |
| Access to data | Obtain a complete copy of personal data held | 15 days |
| Correction of incomplete/inaccurate data | Update or correct personal data | 15 days |
| Anonymization, blocking, or deletion | Of unnecessary or excessive data, or non-compliant processing | 15 days |
| Data portability | Transfer data to another service provider (per ANPD regulation) | 15 days |
| Deletion of data processed with consent | Remove data when consent is withdrawn | 15 days |
| Information on shared data | Know which public and private entities received the data | 15 days |
| Information on consent denial | Be informed about the consequences of not providing consent | Immediate |
| Revocation of consent | Withdraw consent at any time via free and easy mechanism | Immediate |
| Opposition to processing | Object to processing that violates LGPD provisions | 15 days |
| Review of automated decisions | Request human review of decisions made solely by automated means | 15 days |

## LGPD vs GDPR Comparison

| Aspect | LGPD (Brazil) | GDPR (EU) |
|--------|---------------|-----------|
| Law | Lei 13.709/2018 | Regulation (EU) 2016/679 |
| Effective Date | September 18, 2020 (sanctions from August 2021) | May 25, 2018 |
| Supervisory Authority | ANPD (Autoridade Nacional de Protecao de Dados) | National DPAs (e.g., CNIL, ICO, BfDI) |
| Territorial Scope | Processing of data of individuals in Brazil, or processing in Brazil | Processing of data of individuals in EU, or by EU-established entities |
| Legal Bases | 10 legal bases (Art. 7) | 6 legal bases (Art. 6) |
| Consent Standard | Free, informed, unambiguous (written or other means) | Freely given, specific, informed, unambiguous |
| DPO Requirement | Encarregado required for all controllers (ANPD may simplify for SMEs) | Required for public bodies and large-scale processing |
| DPO Qualifications | No formal qualification requirement | No formal requirement but must have expert knowledge |
| Breach Notification | "Reasonable time" to ANPD (ANPD recommends 2 business days; 72h is best practice) | 72 hours to supervisory authority |
| DPIA Equivalent | RIPD (Relatorio de Impacto a Protecao de Dados Pessoais) | DPIA (Data Protection Impact Assessment) |
| International Transfers | Adequacy, SCCs, BCRs, specific consent, cooperation agreements | Adequacy, SCCs, BCRs, derogations |
| Sensitive Data | Race, religion, politics, union, health, sex life, genetics, biometrics | Race, politics, religion, union, health, sex life, genetics, biometrics |
| Children's Data | Requires specific and prominent consent from parent/guardian (Art. 14) | Requires parental consent for ISS (Art. 8), age varies by member state |
| Maximum Fine | 2% of revenue in Brazil (per infraction), capped at R$50 million | 4% of global annual turnover or EUR 20 million |
| Right to Explanation | Yes — review of automated decisions (Art. 20) | Limited — right to meaningful information about logic (Art. 22) |
| Data Portability | Yes, pending ANPD regulation on format | Yes, structured, machine-readable format |

## Implementation Steps

### Phase 1: Data Mapping and Inventory (Weeks 1-6)

1. **Create comprehensive data inventory:**
   - What personal data is collected (name, CPF, email, IP, cookies, biometrics, health data)
   - Data classification: personal data vs. sensitive personal data (Art. 5, II)
   - From whom: customers, employees, leads, partners, website visitors
   - Purpose and legal basis for each processing activity (Art. 7 mapping)
   - Storage locations: Salesforce orgs, databases, cloud storage, third-party systems
   - Data flows: internal systems, external processors, international transfers
   - Retention periods per data category
   - Security measures applied per data store

2. **Build Records of Processing Activities (Art. 37, ANPD Resolution):**
   ```
   Processing Activity Record Template:
   ├── Activity Name
   ├── Controller Identity (CNPJ, contact)
   ├── Encarregado (DPO) Contact
   ├── Categories of Data Subjects
   ├── Categories of Personal Data
   ├── Sensitive Data Flag (Y/N)
   ├── Legal Basis (Art. 7 or Art. 11)
   ├── Purpose of Processing
   ├── Data Recipients (shared with)
   ├── International Transfers (Y/N, destination, mechanism)
   ├── Retention Period
   ├── Security Measures Applied
   └── RIPD Required (Y/N)
   ```

3. **Map cross-border data transfers:**
   - Identify all transfers outside Brazil (cloud providers, SaaS, group companies)
   - Verify adequacy decisions by ANPD
   - Prepare Standard Contractual Clauses (SCCs) or other transfer mechanisms (Art. 33)
   - Document Transfer Impact Assessments

4. **Identify high-risk processing requiring RIPD (Art. 38):**
   - Large-scale processing of sensitive data
   - Automated decision-making (credit scoring, profiling)
   - Systematic monitoring of public areas
   - Processing of children's data

### Phase 2: Gap Analysis and Risk Assessment (Weeks 7-10)

1. **Assess current state against LGPD requirements:**
   - Map each LGPD article to current controls
   - Identify gaps in technical and organizational measures
   - Evaluate consent collection mechanisms
   - Review privacy notices and transparency

2. **Perform RIPD for high-risk processing activities:**
   ```
   RIPD (Relatorio de Impacto) Structure:
   ├── 1. Description of Processing
   │   ├── Nature, scope, context, purpose
   │   ├── Data categories and volume
   │   └── Technologies used
   ├── 2. Necessity and Proportionality Assessment
   │   ├── Legal basis justification
   │   ├── Data minimization analysis
   │   └── Purpose limitation verification
   ├── 3. Risk Assessment
   │   ├── Risks to data subjects
   │   ├── Likelihood and severity matrix
   │   └── Specific risks (discrimination, financial loss, reputational harm)
   ├── 4. Mitigation Measures
   │   ├── Technical controls (encryption, pseudonymization, access control)
   │   ├── Organizational controls (policies, training, audits)
   │   └── Residual risk evaluation
   ├── 5. Stakeholder Consultation
   │   ├── Encarregado (DPO) opinion
   │   └── Data subject input (when applicable)
   └── 6. Conclusion and Approval
       ├── Approved / Conditionally approved / Rejected
       └── ANPD consultation required (Y/N)
   ```

3. **Legitimate Interest Assessment (LIA) for Art. 7, IX:**
   - Purpose test: Is the interest legitimate?
   - Necessity test: Is processing necessary for that interest?
   - Balancing test: Do data subject rights override the interest?
   - Safeguards: What measures mitigate impact?

4. **Evaluate data subject rights handling capabilities:**
   - Can the organization respond within 15 days?
   - Are all 11 rights technically supported?
   - Is there a centralized intake mechanism?

### Phase 3: Technical Controls Implementation (Weeks 11-24)

1. **Encryption:**
   - Data at rest: AES-256 for databases, file systems, backups
   - Data in transit: TLS 1.2+ for all personal data transfers
   - Field-level encryption for CPF, health data, biometrics
   - Key management: HSM or cloud KMS with rotation policies

2. **Pseudonymization and Anonymization:**
   - Tokenization of direct identifiers (CPF, RG, name)
   - Pseudonymization keys stored separately from data
   - Anonymization pipelines for analytics (Art. 12 — anonymized data is outside LGPD scope)
   - Validate irreversibility of anonymization techniques

3. **Access Controls:**
   - Role-Based Access Control (RBAC) aligned to processing purposes
   - Principle of least privilege for personal data access
   - Multi-Factor Authentication (MFA) for all systems with personal data
   - Privileged Access Management (PAM) for administrators
   - Quarterly access reviews with evidence retention

4. **Audit Logging and Monitoring:**
   - Log all access to personal data (who, what, when, why)
   - Log consent changes, DSR actions, data modifications
   - SIEM integration for anomalous access detection
   - Log retention: minimum 5 years for compliance evidence
   - Tamper-proof audit trails

5. **Data Minimization and Retention:**
   - Collection limits enforced at application layer
   - Default privacy settings (privacy by default)
   - Automated retention enforcement with deletion workflows
   - Backup purge procedures aligned to retention policies

6. **Consent Management Platform:**
   - Granular consent collection per purpose (Art. 8)
   - Separate consent for sensitive data processing (Art. 11)
   - Specific and prominent consent for children's data (Art. 14)
   - Easy withdrawal mechanism (as easy as giving consent)
   - Consent versioning and full audit trail
   - Consent receipt storage with timestamp, version, and scope

7. **Data Subject Request (DSR) Automation:**
   ```
   DSR Workflow:
   ├── 1. Intake
   │   ├── Web portal / email / phone / in-person
   │   ├── Identity verification (CPF, email, photo ID)
   │   └── Request classification (access, deletion, portability, etc.)
   ├── 2. Triage
   │   ├── Validate request against legal requirements
   │   ├── Check for exemptions (legal obligation, litigation hold)
   │   └── Assign to data steward
   ├── 3. Execution
   │   ├── Search all systems for data subject's personal data
   │   ├── Execute requested action (export, delete, correct, anonymize)
   │   └── Propagate to processors and shared entities
   ├── 4. Response
   │   ├── Deliver response within 15-day SLA
   │   ├── If complex: communicate timeline extension with justification
   │   └── Provide response in clear, accessible format
   └── 5. Documentation
       ├── Log request, actions taken, response, and timeline
       └── Retain evidence for accountability (Art. 6, X)
   ```

8. **Breach Detection and Response:**
   - Data Loss Prevention (DLP) for personal data exfiltration
   - Database Activity Monitoring (DAM)
   - Endpoint Detection and Response (EDR)
   - Network traffic analysis for data leakage

### Phase 4: Organizational Controls (Weeks 11-24)

1. **Appoint Encarregado / DPO (Art. 41):**
   - Required for all controllers (ANPD may issue simplified rules for SMEs)
   - Responsibilities:
     - Accept complaints and communications from data subjects and ANPD
     - Provide guidance to employees and contractors on data protection
     - Execute controller directives on data protection matters
     - Perform other duties as determined by the controller or by regulation
   - Public identity and contact information must be disclosed (website, ANPD registry)

2. **Develop policies and procedures:**
   - Data Protection Policy (overarching governance)
   - Privacy Notice (external-facing, per Art. 9)
   - Data Retention Policy with schedules per data category
   - Incident Response Plan with LGPD-specific procedures
   - International Data Transfer Policy
   - Consent Management Policy
   - Data Subject Rights Handling Procedure

3. **Breach notification procedure (Art. 48):**
   ```
   Breach Notification Timeline:
   ├── T+0h: Incident detected — activate IR team
   ├── T+1h: Initial assessment — scope, affected data, data subjects
   ├── T+4h: Classification — risk to data subjects (high/medium/low)
   ├── T+24h: Internal report to Encarregado and leadership
   ├── T+48h: ANPD notification preparation
   ├── T+72h: ANPD notification (best practice deadline)
   │   Required content (Art. 48):
   │   ├── Nature of affected personal data
   │   ├── Information on affected data subjects
   │   ├── Technical and security measures applied
   │   ├── Risks related to the incident
   │   ├── Reasons for delay (if applicable)
   │   └── Measures taken or to be taken to mitigate effects
   ├── T+72h+: Data subject notification (if risk is significant)
   └── Post-incident: Root cause analysis, remediation, lessons learned
   ```

4. **Training and awareness:**
   - Annual privacy training for all employees
   - Role-specific training for data handlers
   - Developer training on privacy by design
   - Phishing awareness (data breach prevention)

5. **Vendor and processor management:**
   - Data Processing Agreements (DPAs) with all processors (Art. 39)
   - Processor security assessment before onboarding
   - Annual processor compliance review
   - Contractual clauses: purpose limitation, sub-processor controls, breach notification, audit rights

### Phase 5: Salesforce-Specific LGPD Configuration

1. **Salesforce Privacy Center:**
   - Configure data retention and deletion policies per object
   - Set up right-to-be-forgotten workflows (Account, Contact, Lead, Case)
   - Implement data portability export (structured JSON/CSV)
   - Schedule automated anonymization jobs for expired retention

2. **Consent Management in Salesforce:**
   - Enable Individual object for consent tracking
   - Configure Contact Point Consent (email, phone, web)
   - Map consent to Communication Subscriptions
   - Implement consent checks in Process Builder / Flow before marketing actions
   - Track consent source, timestamp, and version on Individual record

3. **Salesforce Shield:**
   - **Platform Encryption:** Encrypt sensitive fields (CPF, health data, financial data)
   - **Event Monitoring:** Track field-level access, data exports, login anomalies
   - **Field Audit Trail:** Retain field history for up to 10 years for compliance evidence

4. **Data Mask (Sandbox):**
   - Mask CPF, name, email, phone in sandbox environments
   - Ensure non-production environments do not contain real personal data
   - Configure masking rules for all PII fields before sandbox refresh

5. **Salesforce Access Controls:**
   - Field-Level Security (FLS) for personal and sensitive data fields
   - Org-Wide Defaults (OWD) set to Private for objects containing personal data
   - Sharing Rules scoped to legitimate business need
   - Permission Sets for LGPD-specific roles (DPO, Data Steward, DSR Handler)
   - Login IP Ranges and Session Settings for enhanced security

6. **Marketing Cloud LGPD Compliance:**
   - Honor unsubscribe and consent withdrawal in real-time
   - Suppress lists for data subjects who exercised deletion rights
   - Consent synchronization between Sales Cloud and Marketing Cloud
   - Journey Builder exit criteria based on consent status

### Phase 6: Documentation and Compliance Evidence (Weeks 25-30)

1. Finalize Records of Processing Activities
2. Complete all RIPDs and archive with version control
3. Document technical and organizational measures inventory
4. Create compliance evidence repository:
   - Consent records with audit trails
   - DSR logs and response evidence
   - Training completion records
   - Processor DPAs and assessments
   - Breach register (even if no breaches occurred)
5. Prepare for ANPD audit readiness

### Phase 7: Ongoing Compliance (Continuous)

1. Quarterly review of processing activities and legal bases
2. Annual data mapping refresh
3. RIPD review when processing activities change
4. Monthly DSR metrics and SLA monitoring
5. Breach response readiness drills (tabletop exercises)
6. ANPD regulatory updates monitoring and impact assessment
7. Annual privacy program maturity assessment

## Sanctions and Penalties (Art. 52)

| Sanction | Description |
|----------|-------------|
| Warning | With deadline for corrective measures |
| Simple fine | Up to 2% of revenue in Brazil (per infraction), capped at R$50 million per infraction |
| Daily fine | Compounding daily fine to compel compliance |
| Publicization | Public disclosure of the infraction after investigation and confirmation |
| Blocking | Blocking of personal data involved in the infraction |
| Deletion | Deletion of personal data involved in the infraction |
| Partial suspension | Suspension of database processing for up to 6 months (extendable) |
| Prohibition | Partial or total prohibition of processing activities |

> **Note:** ANPD considers the following when determining sanctions: gravity, good faith, cooperation, adoption of security policies, promptness of corrective measures, and proportionality.

### Common Violations

| Violation | Risk Level | Example |
|-----------|-----------|---------|
| Processing without legal basis | Critical | Sending marketing emails without consent |
| Inadequate security measures | High | Unencrypted CPF data in databases |
| Failure to appoint Encarregado | High | No public DPO contact published |
| Missing or inadequate privacy notice | High | No transparency about data processing |
| Failure to honor DSR within deadline | High | Ignoring deletion or access requests |
| International transfer without safeguards | High | Sending data to foreign processor without SCCs |
| Processing sensitive data without proper basis | Critical | Health data processed under legitimate interest |
| No consent for children's data from parent | Critical | Collecting minor's data without parental consent |
| Failure to notify breach to ANPD | High | Concealing or delaying breach notification |

## Technical Controls Checklist

```
LGPD Technical Controls Assessment:
├── Data Classification
│   □ Personal data fields identified and classified
│   □ Sensitive personal data fields identified with enhanced controls
│   □ Data classification taxonomy documented and applied
│   □ Anonymized vs. pseudonymized data clearly distinguished
│
├── Encryption
│   □ AES-256 encryption at rest for all personal data stores
│   □ TLS 1.2+ for all data in transit
│   □ Field-level encryption for CPF, health, biometric data
│   □ Key management with rotation and HSM/KMS
│   □ Encrypted backups with tested restore procedures
│
├── Access Controls
│   □ RBAC implemented aligned to processing purposes
│   □ Least privilege enforced for personal data access
│   □ MFA enabled for all systems processing personal data
│   □ Privileged access management for administrators
│   □ Quarterly access reviews with evidence
│   □ Segregation of duties for sensitive operations
│
├── Audit and Monitoring
│   □ Access logging for all personal data (read/write/delete)
│   □ Consent change audit trail
│   □ DSR action logging
│   □ SIEM integration with alerting for anomalous access
│   □ DLP controls for personal data exfiltration
│   □ Log integrity protection (tamper-proof)
│
├── Data Lifecycle
│   □ Automated retention enforcement per data category
│   □ Deletion workflows across primary and backup systems
│   □ Anonymization pipelines for analytics
│   □ Consent expiry and renewal tracking
│   □ Data minimization enforced at collection points
│
├── Consent Management
│   □ Granular consent per purpose
│   □ Consent withdrawal as easy as granting
│   □ Consent audit trail with timestamp and version
│   □ Separate consent for sensitive data
│   □ Parental consent mechanism for children's data
│
├── Breach Preparedness
│   □ Incident response plan with LGPD-specific procedures
│   □ 72-hour notification workflow tested
│   □ ANPD notification template prepared
│   □ Data subject notification template prepared
│   □ Breach register maintained
│   □ Tabletop exercises conducted quarterly
│
└── International Transfers
    □ All transfers outside Brazil mapped
    □ Transfer mechanisms in place (SCCs, adequacy, consent)
    □ Transfer Impact Assessments completed
    □ Processor obligations documented in DPAs
```

## Integration with Existing Compliance Frameworks

| Framework | LGPD Overlap | Integration Approach |
|-----------|-------------|---------------------|
| ISO 27001 | Annex A controls map to Art. 46 security requirements | Map ISO 27001 controls to LGPD articles; use ISO risk assessment for RIPD |
| ISO 27701 | Privacy-specific extension of ISO 27001 | Directly supports LGPD compliance; use as implementation framework |
| SOC 2 | Trust Services Criteria (Security, Availability, Confidentiality, Privacy) | Map SOC 2 Privacy criteria to LGPD requirements; leverage SOC 2 evidence |
| GDPR | ~80% overlap in principles and controls | Extend GDPR program to cover LGPD-specific requirements (10 legal bases, Encarregado, ANPD) |
| PCI DSS | Data protection controls for cardholder data | Leverage PCI DSS encryption and access controls for financial personal data |
| NIST CSF | Identify, Protect, Detect, Respond, Recover | Map NIST CSF functions to LGPD Art. 46 and Art. 48 requirements |
| CIS Controls | Technical security controls | Use CIS Controls as baseline for Art. 46 technical measures |

### LGPD-to-ISO 27001 Control Mapping (Key Areas)

| LGPD Article | ISO 27001 Control | Description |
|-------------|-------------------|-------------|
| Art. 46 (Security) | A.8 (Asset Management), A.9 (Access Control) | Technical and organizational security measures |
| Art. 47 (Security by Design) | A.14 (System Development) | Security in development and support processes |
| Art. 48 (Breach Notification) | A.16 (Incident Management) | Information security incident management |
| Art. 49 (Systems Design) | A.14.1 (Security Requirements) | Privacy by design in system architecture |
| Art. 46 (Encryption) | A.10 (Cryptography) | Cryptographic controls for data protection |
| Art. 6, X (Accountability) | A.18 (Compliance) | Compliance with legal and contractual requirements |

## Key Artifacts
- Records of Processing Activities (ROPA / Registro de Atividades de Tratamento)
- RIPD (Relatorio de Impacto a Protecao de Dados Pessoais)
- Legitimate Interest Assessment (LIA) documents
- Data Processing Agreements (DPAs) with processors
- Privacy Notices (Aviso de Privacidade)
- Consent Records and Audit Trails
- Breach Response Procedures and Breach Register
- Data Subject Request Handling Procedures and Logs
- International Data Transfer Mechanisms (SCCs, TIAs)
- Technical and Organizational Measures Documentation
- Encarregado (DPO) Appointment and Public Disclosure
- Training Records and Awareness Materials

## Common Pitfalls
- Assuming GDPR compliance automatically equals LGPD compliance (LGPD has 10 legal bases vs. 6, different DPO rules, different penalty structure)
- Treating the Encarregado role as purely ceremonial without operationalizing the responsibilities
- Failing to obtain specific parental consent for children's data (Art. 14)
- Using legitimate interest as legal basis for sensitive data processing (not permitted under Art. 11)
- Incomplete data mapping that misses legacy systems, shadow IT, or third-party integrations
- Not implementing consent withdrawal mechanisms that are as easy as granting consent
- Ignoring ANPD resolutions and regulatory guidance that supplement the law
- Relying solely on consent when other legal bases (contract, legal obligation) are more appropriate
- Not testing the breach notification workflow against the recommended 72-hour timeline
- Failing to conduct RIPDs for high-risk processing activities before they begin
- Overlooking international transfer requirements for cloud-hosted SaaS platforms
- Not maintaining a breach register (required even when no breaches have occurred)

## References
- LGPD Full Text (Lei 13.709/2018): https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm
- ANPD Official Website: https://www.gov.br/anpd/
- ANPD Security Guide for Personal Data Processing Agents: https://www.gov.br/anpd/pt-br/documentos-e-publicacoes
- ANPD Resolution CD/ANPD No. 2/2022 (Sanctions Regulation)
- ANPD Resolution CD/ANPD No. 4/2023 (Dosimetry of Sanctions)
- ANPD Guide on Breach Notification
- ANPD Guide on Cookies and Data Protection
- ISO/IEC 27701:2019 — Privacy Information Management System
- Salesforce Privacy Center Documentation: https://help.salesforce.com/s/articleView?id=sf.privacy_center.htm
- Salesforce Shield Documentation: https://help.salesforce.com/s/articleView?id=sf.shield.htm
- IAPP LGPD Resource Center: https://iapp.org/resources/topics/lgpd/
