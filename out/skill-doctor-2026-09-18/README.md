# skill-doctor — auditoria de skills (2026-09-18)

Janela: 45d · fonte: `~/.cursor/projects` (251 conversas, 217 scoreable, 12 amostradas)
Harness do runtime: GenCode — **fora** do gate do skill (Cursor/Warp/Claude Code/Codex).
Usado o adapter Cursor por ser a única fonte parseável com sinal de skill.

## Nota: C (overall 0.76)
| Métrica | Valor |
|---|---|
| Efficiency | 0.80 (raw 0.60) |
| Code Quality | 0.60 (raw 0.20, só 2 sessões com diff) |
| Skill Coverage | 1.00 no sample · 0.659 na coorte (143/217) |

6 conversas falharam: ebec1ba2, 9dcfe8b1, ca8a5f08, 42a7bcc3, 804836e1, 9ec687b0.

## Nunca dispararam
870 de 950 (736 `cyber-*`, 22 `sci-*`, 112 não-cyber/sci).
Das 112: 68 citadas em `SKILLS_INDEX.md`/rules → mantidas; 44 órfãs, todas em
`VS CODE` (repo distinto) e em famílias coerentes (`link-cli-*`, `stack-*`,
`source-command-*`, `traycer-*`) → **não arquivadas** (decisão registrada).

## Correções aplicadas (rótulo `gotchas`/`pré-condição`, aditivas)
- `cursor-dre-eventos-ops` +1079B — Windows/UTF-8, env vars do refresh, um pipeline de screenshot, Drive privado, sessão vs alvo.
- `cursor-contrato-tarefa-agente` +445B — pré-condição de escopo (não é 5.º bloco).

Backups: `~/.config/gencode/skills/<skill>/SKILL.md.bak` (não versionado em git).

`inventory.json` + `transcripts/` ficaram em TEMP (contêm histórico bruto) e não foram copiados de propósito.
