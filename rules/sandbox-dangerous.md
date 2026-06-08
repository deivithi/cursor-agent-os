# 🧱 Sandbox p/ Operação Sem Permissões — Blast Radius Limitado

> Ativa sempre que a sessão for rodar com `--dangerously-skip-permissions` (ou modo
> equivalente "yolo/auto-approve") ou um loop autônomo de muitos prompts.
> Princípio (Akita/Galego, vídeo "Half Loops"): _"Se você roda dangerously-skip-permissions
> o tempo todo, alguma hora a IA deleta uma pasta do seu computador. É raro, mas a 100-200
> prompts/dia o raro acontece."_

---

## 1. Regra dura

`--dangerously-skip-permissions` (e auto-aprovação irrestrita) **só** dentro de ambiente
isolado:

- **Dev container** (`.devcontainer/`) ou container Docker dedicado, **ou**
- **VM / sandbox** com filesystem e rede restritos, **ou**
- `/sandbox` do Claude Code (isola file/network, ver `workflow-patterns.md` §7).

Fora de ambiente isolado → **não** habilitar skip-permissions. Operar com aprovação normal.

Sinalização: o hook `hooks/git-safety-guard.js` emite lembrete quando detecta
`--dangerously-skip-permissions` sem `SANDBOX`/`DEVCONTAINER` no ambiente.

---

## 2. Blast Radius Limiter (caps por sessão isolada)

Mesmo isolado, limitar o raio de explosão (primitiva #2/Blast Radius do `HARNESS.md`):

- **Writes/deletes** restritos ao workspace do projeto — nunca `~`, `C:\`, `/`, `System32`.
- **Rede** restrita ao necessário (sem exfiltração; sem `curl | sh` de fonte não confiável).
- **Sem credenciais de produção** montadas no sandbox (usar `.env` de dev/stub).
- **Privilégios mínimos** — container não-root quando possível.

---

## 3. Operações que NUNCA são liberadas por skip-permissions

Mesmo em sandbox, estas permanecem sob confirmação (cruza com `human-architectural-gate.md`
e `caverna` safety carve-out):

- `DROP` / `TRUNCATE` / `DELETE` sem WHERE em banco real (mesmo "staging" que replica).
- `git push --force` em `main`/`master` de repo compartilhado.
- `rm -rf` / `Remove-Item -Recurse -Force` fora do workspace.
- Deploy de produção (`vercel --prod`, `supabase db push`).
- Cripto / LGPD / sanitização de BD (gate humano permanece).

Sandbox protege o **computador local**, não autoriza destruição de **estado compartilhado**.

---

## 4. Checklist antes de ligar o modo sem permissões

```
□ Estou em dev container / VM / sandbox isolado?
□ Workspace é cópia descartável OU tenho backup/commit recente?
□ Credenciais de produção estão FORA do ambiente?
□ Rede restrita ao necessário?
□ Kill switch acessível (consigo parar o loop)?
```

Falhou em qualquer item → não habilitar skip-permissions.

---

## 5. Referência cruzada

- `workflow-patterns.md` §7 (`/sandbox`) e §9 (worktree p/ isolar código)
- `human-architectural-gate.md` — gate humano em domínios irreversíveis (independe de sandbox)
- `HARNESS.md` §"10 primitivas" — Blast Radius Limiter, Kill Switch, Least Agency
- `hooks/git-safety-guard.js` — lembrete preToolUse de skip-permissions fora de sandbox
- Vídeo "Half Loops" (Augusto Galego) — dev container p/ loops autônomos
