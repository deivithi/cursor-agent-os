# 🔁 Bootstrap de sessão — memória sem comando

> Ativa sempre. Descreve o que já funciona automaticamente e o que o agente deve fazer
> nas pontas. Substitui o antigo ritual manual de 7 arquivos.

## O que entra sozinho no contexto (não depende de comando)

| Vetor | O que carrega | Alcance |
|---|---|---|
| `~/.dsh/AGENTS.md` | Identidade, infraestrutura canônica, regras de trabalho e o **bloco de estado gerado** | Injetado pelo DSH em **toda** sessão, em qualquer workspace, no primeiro request |
| `AGENTS.md` (raiz do workspace) | Regras globais permanentes do operador | Cadeia de instruções do projeto, raiz → cwd |

Mecanismo: pacote `@deepseek-ai/dsh-agent-instructions`, montado pelo bundle `dsh-base`, budget de 65.536 bytes. O arquivo é relido quando muda — não é preciso reiniciar a sessão.

> ⚠️ **Risco do budget compartilhado.** Os 65.536 bytes são um teto **único** para a baseline inteira: `~/.dsh/AGENTS.md` **mais** a cadeia de `AGENTS.md`/`CLAUDE.md` do projeto. O algoritmo descarta arquivos mais amplos antes de truncar o mais específico — ou seja, um `AGENTS.md` de projeto muito grande pode **omitir ou truncar justamente o bloco de estado** de que esta rule depende. Hoje o consumo é de ~13 KB de 64 KB, então há folga larga; se algum projeto passar a ter um `AGENTS.md` gigante, o bloco pode sumir sem aviso. O doctor não detecta isso — é um ponto cego conhecido, não um risco mitigado.

## O que NÃO existe (não conte com isso)

- **Nenhum subsistema de memória nativo no DSH.** Os MCPs de memória são default-off e exigem `--patch` explícito.
- **Nenhum hook do workspace é montado.** `profile-session.js`, `profile-tracker.js`, `domain-reinforce.js` e `openwiki-auth-guard.js` estão registrados apenas em `~/.claude/settings.json` (Claude Code/Cursor). No DSH eles **não rodam**.
- **`CONTEXT.md`, `AGENT_MEMORY.md`, `DECISIONS.md`, `SESSION_LOG.md` e `~/.claude/memory/` só são lidos se o agente decidir ler.** Não há injeção automática deles.

Consequência prática: a continuidade depende de dois arquivos injetados (`~/.dsh/AGENTS.md` e o `AGENTS.md` do projeto) **mais** a disciplina do agente de abrir a memória quando o pedido toca projeto, stack, ADR ou pendência. Não confie em hook para nada disso no DSH.

## Abertura de sessão

1. O bloco de estado em `~/.dsh/AGENTS.md` já diz a saúde da memória, o inventário, os HEADs e as pendências. **Não repetir esse ritual.**
2. Se o bloco disser `Saúde da memória: DESATUALIZADA`, ler as pendências listadas nele antes de agir sobre qualquer projeto.
3. Trabalho que toca projeto, stack, ADR ou decisão com histórico → ler `MEMORY_STATE.md` e o arquivo específico (`AGENT_MEMORY.md`, `DECISIONS.md`, `dre_eventos_projeto`). Pergunta simples de status → responder já (ADR-013).
4. Antes de mexer em qualquer projeto aninhado: `git status -sb` nele. O bloco de estado informa quantos caminhos estão pendentes.

## Fechamento de sessão (fazer, não perguntar)

1. Registrar a sessão em `SESSION_LOG.md`, **no topo**, mantendo a ordem cronológica decrescente.
2. Atualizar a memória que mudou: `AGENT_MEMORY.md` (fato permanente), `DECISIONS.md` (decisão de arquitetura), camada `user` em `~/.claude/memory` (diretriz do operador).
3. Rodar o doctor — ele recomputa o estado e reescreve os dois artefatos gerados:
   ```powershell
   pwsh -File "$env:USERPROFILE\.claude\scripts\memory-doctor.ps1"
   ```
4. O doctor deve terminar com **zero pendência acionável de memória**. A leitura correta tem três níveis:
   - `Saúde: ATUALIZADA` → nenhuma pendência de memória. Nada a fazer.
   - `Saúde: DESATUALIZADA` → cada linha `- pendência:` é uma **condição real de memória** a resolver.
   - Linhas `- aceito:` são deliberadas; a seção **Condições de ambiente** é problema de operação — nenhuma das duas afeta a Saúde.
5. **Pendências aceitas** (deliberadas, não indicam memória desatualizada): `~/.openwiki/.env` ausente de propósito (bloqueio consciente do OAuth do X) e plugin bundle em `skills/` sem `SKILL.md`. Se uma condição deixa de ser aceitável, ela sai da lista e volta a contar.
6. Commitar e subir (autorização permanente). Os arquivos que o **próprio sistema de memória** gera ou edita (`MEMORY_STATE.md`, `scripts/memory-doctor.ps1`) **não** contam como trabalho pendente — senão o snapshot seria estale-por-construção. Isso está declarado na saída, não é critério oculto.

### Condições de ambiente

Tarefa agendada desligada e scheduler parado são condições do **ambiente**, não da memória. O doctor as reporta na seção "Condições de ambiente" e **não** as soma à Saúde — misturar os dois tornava `ATUALIZADA` inalcançável e transformava a exigência em letra morta. Resolvê-las é decisão do operador: reativar (`Enable-ScheduledTask`) ou conviver. Elas aparecem no bloco injetado justamente para não ficarem invisíveis.

## Regra do número à mão — proibida

Contagem de skills, número de worktrees, HEAD de repositório, contagem de testes, estado de tarefa agendada e datas de "última atualização" **não se escrevem à mão** em arquivo de memória. Esses fatos vivem em `MEMORY_STATE.md`, produzidos por `~/.claude/scripts/memory-doctor.ps1`.

Se um arquivo de memória precisa citar um número, ele cita o arquivo gerado — nunca o valor.

Motivo: foi exatamente isso que apodreceu. `SKILLS_INDEX.md` declarava 110 skills quando havia 110 mas o `AGENT_MEMORY.md` dizia 104; o sync era "diário" com a tarefa desligada há 3 meses; o DRE tinha 595 testes onde havia 649; e o `declaw` apontava para um repositório que não existe mais.

## Quando o doctor acusa

| Pendência | O que significa |
|---|---|
| `última sessão registrada há N dias` | Sessões de trabalho não foram registradas em `SESSION_LOG.md` |
| `N commit(s) de memória/estrutura sem registro de sessão` | Houve commit que toca skills/rules/hooks/scripts/memória depois do último registro |
| `N caminho(s) não commitado(s) no repo raiz` | Trabalho pendurado no working tree (os arquivos do próprio sistema de memória não contam) |
| `N dependência(s) crítica(s) ausente(s)` | Arquivo citado pela memória não existe mais no disco |
| `N memória(s) nomeada(s) citada(s) e inexistente(s)` | A memória referencia uma entrada de memória que não foi criada |
| `SESSION_LOG fora de ordem cronológica` | Bloco anexado no lugar errado |
| `N skill(s) sem SKILL.md` | Diretório de skill incompleto (plugin bundle não conta) |

**Seção "Condições de ambiente"** (não aparece como pendência, e não afeta a Saúde):

| Condição | O que significa |
|---|---|
| `tarefa agendada inativa: …` | Tarefa do pipeline Febracis desligada — automação parada em silêncio |
| `scheduler do Hermes parado desde …` | Jobs `enabled` que não rodam: o FIO-IA e o briefing não estão sendo gerados |
| `N worktree(s) do repo raiz fora de worktrees/` | Trabalho pendente em `.claude/worktrees/` ou `.cline/worktrees/`, fora do inventário principal |

## Relação com outras rules

| Rule | Relação |
|---|---|
| `memory-protocol.md` | Define **o que** capturar e com que confiança; esta define **quando** e **por onde** |
| `plan-and-execute.md` §4 | ADR-013 continua valendo: nada de ritual pesado no primeiro turno de pergunta simples |
| `plan-and-execute.md` §1 | Autonomia e commit/push valem também para a manutenção da memória |
| `gauntlet-protocol.md` | O doctor é o check objetivo da camada de memória; sem ele, "memória atualizada" é afirmação sem evidência |

## Manutenção desta rule

Se um novo vetor de injeção automática for descoberto ou montado (hook no DSH, statusline, MCP de memória), registrar aqui — e remover da seção "O que NÃO existe".
