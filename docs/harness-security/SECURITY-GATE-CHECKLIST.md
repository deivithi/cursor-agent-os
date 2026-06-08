# Security Gate Checklist for Agent Harnesses

**Purpose**: Mandatory review that must be passed before a harness (or major update to the standard) can be considered production-grade or recommended.

**Version**: 1.0 — May 2026  
**Based on**: The 10 Security & Professionalism Primitives in HARNESS.md

## Instructions

For every new harness or significant change:
1. Answer each item honestly.
2. Any "No" in the Critical column must be resolved or explicitly accepted with compensating controls and recorded rationale.
3. This checklist should be stored with the project (e.g. in `.harness/security-review.md`).

---

### Critical (Must be Yes or have strong compensating controls)

| # | Control | Status | Evidence / Notes |
|---|---------|--------|------------------|
| 1 | Does the harness implement (or clearly document) a **3-Gate Permission Pipeline** before executing tools? |  |  |
| 2 | Is there a **Sanitization Layer** for inbound content (Unicode, attachments, links, skills)? |  |  |
| 3 | Are **Skills, Rules, and Hooks** treated with supply-chain hygiene (review, provenance, scanning)? |  |  |
| 4 | Do Hooks support **runtime controls** (profiles, selective disablement)? |  |  |
| 5 | Is there an explicit **Memory Threat Model** and policies for rotation/reset? |  |  |
| 6 | Does the harness follow **Least Agency** principles by default? |  |  |

### High Priority

| # | Control | Status | Evidence / Notes |
|---|---------|--------|------------------|
| 7 | Is automated or manual **security scanning** performed on hooks, MCPs, and extensions? |  |  |
| 8 | Are there **kill switches** and graceful degradation for the agent itself? |  |  |
| 9 | Is **context compaction** strategic and policy-driven (not just "when full")? |  |  |
| 10 | Is there a defined process for **continuous learning / pattern evolution** with confidence scoring? |  |  |

### Recommended for World-Class Harnesses

- Cross-harness portability considerations documented
- Defensive posture for the agent itself defined (self-protection against prompt injection, tool poisoning, etc.)
- Structured logging + evaluation metrics for the harness
- Regular threat model reviews of the harness

---

**Final Verdict**:
- [ ] Passes Security Gate (all Critical items Yes or accepted with recorded compensating controls)
- [ ] Does NOT pass — blocking issues listed above

**Reviewer**: ___________________________  
**Date**: ___________________________
