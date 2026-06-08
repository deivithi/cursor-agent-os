# HARNESS Meta-Governance & Evolution Framework

**Status**: Foundational document for turning the Agent Harness into a living, world-class standard.  
**Date**: 2026-05-25  
**Owner**: deivithi + community

## Purpose

This document defines how the HARNESS.md standard itself evolves, is governed, hardened, and improved over time. It elevates the project from "excellent SOP" to "self-improving global reference standard."

Without strong meta-governance, even the best technical content stagnates or gets diluted.

## Core Principles of Meta-Governance

1. **The HARNESS is a Product** — It must be treated with the same rigor as the harnesses it generates (versioning, threat modeling, change control, evaluation).
2. **Security & Professionalism First** — Every major change must pass the Security & Professionalism Primitives gate.
3. **Evidence-Based Evolution** — Changes must be backed by data, lessons learned, or external research (not just opinion).
4. **Minimal Core, Powerful Extensions** — The standard must remain lean. Complexity lives in optional extensions or profiles.
5. **Transparency & Auditability** — All significant decisions and changes must be logged and reviewable.

## Evolution Cycle (The HARNESS Loop)

The standard follows a recurring cycle:

### 1. Trigger
- External research (new high-signal projects like ECC, new CVEs, new agent architectures)
- Internal lessons from real usage (HarnessQwen, production agents, failed experiments)
- Community contributions
- Security incidents or near-misses
- New requirements from Febracis / enterprise use cases

### 2. Analysis & Proposal
- Create a research note or RFC in `docs/harness-governance/rfcs/`
- Perform gap analysis against current state
- Evaluate against the 10 Security & Professionalism Primitives
- Assess blast radius and complexity cost

### 3. Security & Professionalism Gate (Mandatory)
- Every proposal above a certain threshold must pass a formal review against the 10 primitives.
- At minimum: Does this change increase or decrease attack surface? Does it improve or hurt auditability?
- Gate can be performed by the owner or a small trusted review group.

### 4. Decision & Integration
- Decision recorded in `HARNESS-DECISIONS.md` (or changelog with rationale)
- Integration into the main HARNESS.md using the same quality standards applied to generated harnesses (categorized review, minimalism, clarity)
- Version bump (semantic: major for breaking changes to the standard itself)

### 5. Evaluation & Feedback Loop
- After 30-90 days, evaluate real-world impact
- Collect metrics (adoption, security incidents, usability feedback)
- Feed back into the next cycle

## Artifacts of Meta-Governance

| Artifact                        | Purpose                                      | Location |
|--------------------------------|----------------------------------------------|----------|
| `HARNESS.md`                   | The living standard                          | Root |
| `HARNESS-DECISIONS.md`         | Rationale for major changes                  | docs/harness-governance/ |
| `HARNESS-THREAT-MODEL.md`      | Threat model of the standard itself          | docs/harness-governance/ |
| `HARNESS-EVALUATION.md`        | How we measure the quality of the standard   | docs/harness-governance/ |
| RFCs / Research Notes          | Proposals and deep analysis                  | docs/harness-governance/rfcs/ |
| Security & Professionalism Gate Checklist | Mandatory review for changes | docs/harness-governance/ |

## Change Control Levels

- **Patch / Minor**: Small clarifications, typo fixes, small examples → Direct edit + changelog entry
- **Minor Standard Change**: New recommended pattern, small extension → Requires light review + decision log
- **Major / Breaking**: New mandatory primitives, restructuring of phases, new governance rules → Requires full Security Gate + recorded decision

## Security of the Standard Itself

The HARNESS.md and its governance artifacts are themselves high-value targets (they influence how many agents will be built).

Key protections:
- All significant changes must pass the Security Primitives review.
- Skills, templates, and example code used in the standard must go through supply-chain hygiene.
- The threat model of the standard (`HARNESS-THREAT-MODEL.md`) must be reviewed at least once per year or after major incidents in the agent space.

## Roadmap for Meta-Governance (2026)

- Q2 2026: Establish this framework + initial `HARNESS-THREAT-MODEL.md`
- Q3 2026: Implement first version of evaluation metrics for the standard
- Q4 2026: Open structured contribution process for new patterns (with strong security gates)

---

**This document is the seed of the Meta-Harness.**  
It will evolve using the same loop it defines.
