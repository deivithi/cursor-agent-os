# Parâmetros “Smart YOLO” (espelho conceitual)

Referência oficial: [YOLO Mode](https://docs.traycer.ai/tasks/yolo-mode) e secção Smart YOLO em [Epic Mode](https://docs.traycer.ai/tasks/epic).

O produto Traycer descreve orquestração **dinâmica**: por ticket/spec, ajustar em runtime aspectos como agentes, templates, **skip planning**, níveis de verificação, **timeouts**, **auto-commit**, etc.

## Tabela para este workspace (`spec-yolo`)

Alinhar à skill `.claude/skills/spec-yolo/SKILL.md`. Parâmetros típicos:

| Parâmetro | Uso |
|-----------|-----|
| Skip Plan | Tarefas triviais com plano implícito |
| Severity threshold | Até que severidade o auto-fix corre (ex.: MAJOR) |
| Max fix loops | Teto de iterações por fase (ex.: 3) |
| Auto-commit | Só com OK explícito do utilizador em políticas sensíveis |
| Progress tracking | `agent-harness` para sessões longas |

## Heurísticas de roteamento (inspiradas em Smart YOLO)

- Ticket pequeno + codebase conhecida → pode **reduzir** verbosidade do plano ou usar planner mínimo.
- Ticket com integrações externas ou segurança → **não** skip plan; verificação mais estrita.
- Falhas repetidas na verificação → aumentar loops ou reduzir scope do ticket antes de continuar.

Sempre preferir **parâmetros explícitos** num bloco `YOLO Config` no início da corrida (ver `spec-yolo`), para auditoria.
