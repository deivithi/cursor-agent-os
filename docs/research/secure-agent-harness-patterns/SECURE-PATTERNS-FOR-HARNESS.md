# Secure & Professional Agent Harness Patterns (Curated)

**Status**: Curated for integration into main HARNESS.md  
**Source**: Research on affaan-m/ECC (182k+ stars) + shareAI-lab/learn-claude-code (62k+ stars) + cross-analysis with HarnessQwen-v6.5  
**Date**: 2026-05-25  
**Principle**: Extract only high-signal, security-first architectural patterns. Never copy implementations. Adopt the principles.

---

## Core Principle

This section registers only patterns that:
- Dramatically reduce attack surface
- Are proven in large-scale agent harnesses
- Work cross-harness (Claude Code, Cursor, OpenCode, Codex, etc.)
- Are defensible in security audits

**Rule**: Do not paste code or full implementations here. Reference the research docs for details.

---

## The 10 Curated Patterns

### 1. 3-Gate Permission Pipeline (Mandatory)

**Principle**: Every tool action must pass three gates in fixed order:
1. Hard Deny List (e.g. `rm -rf /`, `sudo`, `curl | bash`)
2. Contextual Rules (e.g. "writing outside WORKDIR", "destructive bash commands")
3. Human Approval (when rules trigger or high-risk action)

**Security Rationale**: Creates fail-closed by default. Eliminates blind execution. Directly mitigates prompt injection → shell execution and ransomware precursors.

**Integration Note**: Make this a non-negotiable runtime security layer in any professional harness.

---

### 2. Least Agency + Explicit Trust Boundaries

**Principle**: The agent always operates with the smallest possible set of powers and identities. It never inherits the operator’s full credentials or context.

**Security Rationale**: Limits blast radius. Prevents lateral movement and credential theft if the agent is compromised.

**Integration Note**: Declare explicit trust boundaries per operation class (read vs write vs execute vs network).

---

### 3. Sanitization as First-Class Layer

**Principle**: Every piece of content entering the agent’s context (Unicode, attachments, links, skills, rules, MCP configs) goes through structured sanitization before processing.

**Security Rationale**: Treats “data = executable context”. Mitigates hidden-character injection, malicious links, and supply-chain attacks via skills/hooks (see ECC CVE-2025-59536 lessons).

**Integration Note**: Add a mandatory Sanitization Layer in the input pipeline.

---

### 4. Hook System with Runtime Controls

**Principle**: Hooks are secure extension points. They must support:
- Execution profiles (e.g. `strict`, `research`, `yolo`)
- Runtime disablement (`ECC_DISABLED_HOOKS` style)
- Implementation via external scripts (never inline)

**Security Rationale**: Prevents compromised or malicious hooks from running silently. Allows hardening without rewriting the core.

**Integration Note**: Adopt runtime-controllable hook architecture as the recommended extensibility model.

---

### 5. Strategic Context Compaction

**Principle**: Context compaction is not an emergency “summarize when full” hack. It is a first-class strategic mechanism with retention policies, layers, and explicit security goals.

**Security Rationale**: Reduces the attack window of long context (memory poisoning, prompt stuffing, data exfiltration via context).

**Integration Note**: Treat compaction as a core primitive with policy, not an afterthought.

---

### 6. Memory Threat Model ("Memory as Gasoline")

**Principle**: Persistent memory is an attack vector. It requires explicit policies for rotation, trust scoring, isolation, and controlled reset.

**Security Rationale**: Poisoned memory can persist for weeks and corrupt future decisions (ECC “memory as gasoline” insight).

**Integration Note**: Add a dedicated Memory Threat Model section in the harness security model.

---

### 7. Skills / Rules / Hooks Treated as Supply Chain

**Principle**: Skills, rules, and hooks are supply-chain artifacts. They must go through review, hashing, provenance tracking, and scanning before being loaded.

**Security Rationale**: Prevents injection of malicious behavior through “helpful” extensions (major lesson from ECC security guide).

**Integration Note**: Define a minimum secure onboarding process for all extensions.

---

### 8. AgentShield / Security Scanning as Gate

**Principle**: The harness should include (or integrate) automated security scanning for hooks, MCPs, permissions, secrets, and prompt injection patterns.

**Security Rationale**: Catches dangerous patterns before execution (ECC AgentShield model with 1282+ tests).

**Integration Note**: Position security scanning as a mandatory gate for professional harnesses.

---

### 9. Continuous Learning with Confidence Scoring

**Principle**: Evolution of the harness (new rules, instincts, patterns) must carry confidence scores and human review before entering production use.

**Security Rationale**: Prevents “fast learning” from introducing insecure behaviors.

**Integration Note**: Use controlled evolution model (not fully automatic).

---

### 10. Cross-Harness Design by Default

**Principle**: The harness must be architected from day one to be portable and auditable across different platforms and vendors.

**Security Rationale**: Enables comparative security audits and avoids lock-in to any single (potentially flawed) implementation.

**Integration Note**: Adopt as a long-term architectural requirement.

---

## Usage Rules for HARNESS.md

- Keep this section extremely lean (max 4 lines per pattern).
- Always reinforce: **“Principles, not implementations.”**
- Link to the full research docs for depth:
  - `docs/research/secure-agent-harness-patterns/RESEARCH-REPORT.md`
  - `docs/research/secure-agent-harness-patterns/SECURE-PATTERNS-FOR-HARNESS.md`

---

**Curated by**: deivithi + research on ECC + learn-claude-code  
**Last updated**: 2026-05-25
