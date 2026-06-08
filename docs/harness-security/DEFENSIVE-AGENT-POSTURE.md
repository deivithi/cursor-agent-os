# Defensive Posture for Agents Built with This Harness

**Status**: Initial framework — May 2026  
**Goal**: Define minimum self-protection expectations for agents generated using this standard.

Most agent harnesses focus exclusively on offensive capabilities (controlling external software). This document addresses the equally important defensive side: how the agent protects **itself**.

## Core Defensive Principles

1. **Assume the environment is hostile** — The agent must not trust tool outputs, user prompts, or memory without validation.
2. **Minimize persistent state** — The less memory the agent keeps, the smaller the poisoning surface.
3. **Validate before acting** — Every high-impact action should have multiple independent checks.
4. **Fail closed and loudly** — When in doubt, the agent should stop and escalate rather than proceed unsafely.
5. **Maintain kill switches** — The operator (and in advanced cases, the agent itself) must be able to terminate execution cleanly.

## Recommended Defensive Controls (by Maturity Level)

### Level 0 (Baseline - Mandatory for any serious use)
- Sanitization of all tool outputs before they enter context
- Explicit bounding of context size + compaction policy
- Clear separation between "planning" and "execution" phases
- Operator-visible kill switch / emergency stop
- Logging of all tool calls with arguments (for post-incident analysis)

### Level 1 (Recommended for production agents)
- Tool output validation against expected schemas when possible
- Memory integrity checks (hashing or signing of critical facts)
- Rate limiting and anomaly detection on tool usage patterns
- Explicit "blast radius" limits per task (e.g., maximum files changed, maximum spend)
- Red team / adversarial testing of the agent before deployment

### Level 2 (World-class / High-security environments)
- Dual control for high-impact actions (human + agent confirmation)
- Cryptographic provenance for skills and critical instructions
- Runtime monitoring of the agent's own decision process (anomaly detection on reasoning traces)
- Ability for the agent to detect and report suspected prompt injection or context poisoning
- Regular adversarial red teaming of the full agent + harness combination

## Common Attack Vectors Against the Agent (Not the Target Software)

- Prompt injection via tool outputs or retrieved documents
- Memory poisoning / gradual context corruption
- Tool poisoning (malicious tool descriptions or return values)
- Supply chain attacks via skills, MCPs, or rules
- Context window stuffing / distraction attacks
- Long-term persistence via poisoned memory or backdoored skills

Every harness built with this standard should document how it mitigates (or accepts risk on) these vectors.

## Next Steps for This Document

- Map specific controls to the 10 Security Primitives
- Create example implementations and patterns
- Develop evaluation criteria for "Defensive Posture Level"

---

## Pilot Implementation (HarnessQwen-v6.5)

**Status**: Level 0 baseline being implemented (May 2026)

### Implemented

- **Output Sanitizer** (`output_sanitizer.py`)
  - Detects high/medium severity prompt injection patterns in tool outputs
  - Fail-closed on high-severity (blocks from context)
  - Aggressive redaction on medium-severity
  - Integrated into pilot via `.clinerules` §0c (mandatory)

- **Context Guard** (`context_guard.py`)
  - Registers critical facts with content hash (SHA-256)
  - Detects fact drift / memory poisoning attempts
  - Anomaly logging + compaction policy suggestion
  - Level 0 memory integrity baseline

- **Blast Radius Limiter** (`blast_radius.py`)
  - Hard limits on writes, deletes, moves, network calls, privilege ops per task
  - Blocks further operations once any limit is exceeded
  - Strong containment for high-impact or long-running tasks
  - Level 0/1 blast radius control

- **Kill Switch** (`kill_switch.py`)
  - File-based + programmatic emergency stop (`.harness/STOP` or per-task)
  - Can be triggered by operator or by the agent itself when it detects problems
  - Recommended to be checked at the start of every major loop / dangerous step
  - Level 0 mandatory control (explicit kill switch)

### Enforcement

- `.clinerules/clinerules.md` section 0c requires Output Sanitizer on all tool outputs before context injection
- Context Guard is available and recommended for any task that maintains important state across steps
- Ignoring defensive guards = security anti-pattern

See pilot implementation: `HarnessQwen-v6.5/.harness/defense/`

This pilot is being used to validate and refine the Defensive Posture framework before promoting patterns back into the main HARNESS.md.

---

This document will evolve. Contributions that make agents safer (not just more capable) are especially welcome.
