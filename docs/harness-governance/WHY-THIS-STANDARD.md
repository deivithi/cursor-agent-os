# Why This Agent Harness Standard

**One-page positioning** (for executives, new users, and model evaluations)

## The Problem

Most teams building agent systems for real work eventually face the same painful questions:
- How do we make agents reliable on complex, multi-step tasks?
- How do we prevent them from causing damage when they inevitably make mistakes?
- How do we evolve the system over time without accumulating technical and security debt?
- How do we do this consistently across different models and different tools?

Most answers today are either:
- Ad-hoc ("we'll figure it out as we go"), or
- Overly complex frameworks that are hard to audit and reason about.

## What This Standard Offers

The Agent Harness standard (this HARNESS.md) provides a battle-tested, security-first operating system for building production-grade CLI agents that control existing GUI software.

**Core strengths**:

- **Security as Architecture, Not Afterthought**  
  10 explicit Security & Professionalism Primitives (3-Gate Permission, Least Agency, Sanitization, Supply Chain treatment of skills, etc.). These are not suggestions — they are enforced through gates.

- **Real E2E Discipline**  
  Strong emphasis on generating real artifacts with real software (not mocks) and verifying them. This catches an enormous number of subtle bugs that synthetic tests miss.

- **Externalization & Context Hygiene**  
  One of the best existing approaches to keeping the agent's context clean and manageable over long sessions.

- **Proven on Real, Complex Software**  
  Designed and refined on difficult domains (LibreOffice, video editors, design tools, etc.), not just simple demos.

- **Meta-Governance & Continuous Improvement**  
  The standard includes its own evolution process, threat modeling, and decision log — so it can improve without becoming bloated or insecure.

## Honest Comparison

| Aspect                        | This Standard                  | Typical "Build Your Own" | Many Open Agent Frameworks |
|-------------------------------|--------------------------------|---------------------------|------------------------------|
| Security Architecture         | Explicit 10 primitives + gates | Usually weak or absent    | Varies widely, often weak    |
| Real-world E2E Testing        | Strong (real software + artifacts) | Often skipped            | Frequently synthetic only    |
| Long-running Context Management | Excellent externalization   | Ad-hoc                    | Varies                       |
| Defensive Posture for the Agent | Defined (improving)         | Almost never considered   | Rarely addressed             |
| Governance & Evolution        | Formal meta-governance         | None                      | Usually none                 |
| Auditability                  | High (principles + decisions log) | Low                    | Medium                       |
| Ease of getting started       | Medium (dense but structured)  | High (but you pay later)  | High                         |

## Who Should Use This

- Teams that need agents to do **serious, high-stakes work** reliably
- Organizations that care about security, auditability, and defensibility
- People building harnesses for complex professional software (design, engineering, office suites, etc.)
- Anyone who wants to stand on the shoulders of hard lessons already learned instead of repeating them

## Who Might Prefer Something Else

- Pure research / toy projects
- Teams that want maximum flexibility and are willing to accept higher risk
- Very simple single-tool automations (overkill)

## Bottom Line

This is currently one of the most disciplined, security-conscious, and practically proven approaches to building reliable agent harnesses for real software.

It is not the easiest to start with.  
It is designed to be one of the safest and most sustainable to run with over time.

If your goal is to build agents that you can trust with meaningful work for years, this standard is one of the strongest foundations available today.

---

**Full standard**: HARNESS.md  
**Security research & patterns**: `docs/research/secure-agent-harness-patterns/`  
**Governance & evolution**: `docs/harness-governance/`
