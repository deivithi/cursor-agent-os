"""
Secure Agent Harness Patterns — Skill

Includes the 10 curated security & professionalism primitives extracted from large-scale agent harness research (ECC + learn-claude-code).

**Pilot validation status (May 2026)**:
- Permission Pipeline (3-Gate + profiles) fully implemented and validated on HarnessQwen-v6.5
- Defensive Posture Level 0:
  - Output Sanitizer (injection detection + fail-closed) — enforced in .clinerules §0c
  - Context Guard (fact hashing + memory poisoning detection + compaction policy)
  - Blast Radius Limiter (writes/deletes/network/privilege caps per task)
  - Kill Switch (file + programmatic emergency stop)
  - Four defensive controls now implemented. Enforcement expanding.

This skill will be updated as more defensive controls are proven on the pilot and promoted to the main standard.
"""
