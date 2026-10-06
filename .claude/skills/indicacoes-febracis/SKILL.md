---
name: indicacoes-febracis
description: Plataforma de Indicações Febracis (programa embaixador → lead → venda → recompensa). Abre o projeto, lê o estado, confere repositório, CI e ambientes e propõe ou executa o próximo passo (sprint). Use quando chamarem /indicacoes-febracis ou falarem em "indicações", "Referido", "por onde paramos", "retomar", "próxima sprint", "deploy de prd/hml", "DigitalOcean" deste projeto.
---

# Plataforma de Indicações Febracis

**Repositório oficial:** `github.com/tifebracis/febracis-indicacoes` (privado), branch `main`. Rode tudo a partir da raiz do clone. Se a sessão foi aberta em outra pasta, descubra o clone (`git rev-parse --show-toplevel` dentro dele) e use `git -C "<clone>"` e caminhos absolutos.

## Fontes da verdade (ler nesta ordem)

1. `docs/ESTADO.md` — o que está no ar, entregue, próxima sprint sugerida, bloqueios externos.
2. `CLAUDE.md` — invariantes, comandos e forma de trabalho.
3. `docs/GUIA_DE_ENTRADA.md` — acessos, fluxo de branches/PR e mapa dos documentos.
4. `docs/BACKLOG.md` — tarefas T01–T96 com situação e sprint, e "Pontos a verificar". Requisitos em `docs/PRD.md`; arquitetura em `docs/SDD.md`; histórico em `docs/SPRINTS.md`.
5. `docs/DECISOES.md` — ADRs 001–023 (019 = 2º fator; 020 = observabilidade, carga, LGPD; 021 = fila genérica; 022 = acesso temporário sem 2º fator; 023 = implantação na DigitalOcean).
6. Skills do projeto: `/ambiente-local` (subir na máquina), `/tarefa` (executar e fechar uma tarefa/sprint), `/auditar` (checklist antes de entregar).

## Perfis

| Perfil | Tem acesso a | Publica em |
|---|---|---|
| PO (Deivithi) | Zo, Vercel (`deivithis-projects`), remoto `deploy` | Produção atual (Vercel + Zo) — `docs/AMBIENTES.md` |
| Desenvolvedora (Lorrany) | Repositório oficial, DigitalOcean da Febracis | DigitalOcean — `docs/DEPLOY_DIGITALOCEAN.md` (ADR-023) |

Sem acesso ao Zo: ignore os passos marcados "(PO)". O Zo e o Vercel são a **referência** do que está em produção hoje.

## Onde está no ar (referência atual)

| Ambiente | Endereço |
|---|---|
| Produção | https://febracis-indicacoes-deivithis-projects.vercel.app/ (console em `/console`) |
| Homologação | https://febracis-indicacoes-git-hml-deivithis-projects.vercel.app/console (protegida pelo Vercel) |
| API + banco (PO) | Zo (`infra/zo`): serviços `indicacoes-hml-api`, `indicacoes-prd-api`, `indicacoes-gateway-auth` e gateway `indicacoes` (ids em `infra/zo/services.md`) |

Stack: monorepo pnpm 12.8.1, Node 24, Next 16 + React 19 (web), NestJS (API), PostgreSQL 18 com RLS por marca, migrações SQL (node-pg-migrate).

## Ao abrir (retomar)

1. Ler `docs/ESTADO.md`.
2. Conferir a realidade (o documento pode estar atrasado):
   - `git fetch --prune && git status -sb && git log --oneline -5` — `main` igual a `origin/main`, árvore limpa.
   - `gh run list --limit 3` — último CI da `main` verde (4 checks: segredos, verify, ambiente local, imagens).
   - Ambiente local de pé? `pnpm local:check` (com `pnpm local:dev` rodando). Se nunca subiu: `/ambiente-local`.
   - (PO) `bash scripts/smoke-vercel.sh`; no Zo, `tail -5 /home/.z/backups/indicacoes-alerts.log` e `curl -s 127.0.0.1:3425/status`; commits de `…/febracis-indicacoes/app` (hml) e `…/envs/prd/app` (prd) iguais ao de `origin/main` e do remoto `deploy`.
   Divergência → corrigir o documento (a realidade vence) e avisar em uma linha.
3. Propor (ou executar, se o pedido for executar) a "Próxima sprint sugerida" do ESTADO, respeitando "Depende de" e os bloqueios externos.

## Como trabalhar (decisões do PO)

- **Autonomia:** decidir pelo contexto, sem custo extra e pelo mais avançado; cripto/LGPD entram como decisão registrada em ADR com premissas e a opção mais protetiva.
- **Sprint fechada de ponta a ponta, sem pendências:** plano → base (migração, contratos) → frentes em paralelo (agentes em worktree; mande cada um fazer `git reset --hard <branch da sprint>`, porque nascem de `main`) → integração → verify local + CI → revisões independentes (segurança e código) → corrigir TODOS os achados → re-checagem → docs/ADR/ESTADO/BACKLOG/SPRINTS/skills → PR squash → tag `sprint-NN` → deploy.
- **Deploy:** ver a skill `/tarefa`, passo 7 (PO: Vercel + Zo pelo remoto `deploy`; DigitalOcean: `docs/DEPLOY_DIGITALOCEAN.md`).
- Comunicação em português do Brasil com acentos, frases curtas. Credenciais nunca passam pelo chat nem pelo repositório.

## Operação rápida

- Ambiente local: `pnpm local:setup`, `pnpm local:dev`, `pnpm local:check`, `pnpm local:reset` (`docs/AMBIENTE_LOCAL.md`).
- DigitalOcean: imagens em `infra/docker/`, compose de produção em `infra/digitalocean/` (`docs/DEPLOY_DIGITALOCEAN.md`).
- (PO, no Zo como root) senha: `infra/zo/password-link.sh <env> <email>`; 2º fator perdido: `infra/zo/mfa-reset.sh <env> <email> [chamado]`; acesso temporário: `infra/zo/temp-access.sh <env> grant|revoke …` (ADR-022); demonstração: `infra/zo/demo.sh <env> create|remove`; ambiente do zero: `infra/zo/provision.sh <env>`; vigia: `node infra/zo/watchdog.mjs <env> --dry-run|--test-alert`.
- Incidente: `docs/RUNBOOK.md` (um procedimento por alerta). Fila de erro: console → Integrações → Fila de processamento.

## Bloqueios externos (não resolver por conta própria)

DPO/jurídico (texto de consentimento abre a captura em prd; páginas legais; retenções; DigitalOcean como suboperadora fora do Brasil), Financeiro (regra de comissão e unidade do extrato), Salesforce (licenças, T46–T52), Meta/WhatsApp (T40–T44, T11), Comercial (volume do pico do Método CIS).

(PO) Cópias desta skill: esta, versionada no repositório (fonte), e as cópias locais do PO (`~/.claude/skills/indicacoes-febracis` e `Documents/Cursor/.claude/skills/indicacoes-febracis`). Ao mudar esta, o PO copia para as outras. Quem não é o PO ignora esta linha.
