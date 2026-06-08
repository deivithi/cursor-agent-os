# Permission Pipeline Design for HarnessQwen-v6.5 (v1.1 - Refined)

**Status**: Refined Design  
**Version**: 1.1 — May 2026  
**Previous Version**: v1.0 (initial design)  
**Refinements Applied**: All 8 identified gaps + additional hardening considerations.

---

## 1. Executive Summary

This document defines a practical, security-first 3-Gate Permission Pipeline for HarnessQwen-v6.5.

The goal is to move from a system that only does **post-facto auditing** to one that also has strong **pre-execution controls**, while preserving the existing strengths (excellent externalization, structured review, and real E2E discipline).

**Core Model**: Hard Deny → Contextual Risk Rules → Human Confirmation

---

## 2. Scope (Refined)

### In Scope (Phase 1 – Mandatory)

- **Bash / Shell execution** (highest risk)
- **File system writes and deletions** (create, write, move, delete, chmod, chown)
- **Network requests** that can exfiltrate data or download+execute (curl, wget, requests with large payloads)

### Out of Scope (Initial Phase)

- Pure read operations (unless they target highly sensitive files)
- LLM calls themselves
- Internal Python logic (for now)

**Rationale**: We prioritize the attack surface that can cause the most damage with the least friction.

---

## 3. The 3-Gate Model (Detailed)

### Gate 1: Hard Deny List (Non-Negotiable)

Executed first. No bypass in normal operation.

**Initial Deny Categories**:

**Destructive / Irreversible**
- `rm -rf /`, `rm -rf ~`, `rm -rf $HOME`, `rm -rf .`
- `dd if=/dev/zero of=/dev/sd*`
- `mkfs`, `fdisk`, `parted`, `wipefs`

**Privilege Escalation**
- `sudo`, `su`, `doas`, `pkexec`

**Download + Execute**
- `curl * | bash`, `wget * | sh`, `bash <(curl ...)`, `python -c "import urllib.request; exec(urllib...)"`

**Mass Permission Changes**
- `chmod -R 777`, `chmod 777 /`

**System Modification**
- Direct writes to `/etc`, `/boot`, `/sys`, `/proc` (with limited exceptions)

**Configuration**:
- Stored in `utils/permission_config.py` (or JSON for easier editing later)
- Must be versioned together with the harness

**Bypass Policy**:
- Only allowed via explicit `--dangerous-override` flag + forced extra logging + highlighted warning in the final Sprint Review.

### Gate 2: Contextual Risk Rules + Scoring

If not hard-denied, the command goes through risk evaluation.

**Risk Factors** (examples):

- Target path is outside allowed workspaces
- Command modifies sensitive files (`.env`, `credentials`, `*.pem`, `id_rsa`, `.git/config`)
- Large outbound data transfer patterns
- Command contains obfuscation (base64, eval, etc.)
- Running as high-privilege user unexpectedly

**Risk Levels**:
- `LOW` → Proceed
- `MEDIUM` → Log + proceed (with warning)
- `HIGH` → Require Gate 3 (confirmation)
- `CRITICAL` → Block + escalate (treated almost like hard deny)

**Configuration Governance**:
- Rules should have comments explaining *why* each rule exists.
- Major changes to rules require review (similar to LICOES updates).

### Gate 3: Human Confirmation (Interactive)

When risk is HIGH or CRITICAL.

**Recommended UX**:

The agent should present to the user:
1. The exact command it wants to run
2. The risk assessment and why it triggered
3. What is the intended goal of this action (the agent must justify)
4. Options: Approve once / Approve for this task / Deny / Ask for safer alternative

**Implementation Note**:
This should be a dedicated function (`ask_permission_confirmation`) that pauses execution cleanly.

---

## 4. Logging & Audit Integration (Critical Refinement)

Every permission decision **must** be logged in a structured way that feeds the existing review system.

**Minimum Log Fields**:
- Timestamp
- Command (full)
- Risk level + triggered rules
- Decision (Denied / Approved / User Approved / User Denied)
- Context / Task ID (when available)
- User justification (if provided)

These logs should be:
- Written to a dedicated file (e.g. `.harness/logs/permission.log`)
- Automatically included in the `Sprint Review Final` process
- Difficult for the agent to tamper with (ideally append-only or external)

---

## 5. Architecture & Implementation

### Recommended Structure

```
utils/
├── permission.py                 # Core logic (check_permission)
├── permission_config.py          # Deny list + rules + comments
├── permission_logger.py          # Structured logging
└── permission_ui.py              # User confirmation interface (interactive)

.harness/
├── permissions/
│   ├── deny_list.json            # Machine-readable (future)
│   └── rules.yaml                # Human-readable with explanations
└── logs/
    └── permission.log
```

### Integration Points

All risky tools must call the permission system **before** executing the real action:

- Bash execution script
- File write / delete helpers
- Any future network exfiltration tools

---

## 6. Profiles (Future but Planned)

We should support different operating modes:

- `strict` → Maximum safety (default for important work)
- `balanced` → Good security with reasonable friction
- `research` → More permissive + heavy logging (requires explicit activation)

Each profile can have different deny lists and risk thresholds.

---

## 7. Self-Protection of the Permission System

**Risk**: An attacker could try to modify `permission.py` or the config files.

**Mitigations (Minimum)**:

- The permission module should validate its own configuration at load time (basic integrity checks).
- Consider running the permission checks from a more restricted context when possible.
- All changes to permission files should be visible in git history and reviewed.

---

## 8. Open Decisions (with Recommendations)

| Decision | Recommendation | Rationale |
|----------|----------------|---------|
| Should confirmation be blocking? | Yes (interactive) in normal use | Safety > speed for high-risk actions |
| YOLO / bypass mode? | Yes, but heavily logged and highlighted in final review | Needed for research and debugging, but must be visible |
| How to handle fully autonomous runs? | Use "balanced" profile + very strict deny list + no interactive gate (fail closed) | In autonomous mode, better to block than to proceed unsafely |
| Versioning of rules | Treat permission config as code (versioned + reviewed) | Same discipline as LICOES |

---

## 9. Phased Rollout Plan (Updated)

**Phase 1 (7–14 days)** — Minimum Viable Safety
- Gate 1 (Hard Deny) for bash + basic file writes
- Basic structured logging
- Simple interactive confirmation for HIGH risk

**Phase 2 (15–45 days)**
- Full Gate 2 (risk scoring)
- Better confirmation UX with agent justification
- Integration with Sprint Review Final
- First version of permission profiles

**Phase 3 (Later)**
- Self-protection improvements
- Config governance process
- Advanced rules (obfuscation detection, behavioral anomalies)

---

## 10. Success Criteria for This Feature

We will consider the Permission Pipeline successful when:

- Destructive commands are reliably blocked before execution
- Risky actions outside the workspace trigger appropriate friction
- All permission decisions are visible in the final review process
- The system does not create excessive friction for normal, safe work

---

**This v1.1 version incorporates all major refinements identified in the review process.**

It is now significantly more complete, realistic, and aligned with the security ambitions of the broader HARNESS standard.
