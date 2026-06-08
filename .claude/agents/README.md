# Typed Subagents

## Available Agent Types

| Type | Role | Read-only? | Use When |
|------|------|-----------|----------|
| `worker` | Focused executor | No | Task execution, code changes |
| `explorer` | Researcher | Yes | Codebase exploration, research |
| `reviewer` | Adversarial critic | Yes | Code review, audit, quality |
| `evaluator` | Skeptical QA (live testing) | Yes | QA with Playwright, scoring, bug hunting |
| `planner` | Strategic architect | Yes | Planning, architecture, design |

## Usage in /do

When using `/do`, specify the agent type:
```
/do --agent-type reviewer "review the auth module"
/do --agent-type evaluator "QA the running app at localhost:3000"
/do --agent-type worker "implement the login form"
/do --agent-type explorer "find all API endpoints"
/do --agent-type planner "plan the migration to v2"
```

The agent definition is prepended to the subagent's prompt, giving it specific behavioral constraints.

### Reviewer vs Evaluator

| Aspect | Reviewer | Evaluator |
|--------|----------|-----------|
| **Focus** | Code quality (static) | Product quality (live) |
| **Method** | Read code, find issues | Test running app, score |
| **Tools** | Read-only, Grep, Glob | Playwright MCP, screenshots |
| **Output** | Severity-scored findings | Graded rubric + bugs |
| **When** | PR review, code audit | After build, QA pass |

## Orchestration Protocols

Protocols define how agents interact in multi-agent architectures:

| Protocol | File | Purpose |
|----------|------|---------|
| **Sprint Contract** | `protocols/sprint-contract.md` | Negotiate "done" before coding |
| **GAN Loop** | `protocols/gan-loop.md` | Generator↔Evaluator iteration loop |
| **Frontend Rubric** | `protocols/frontend-grading-rubric.md` | 4-criteria scoring for UI work |
| **Context Reset** | `protocols/context-reset-strategy.md` | Handoff strategy for long sessions |

### GAN Loop (Generator↔Evaluator)

> Source: [Anthropic Engineering — Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps)

For complex builds, use the 3-agent architecture:
```
Planner (1x) → Generator (sprints) ↔ Evaluator (QA per sprint)
```

For simpler tasks with Opus 4.6:
```
Planner (1x) → Generator (implements all) → Evaluator (1x final QA)
```

## Creating Custom Agents

Create a new `.md` file in `.claude/agents/` with:
1. Agent name as H1 heading
2. Role description
3. Output format specification
4. Constraints

The file name (without .md) becomes the agent type name.
