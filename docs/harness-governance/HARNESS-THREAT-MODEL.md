# HARNESS Threat Model

**Status**: Initial draft — to be expanded over time  
**Last Review**: 2026-05-25

## Scope

This threat model covers risks to the **HARNESS.md standard itself** and its governance artifacts, not the individual software harnesses generated from it.

The standard is a high-value artifact because it influences the design and security posture of many future agent systems.

## Key Assets

- The HARNESS.md document and its principles
- Governance artifacts (this threat model, meta-governance doc, decisions log)
- Recommended patterns, templates, and example code
- The "Security & Professionalism Primitives" section
- Skills and extensions that reference this standard

## Threat Actors

- Malicious contributors trying to introduce insecure patterns
- Nation-state or sophisticated attackers seeking to poison widely adopted standards
- Accidental introduction of dangerous patterns by well-intentioned but inexperienced contributors
- Supply chain attacks on skills, templates, or linked research

## Top Risks (Initial)

| Risk | Description | Likelihood | Impact | Mitigation |
|------|-------------|------------|--------|----------|
| Pattern Poisoning | Introduction of insecure but attractive patterns into the standard | Medium | Very High | Mandatory Security Gate + multiple reviewers + confidence scoring on new patterns |
| Governance Capture | Small group or single person making decisions without sufficient challenge | Low-Medium | High | Transparent decision log + periodic external review |
| Supply Chain via Skills | Malicious or vulnerable skills promoted as "official" or "recommended" | Medium | High | Strong supply chain rules for anything referenced in the standard |
| Context Poisoning via Research | Malicious or low-quality research being used as basis for changes | Medium | Medium-High | Source vetting + confidence scoring + requirement for multiple corroborating sources |
| Dilution of Security Primitives | Gradual weakening of the 10 primitives over time due to convenience | Medium | High | Explicit rule that changes to primitives require higher bar + recorded rationale |

## Required Controls (Minimum)

1. Every significant change to principles or mandatory sections must pass the Security & Professionalism Gate.
2. All decisions with security implications must be recorded in the Decisions Log with rationale.
3. The threat model itself must be reviewed at least annually or after major incidents in the agent ecosystem.
4. No pattern should be marked as "recommended" or "baseline" without evidence of real-world hardening.

---

**This is a living document.** It will be updated as the standard matures and new risks are identified.
