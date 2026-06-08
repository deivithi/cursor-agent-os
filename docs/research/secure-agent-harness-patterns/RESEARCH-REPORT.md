# Research Report: Secure & Professional Agent Harness Patterns

**Date**: 2026-05-25  
**Researchers**: deivithi (with AI assistance)  
**Primary Sources**:
- affaan-m/ECC (182k+ stars) — "The agent harness performance optimization system"
- shareAI-lab/learn-claude-code (62k+ stars) — Teaching-focused minimal harness
- Cross-reference with HarnessQwen-v6.5 and main HARNESS.md project

**Goal**: Extract only high-signal, security-first architectural patterns that can be safely adopted into the main Agent Harness project without pollution or risk.

---

## Executive Summary

Two world-class agent harness projects were deeply analyzed with extreme security focus:

- **ECC** is currently the most mature, security-conscious, cross-harness production system available. It treats security, supply chain, memory, and continuous learning as first-class concerns.
- **learn-claude-code** provides the clearest, most teachable implementation of the core loop + a practical 3-gate permission pipeline.

**Key Finding**: Current HarnessQwen-v6.5 (and the broader HARNESS.md SOP) is strong on externalization and review discipline, but has significant gaps in pre-execution permission control, input sanitization, hook safety, and supply-chain awareness compared to these references.

The 10 patterns in `SECURE-PATTERNS-FOR-HARNESS.md` represent the minimal, high-ROI, defensible set worth adopting.

---

## Detailed Gap Analysis (Security-First Lens)

| Dimension                      | HarnessQwen-v6.5 Current State          | ECC / learn-claude-code State                          | Security Risk Level | Priority |
|--------------------------------|-----------------------------------------|-------------------------------------------------------|---------------------|----------|
| Permission Model               | Post-facto audit + external gates       | 3-Gate Pipeline (Hard Deny → Rules → Human Approval) | Critical            | P1       |
| Input Sanitization             | Basic                                   | Explicit layer (Unicode, attachments, links, skills) | High                | P1       |
| Hook Safety                    | Present but fragile                     | Runtime profiles + disable + script-based             | High                | P1       |
| Supply Chain (Skills/Hooks)    | Low awareness                           | Treated as artifacts with review + scanning           | High                | P1       |
| Memory Threat Model            | Implicit                                | Explicit ("memory as gasoline") + policies            | Medium-High         | P2       |
| Context Compaction             | Manual / ad-hoc                         | Strategic + multi-layer + policy                      | Medium              | P2       |
| Continuous Learning            | LICOES (strong but manual)              | Instincts + confidence scoring + controlled evolve    | Medium              | P2       |
| Observability & Kill Switches  | Partial                                 | Heartbeat + structured logging + process-group kill   | Medium              | P2       |
| Cross-Harness Design           | Low (Claude/Cursor centric)             | High (designed for multiple harnesses from day 1)     | Strategic           | P3       |
| Least Agency Principle         | Partially applied                       | Core architectural principle                          | High                | P1       |

**Critical Insight from ECC Security Guide**:
- Prompt injection in agents can lead to full shell execution and lateral movement (CVE-2025-59536 class issues).
- Skills, rules, and hooks are supply-chain attack vectors.
- Memory persistence is "gasoline" — poisoned memory survives restarts and corrupts long-term behavior.

---

## The 10 Curated Patterns (Summary)

See the companion file `SECURE-PATTERNS-FOR-HARNESS.md` for the clean, copy-paste-ready version.

The patterns were selected using these filters:
- Must reduce attack surface measurably
- Must be architectural (not tied to one codebase)
- Must be cross-harness portable
- Must be auditable / defensible
- Must not significantly increase complexity without security ROI

**Deliberately excluded**:
- LLM-based classifiers for approval (too bypassable)
- Heavy UI/Dashboard features
- Anything that would bloat the core HARNESS.md

---

## Prioritized Evolution Proposals

### Priority 1 — Security Hardening (Do First)

1. Implement a **3-Gate Permission Pipeline** (adapted from learn-claude-code + ECC)
2. Add mandatory **Sanitization Layer** for all inbound content
3. Introduce **Hook Runtime Controls** (profiles + selective disable)
4. Treat **Skills / Rules / Hooks as Supply Chain** with minimum review + scanning gate

### Priority 2 — Professionalism & Resilience

5. Evolve LICOES-style memory into **Instincts + Confidence Scoring**
6. Make **Strategic Context Compaction** a first-class mechanism with policy
7. Add explicit **Memory Threat Model** section

### Priority 3 — Long-term Architecture

8. Design future versions with **cross-harness portability** as a requirement
9. Create a minimal "Core Security Profile" of the harness (audit-friendly subset)

---

## Recommended Integration Path (No Pollution)

1. Add the clean 10-pattern list to main `HARNESS.md` (see `SECURE-PATTERNS-FOR-HARNESS.md`)
2. Keep all detailed research, examples, and rationale in `docs/research/secure-agent-harness-patterns/`
3. Create a skill (`secure-agent-harness-patterns`) so the context can be reloaded instantly in any future session
4. When evolving HarnessQwen-v6.5 or the main harness, load the skill first

---

## Files Generated in This Research Cycle

- `docs/research/secure-agent-harness-patterns/SECURE-PATTERNS-FOR-HARNESS.md` — Clean, minimal version for HARNESS.md
- `docs/research/secure-agent-harness-patterns/RESEARCH-REPORT.md` — This full report
- `skills/secure-agent-harness-patterns/SKILL.md` — Reloadable context skill

---

**Research conducted with extreme security caution** as explicitly requested. Only patterns that survive adversarial review were included.

**Next recommended action**: Load the new skill in future sessions when working on harness evolution.
