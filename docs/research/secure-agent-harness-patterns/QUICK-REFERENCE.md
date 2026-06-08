# Quick Reference — 10 Secure Agent Harness Patterns

**Use this when you need the list in < 30 seconds.**

1. **3-Gate Permission Pipeline** — Hard Deny → Contextual Rules → Human Approval (mandatory)
2. **Least Agency + Explicit Trust Boundaries** — Agent never inherits full operator power
3. **Sanitization as First-Class Layer** — Unicode, attachments, links, skills treated as executable context
4. **Hook System with Runtime Controls** — Profiles + selective disable + script-based only
5. **Strategic Context Compaction** — First-class mechanism with policy, not emergency hack
6. **Memory Threat Model ("Memory as Gasoline")** — Persistent memory is an attack vector; needs rotation/trust/reset policies
7. **Skills/Rules/Hooks = Supply Chain** — Review + hash + provenance + scanning before loading
8. **AgentShield / Security Scanning as Gate** — Automated scanning for hooks, MCPs, permissions, secrets, prompt injection
9. **Continuous Learning with Confidence Scoring** — Evolution requires confidence + human review, not automatic
10. **Cross-Harness Design by Default** — Architected for portability and comparative audits from day one

**Golden Rule**: Principles only. Never copy implementations.

**Full clean version**: `SECURE-PATTERNS-FOR-HARNESS.md`  
**Full report + gaps + proposals**: `RESEARCH-REPORT.md`

**Reload full context anytime**: Load skill `secure-agent-harness-patterns`
