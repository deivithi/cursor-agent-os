# HARNESS Evaluation & Observability Framework

**Status**: Initial draft — May 2026

## Why This Matters

A world-class harness standard must be measurable. If we cannot tell whether a harness (or the standard itself) is improving or regressing, we are flying blind.

This document defines the minimum evaluation and observability expectations for harnesses built according to this standard.

## Core Evaluation Dimensions

### 1. Task Success & Reliability
- Percentage of complex, multi-step tasks completed without human intervention
- Recovery rate from partial failures
- Consistency across different models (Claude 3.5/4, GPT-4o, Gemini, local models, etc.)

### 2. Security & Safety
- Rate of permission gate violations (should trend toward zero)
- Number of near-miss or actual security incidents during operation
- Coverage of the 10 Security Primitives (measured via the Security Gate Checklist)

### 3. Efficiency & Cost
- Average tokens per successful task
- Context compaction effectiveness (tokens saved vs. information lost)
- Wall-clock time vs. pure tool execution time

### 4. Maintainability & Evolution
- How easily new capabilities can be added without breaking existing behavior
- Quality and coverage of the harness's own documentation and tests
- Speed of incorporating lessons from real usage

### 5. Defensive Posture (Agent Self-Protection)
- Ability to detect and respond to prompt injection, tool poisoning, and memory corruption attempts
- Quality of logging for post-incident forensic analysis

## Recommended Observability Baseline

Every production harness should produce at minimum:

- Structured logs of every tool call (with arguments, result summary, duration, and success/failure)
- Decision traces for high-impact actions (why the agent chose a particular path)
- Periodic "Harness Health Reports" (success rates, security violations, cost trends)
- Red team / adversarial test results (at least annually for serious use)

## Evaluation Cadence

- **Per Project / Per Major Task**: Full task success + security gate review
- **Monthly**: Aggregate metrics + trend analysis
- **Quarterly**: Deeper evaluation + comparison against previous quarter
- **Annually**: Full adversarial red teaming + update of threat model and defensive posture

## Open Questions (to be refined)

- What is the minimal viable evaluation harness that can be reused across projects?
- How do we normalize metrics across very different domains (LibreOffice vs. video editing vs. cybersecurity)?
- Should there be a public (anonymized) benchmark for harness quality?

---

This framework will mature as more real-world data becomes available.
