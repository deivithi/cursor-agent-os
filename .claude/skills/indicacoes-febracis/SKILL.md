---
name: indicacoes-febracis
description: Plataforma de Indicações Febracis (programa embaixador → lead → venda → recompensa). Abre o projeto de qualquer pasta, lê o estado, confere repositório, CI, Vercel e Zo e propõe ou executa o próximo passo (sprint). Use quando o operador chamar /indicacoes-febracis ou falar em "indicações", "Referido", "por onde paramos", "retomar", "próxima sprint", "deploy de prd/hml" deste projeto.
---

# Plataforma de Indicações Febracis

**Projeto:** `C:\Users\deivithi.lopes\Documents\Cursor\REferido - Febracis` (Git Bash: `/c/Users/deivithi.lopes/Documents/Cursor/REferido - Febracis`). Repositório privado `github.com/deivithi/febracis-indicacoes`, branch `main`.
Sessão aberta em outra pasta: rode todos os comandos com `cd` para esse caminho (ou `git -C "<caminho>"`) e leia os arquivos pelo caminho absoluto.

## Fontes da verdade (ler nesta ordem)

1. `docs/ESTADO.md` — o que está no ar, entregue, próxima sprint sugerida, bloqueios externos.
2. `CLAUDE.md` — invariantes, comandos e forma de trabalho.
3. `docs/DECISOES.md` — ADRs 001–021 (019 = sprint 6: 2º fator, trilha de segurança, atribuição, eventos, webhook, páginas legais; 020 = sprint 7: observabilidade e alertas, carga do pico, retenção LGPD, dicionário de métricas e exportação; 021 = sprint 8: fila genérica própria no PostgreSQL com fila de erro e runbook/manual).
4. `docs/PRD_SDD_BACKLOG.md` — tarefas T01–T92 e "Pontos a verificar"; `docs/AMBIENTES.md` — Zo, Vercel, senhas, 2º fator, demonstração, backup.
5. Skills do projeto: `.claude/skills/tarefa/SKILL.md` (como executar e fechar uma tarefa/sprint) e `.claude/skills/auditar/SKILL.md`.

## Onde está no ar

| Ambiente | Endereço |
|---|---|
| Produção (link que o PO compartilha) | https://febracis-indicacoes-deivithis-projects.vercel.app/ |
| Homologação (protegida pelo Vercel) | https://febracis-indicacoes-git-hml-deivithis-projects.vercel.app/console |
| API + banco | Zo (`infra/zo`): serviços `indicacoes-hml-api` (svc__Cb1fONDhNI), `indicacoes-prd-api` (svc_jMr1OG2r2hU), `indicacoes-gateway-auth` (svc_U1GNaOK6Tss), gateway `indicacoes` (svc_q8LcK_khT7Y) |

Stack: monorepo pnpm 12.8.1 (`npx -y pnpm@12.8.1 …`), Node 24, Next 16 + React 19 (web no Vercel), NestJS (API no Zo), PostgreSQL 18 com RLS por marca, migrações SQL (node-pg-migrate).

## Ao abrir (retomar)

1. Ler `docs/ESTADO.md`.
2. Conferir a realidade (o documento pode estar atrasado):
   - `git -C "<projeto>" fetch --prune && git -C "<projeto>" status -sb && git -C "<projeto>" log --oneline -5` — `main` = `origin/main`, árvore limpa.
   - `gh run list --repo deivithi/febracis-indicacoes --limit 3` — último CI de `main` verde.
   - `bash "<projeto>/scripts/smoke-vercel.sh"` — produção ponta a ponta.
   - Zo: `tail -5 /home/.z/backups/indicacoes-alerts.log` (alertas do vigia, T05) e `curl -s 127.0.0.1:3425/status` (saúde de prd; hml 3415).
   - Zo (MCP `zo`): `git -C /home/workspace/Projects/febracis-indicacoes/app log -1` (hml) e `…/envs/prd/app log -1` (prd) no mesmo commit de `origin/main`.
   Divergência → corrigir o documento (a realidade vence) e avisar em uma linha.
3. Propor (ou executar, se o pedido for executar) a "Próxima sprint sugerida" do ESTADO, respeitando "Depende de" e os bloqueios externos.

## Como trabalhar (decisões do PO)

- **Autonomia:** o PO autorizou decidir pelo contexto, sem custo extra e pelo mais avançado; cripto/LGPD entram como override registrado em ADR com premissas e a opção mais protetiva.
- **Sprint fechada de ponta a ponta, sem pendências:** plano → base (migração, contratos) → frentes em paralelo (agentes em worktree; mandar cada um fazer `git reset --hard <branch da sprint>`, porque nascem de `main`) → integração → verify local + CI → revisões independentes (segurança e código) → corrigir TODOS os achados, Low incluído → re-checagem → docs/ADR/ESTADO/skills/memória → PR squash → deploy.
- **Deploy sempre em prd e hml:** push em `main` (prd no Vercel) + `git push origin main:hml`; no Zo, `provision.sh hml` e `provision.sh prd` (cada um do próprio clone; mudança em `provision.sh`/`envs.sh` exige 2 passadas em cada ambiente), reiniciar as APIs, `infra/zo/gateway/smoke.sh`, `scripts/smoke-vercel.sh`.
- **QA visual** com Playwright no Zo (scripts em `/root/qa-indicacoes/`), sessão temporária gravada no banco de hml com `mfa_method='totp'`, revogada no fim; nunca digitar senha em site publicado.
- Comunicação em português do Brasil com acentos, STE-PT nível 80. Credenciais nunca passam pelo chat (links de senha vão para arquivo 0600 no Zo).

## Operação rápida (Zo, como root)

- Senha de usuário: `bash <clone>/infra/zo/password-link.sh <env> <email>` (link em `…/acesso/<env>-definir-senha.txt`).
- 2º fator perdido: `bash <clone>/infra/zo/mfa-reset.sh <env> <email> [chamado]`.
- Demonstração: `bash <clone>/infra/zo/demo.sh <env> <create|remove>` (remover antes de dado real em prd).
- Ambiente do zero: `bash <clone>/infra/zo/provision.sh <env>`; prova: `selftest.sh`.
- Vigia e alertas (Telegram): `node <clone de prd>/infra/zo/watchdog.mjs <env> --dry-run|--test-alert`; cron do projeto: `bash <clone>/infra/zo/cron.sh print|install`.
- Incidente: siga `docs/RUNBOOK.md` (um procedimento por alerta). Fila de erro (T04): console → Integrações → Fila de processamento (reprocessar, descartar, mensagem de teste); `queues.jobs` no `/status`.
- Carga do pico (RNF-02): `bash infra/zo/loadtest.sh <ref>` a partir de um clone no ref (ex.: cópia em `/root/qa-indicacoes/src-carga`); relatório em `/root/qa-indicacoes/carga-<data>.md`.
- QA visual em hml: o link `_vercel_share` expira; gere outro com a ferramenta do Vercel `get_access_to_vercel_url` (team `deivithis-projects`).

## Bloqueios externos (não resolver por conta própria)

DPO/jurídico (texto de consentimento abre a captura em prd; páginas legais; retenções), Financeiro (regra de comissão e unidade do extrato), Salesforce (licenças, T46–T52), Meta/WhatsApp (T40–T44, T11).

Cópias desta skill: nível do usuário (`~/.claude/skills/indicacoes-febracis`, aparece em sessões fora desta pasta), workspace (`Documents/Cursor/.claude/skills/indicacoes-febracis`) e esta, versionada no repositório. As três têm o mesmo conteúdo; ao mudar uma, copie para as outras.
