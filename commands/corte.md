# ✂️ Corte de release

Faz o corte de versão com enxame de QA, triagem e patch. Uso: `/corte [<versao>|qa <areas>|patch <achado>]`

Carregue `skills/corte-release/SKILL.md` e siga o workflow.

## Modos

| Comando | Efeito |
|---|---|
| `/corte <versao>` | Fases 1 a 5: avisa autores, publica em hml, roda o enxame, faz triagem e corrige |
| `/corte qa <areas>` | Roda só o enxame nas áreas do mapa citadas |
| `/corte patch <achado>` | Corrige o achado, faz cherry-pick no ramo do corte e cria a tag de patch |

## Limites

- Deploy em prd pede confirmação do PO toda vez.
- Correção que toca cripto, LGPD ou dado em massa para no gate humano.
