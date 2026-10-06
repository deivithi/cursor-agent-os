# Triagem e patch release

## 1. Decisão por achado

| Severidade | Origem | Destino | Patch? |
|---|---|---|---|
| CRITICAL | regressão | corrige em `main`, cherry-pick no ramo do corte, tag de patch | sim, antes de prd |
| CRITICAL | pré-existente | corrige em `main`, cherry-pick no ramo do corte | sim; o PO decide se segura o corte |
| HIGH | regressão | corrige em `main`, cherry-pick no ramo do corte | sim |
| HIGH | pré-existente | corrige em `main` | não: entra no próximo corte |
| MEDIUM / LOW | qualquer | vira item do `docs/BACKLOG.md` | não |
| qualquer | indeterminada ou não verificada | reproduzir à mão antes de decidir; na dúvida, trate como regressão | — |

- **Regressão** = acontece em hml (versão nova) e não em prd (versão anterior), com o agente na mesma tela nos dois.
- **Pré-existente** = acontece nos dois.
- **Indeterminada** = não deu para comparar com prd sem login ou sem escrever.
- **Não verificada** = o agente de reprodução falhou.

Severidade segue `data/severity-config.json` (CRITICAL = P0 bloqueia operação; HIGH = P1).

## 2. Correção (um agente por achado)

1. Abra um agente com `isolation: worktree` por achado CRITICAL/HIGH. Primeiro comando, **só dentro do worktree**: `git fetch origin && git reset --hard origin/main`. O worktree nasce do `main` local, que pode estar velho. Nunca rode esse reset na cópia principal: ele apaga trabalho não commitado.
2. O agente escreve primeiro o teste que reproduz o achado (Red), depois corrige o código (Green). Não apaga nem enfraquece teste (`rules/test-integrity.md`).
3. O agente roda `pnpm verify` e abre PR para `main` (`gh pr create --repo "$REPO"`) com o achado, a evidência e o teste.
4. Um revisor independente (`code-review`, contexto isolado) revisa o PR. Achado acima do limiar volta ao passo 2.
5. Mescle o PR em `main` (squash).

## 3. Patch release (só regressão ou CRITICAL)

```bash
# ramo do corte: release/<versao>, criado no corte no mesmo commit da tag-base
git fetch origin --tags
git switch -c release/sprint-10 --track origin/release/sprint-10   # ou: git switch release/sprint-10 && git pull --ff-only
git cherry-pick -x <sha-do-squash-em-main>   # -x registra a origem
pnpm verify
git push origin release/sprint-10
TAG_ATUAL=$(git describe --tags --abbrev=0)   # sprint-10 ou o último patch, ex.: sprint-10.1
NOVA=$(node --input-type=module -e "import {proximoPatch} from './skills/corte-release/scripts/notas-do-corte.mjs'; console.log(proximoPatch(process.argv[1]))" "$TAG_ATUAL")
git tag -a "$NOVA" -m "patch: <achado>"
git push origin "$NOVA"
gh release create "$NOVA" --repo "$REPO" --verify-tag --notes-file notas-patch.md
```

- Conflito no cherry-pick: não resolva "no olho". Peça ao agente da correção um PR próprio para `release/<versao>`.
- Depois do patch, publique o ramo em hml de novo (Fase 2 da SKILL) e rode o enxame **só nas áreas tocadas** (`areas` filtrada nos args).

## 4. O que nunca entra no automático

- Deploy em prd (`vercel --prod`, reprovisionar prd no Zo, implantar na DigitalOcean): pede confirmação do PO toda vez.
- Correção que mexe em cripto, LGPD, retenção ou dado em massa: `rules/human-architectural-gate.md` bloqueia até ter spec.
- Push para `main`: só por PR.
- Push para `hml`: só o ramo do corte, na Fase 2 (`git push deploy release/<versao>:hml`). Nenhum outro commit entra direto em `hml`.
