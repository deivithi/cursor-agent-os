# skill-doctor — auditoria de skills (2026-09-18)

Janela: 45d · fonte: `~/.cursor/projects` (251 conversas na janela, 217 scoreable, 12 amostradas).
Harness do runtime: GenCode — **fora** do gate declarado pelo skill (Cursor/Warp/Claude Code/Codex).
Usado o adapter Cursor por ser a única fonte parseável com sinal de skill (`opencode.db` do GenCode não é suportado pelo collector).

## Nota: C (overall 0.76)

Pesos do skill: `0.5*efficiency + 0.35*code_quality + 0.15*skill_coverage`
→ `0.5*0.8 + 0.35*0.6 + 0.15*1.0 = 0.76` (faixa C = 0.73–0.77).

| Métrica | Valor | Base |
|---|---|---|
| Efficiency | 0.80 | raw 0.60, curado por `0.5 + 0.5x` |
| Code Quality | 0.60 | raw 0.20 — só **2** das 12 sessões tinham diff visível |
| Skill Coverage | 1.00 no sample | 12/12; na coorte = **0.659** (143 de 217 em escopo) |

**6 das 12 amostradas** falharam (eficiência e/ou qualidade < 0.5): `ebec1ba2`, `9dcfe8b1`, `ca8a5f08`, `42a7bcc3`, `804836e1`, `9ec687b0`.
Os IDs de `top_findings` no `report.json` são um subconjunto — findings ≠ lista de falhas.

## Nunca dispararam

870 de 950 instaladas: 736 `cyber-*`, 22 `sci-*`, 112 não-cyber/sci.

Disposição das 112, decidida **depois** do mapa de referências (rules, hooks, `SKILLS_INDEX.md`, commands, settings):

- **68 citadas** em `SKILLS_INDEX.md` / rules de ativação → **mantidas** (arquivar desincroniza índice e rules).
- **44 órfãs** → **não arquivadas**. Todas vivem no repo `VS CODE` (distinto deste), em famílias coerentes
  (`link-cli-*`, `stack-*`, `source-command-*`, `traycer-*`): não-acionadas ainda, não mortas. Zero-uso ≠ morta.

## Correções aplicadas (aditivas)

| Skill | Δ bytes | Conteúdo |
|---|---|---|
| `cursor-dre-eventos-ops` | +1486 | UTF-8/Windows, env vars antes de rodar, um pipeline de screenshot, credenciais fora de hardcode, Drive privado, sessão vs produto |
| `cursor-contrato-tarefa-agente` | +409 | alvo/escopo como condição dos 4 blocos (não um 5.º) |

Contagem em **bytes** (UTF-8); o original de cada skill é o `.bak` correspondente.

Evidência das correções (das 12 sessões amostradas): `9ec687b0` e `9dcfe8b1` → encoding/`SECRET_KEY`;
`ca8a5f08` → `DEPARA_SHEET_PUB_ID`/`DEPARA_GID` ausentes, `NIVEL_1` vazio;
`42a7bcc3` e `ca8a5f08` → flailing de screenshot em 3–4 backends;
`466aced0` → Drive privado buscado por 3 caminhos;
`ebec1ba2` e `1b47d58a` → alvo/escopo não fixado antes do build.

Backups do original: `~/.config/gencode/_skill-backups/skill-doctor-2026-09-18/` — `~/.config/gencode`
**não é repo git**, então o `.bak` é o caminho de revert. O `.bak` foi reconstruído removendo o bloco
inserido (mtime posterior ao edit); `diff` contra ele mostra exatamente o bloco adicionado.

## Não versionado de propósito

`inventory.json` e `transcripts/` (histórico bruto das conversas) ficaram em
`%TEMP%\gencode\skill-doctor-1789758656\` e não foram copiados para cá.
