# HARNESS Major Decisions Log

This log records significant decisions that shaped the Agent Harness standard, especially those with security, architectural, or long-term impact.

Format:
- **Date**
- **Decision**
- **Rationale** (including security considerations)
- **Alternatives Considered**
- **Impact / Follow-up**

---

### 2026-05-25 — Added "Security & Professionalism Primitives" section

**Decision**: Integrated the 10 curated security-first patterns (sourced from ECC and learn-claude-code research) directly into the main HARNESS.md as a top-level section after Key Principles.

**Rationale**:
- Current state of the standard was strong on construction methodology but weak on explicit security architecture.
- Research on mature harnesses (especially ECC) showed that declarative security without enforcement is insufficient.
- Goal: Make security a visible, first-class concern for anyone using or extending this standard.

**Security Considerations**:
- Patterns were heavily filtered for attack surface reduction.
- Explicit rule added: "Never copy implementations, only adopt principles."
- Full research report and sources documented in `docs/research/secure-agent-harness-patterns/`.

**Alternatives Considered**:
- Keep patterns only in a separate research folder (rejected — too low visibility).
- Make them mandatory rules immediately (deferred — needs more operationalization first).

**Impact**:
- Raised the baseline security expectations for all future harnesses built with this standard.
- Created foundation for later enforcement gates.

---

**Next entries will be added as major decisions occur.**
