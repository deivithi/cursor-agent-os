# HARNESS Adoption, Levels & Contribution Model

**Status**: Initial framework — May 2026

## Vision

For this standard to become a world power, it cannot remain a single-person or single-team effort. We need a clear path for adoption, progressive maturity levels, and safe contribution.

## Maturity Levels (Proposed)

Harnesses built according to this standard can be classified in levels:

- **Level 0 — Experimental**: Follows basic structure. No security gate passed.
- **Level 1 — Internal Use**: Passes the Security Gate Checklist at basic level. Suitable for controlled internal use.
- **Level 2 — Production-Grade**: Passes full Security Gate + has defensive posture documentation + basic observability. Recommended for real workloads.
- **Level 3 — Reference / Certified**: Passes Level 2 + has public evaluation results, adversarial testing, and proven track record across multiple models and domains. Eligible to be listed as an official reference implementation.

These levels will be refined and eventually tied to concrete checklists and evidence requirements.

## Contribution Model (How to Improve the Standard)

We welcome contributions that strengthen the standard, especially in security, professional practices, and real-world hardening.

### Safe Contribution Process

1. Open an issue or RFC in the repository with clear problem statement and proposed change.
2. For security-related or principle-level changes: The proposal must address impact on the 10 Primitives.
3. All significant changes go through the Meta-Governance process (see `HARNESS-META-GOVERNANCE.md`).
4. New patterns should start as optional/recommended before being considered for mandatory status.

### What We Especially Want

- Hardened real-world patterns that survived production use
- Defensive techniques for agents
- Better evaluation methods and metrics
- Cross-harness portability improvements
- Clear failure stories and lessons learned (these are extremely valuable)

### What We Are Very Careful About

- New mandatory requirements without strong evidence
- Complex mechanisms that only work for one specific stack
- Anything that significantly increases the cognitive load of using the standard

## Distribution Strategy (Long Term)

- Maintain a clean "Core" version of the standard (minimal, ultra-defensible)
- Allow domain-specific extensions (e.g., cybersecurity harness profile, creative tools profile)
- Create a lightweight registry or showcase of Level 2+ implementations
- Encourage translation and adaptation while preserving the security primitives

---

This model will evolve. The goal is maximum positive impact with minimum risk of dilution or capture.
