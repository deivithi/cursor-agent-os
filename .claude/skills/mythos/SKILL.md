---
name: mythos
description: >
  Mythos-class autonomous vulnerability discovery para cybersecurity defensiva.
  Deep code comprehension, file prioritization (1-5), exploit chain analysis,
  variant analysis e zero-day class bug hunting. Orquestra subagentes para
  hunting paralelo. Triggers: mythos, zero-day hunt, exploit chain, deep security,
  vulnerability discovery, mythos scan/hunt/siege, security deep dive.
domain: security
subdomain: vulnerability-research
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - mythos
  - vulnerability-discovery
  - zero-day
  - exploit-chain
  - deep-code-comprehension
  - variant-analysis
  - file-prioritization
  - autonomous-hunting
  - defensive-security
  - attack-surface
---

# Mythos — Autonomous Vulnerability Discovery (Defensive)

> **"Os bugs que importam sao os que ferramentas automatizadas nao pegam apos milhoes de testes."**
> Inspirado na metodologia do Claude Mythos Preview (Anthropic, 2026) — adaptado como skill defensiva.

**Mythos e o apex predator do stack de seguranca.** Onde `security-audit` aplica checklists e `vibe-deploy-guard` pega erros comuns, Mythos vai alem: deep code comprehension linha-a-linha, file prioritization por attack surface, exploit chain analysis e variant analysis autonoma. 100% defensivo — encontra vulnerabilidades para CORRIGIR, nunca para explorar.

## File Structure

- `SKILL.md` — Voce esta aqui. Metodologia completa.
- `references/file-prioritization-matrix.md` — Criterios de scoring 1-5 por linguagem/framework.
- `references/exploit-chain-patterns.md` — 10 padroes de cadeias de exploits.
- `references/vulnerability-taxonomy.md` — Classes de bugs alem do OWASP.
- `references/deep-comprehension-protocol.md` — Protocolo linha-a-linha com exemplos.
- `references/variant-analysis-playbook.md` — Playbook com grep patterns por classe.
- `references/report-template.md` — Template de relatorio standalone.
- `gotchas.md` — 7 armadilhas conhecidas.

## Related Skills

- `security-audit` — Trail of Bits, OWASP, Semgrep. Mythos ESTENDE com hunting autonomo e profundidade
- `vibe-deploy-guard` — 18 erros comuns de AI coding. Mythos encontra o que checklists nao cobrem
- `/cyber` — Router de 572 skills. Mythos orquestra as relevantes via subagentes
- `code-review` — Review adversarial. Mythos escala quando deep hunting e necessario
- `guardrails` — Protecao runtime. Mythos encontra as vulns que guardrails deve proteger
- `codebase-graph` — Visualizacao de arquitetura alimenta o mapeamento de attack surface
- `alpha-loop` — Loop iterativo test→fix→retest para resolver vulnerabilidades encontradas

---

## 1. Quando Usar

| Cenario | Mythos? | Alternativa |
|---------|---------|-------------|
| Zero-day class hunting em codigo critico | ✅ L2/L3 | — |
| Deep research em parsers, JIT, crypto, kernels | ✅ L3 | — |
| Exploit chain analysis (vulns podem ser encadeadas?) | ✅ L2/L3 | — |
| Variant analysis apos encontrar um bug | ✅ L2 | — |
| Auditoria pre-release de componentes security-critical | ✅ L2 | — |
| Mapeamento rapido de attack surface | ✅ L1 | — |
| Checklist OWASP padrao | ❌ | `security-audit` |
| Verificacao rapida de erros de AI coding | ❌ | `vibe-deploy-guard` |
| Code review de PR simples | ❌ | `code-review` |
| Dominio cyber especifico (forensics, SIEM, malware) | ❌ | `/cyber` |
| Protecao runtime de agentes | ❌ | `guardrails` |

---

## 2. Progressive Disclosure

| Nivel | Nome | Trigger | Duracao | Comportamento |
|-------|------|---------|---------|---------------|
| **L1: Recon** | Quick Attack Surface | `mythos scan` | 5-10 min | Fases 1-2: mapeamento + file prioritization 1-5. Top 10 arquivos. Surface findings |
| **L2: Hunt** | Standard Vuln Hunt | `mythos hunt` | 20-40 min | Fases 1-4 completas em arquivos priorizados. Exploit chain mapping. Variant search |
| **L3: Siege** | Full Mythos-Class | `mythos siege` | 1-3 horas | Todas as 6 fases. 4 subagentes paralelos. Analise exaustiva. Report formal completo |

**Regra:** Sempre comecar pelo nivel mais baixo e escalar se necessario. L3 Siege requer time budget definido ANTES de iniciar.

---

## 3. Metodologia Mythos (6 Fases)

### Fase 1 — Attack Surface Mapping

> Estende `security-audit` Fase 1 (Context Building). NAO busque vulnerabilidades aqui.

```
MAPEAMENTO OBRIGATORIO:

1. ENTRY POINTS — Onde dados nao confiaveis entram:
   □ Network parsers (HTTP, WebSocket, gRPC, TCP/UDP raw)
   □ File parsers (uploads, imports, configuracao)
   □ API endpoints (REST, GraphQL, webhooks)
   □ IPC handlers (postMessage, shared memory, pipes)
   □ CLI arguments e stdin
   □ Deserializacao (JSON.parse, pickle, protobuf)

2. TRUST BOUNDARIES — Onde dados cruzam fronteiras de confianca:
   □ Frontend → Backend (nunca confiar no client)
   □ Sandbox → Host (browser renderer → OS)
   □ User → Admin (escalacao de privilegios)
   □ Internal → External (SSRF, outbound requests)
   □ Process → Kernel (syscalls, drivers)

3. DATA FLOW — Como dados fluem pelo sistema:
   □ Input → Validacao → Processamento → Storage → Output
   □ Onde esta a sanitizacao? E consistente?
   □ Dados cruzam fronteiras entre validacao e uso?
   □ Ha caching que pode servir dados stale/inseguros?

4. DEPENDENCIAS CRITICAS:
   □ Auth/session management (Supabase Auth, JWT, OAuth)
   □ Crypto (hashing, encryption, token generation)
   □ ORM/query builder (Prisma, Drizzle, raw SQL)
   □ HTTP client (fetch, axios — SSRF surface)
```

---

### Fase 2 — File Prioritization (1-5)

> Cada arquivo recebe um score de 1-5 por likelihood de conter vulnerabilidades.
> Hunting segue ordem decrescente: 5s primeiro, depois 4s. Skip 1-2 exceto se variant analysis demandar.

```
CRITERIOS DE SCORING:

[5] CRITICAL ATTACK SURFACE
    - Parseia input nao confiavel (protocolos de rede, formatos de arquivo, dados de usuario)
    - Toma decisoes de autenticacao ou autorizacao
    - Realiza operacoes criptograficas
    - Gerencia memoria diretamente (C/C++ allocators, unsafe blocks, ArrayBuffer)
    - Cruza fronteiras de privilegio/sandbox
    Exemplos: auth middleware, JWT verify, file upload handler, WebSocket parser

[4] HIGH ATTACK SURFACE
    - Processa dados vindos de arquivos priority-5
    - Implementa logica de negocio security-sensitive
    - Gerencia sessoes ou valida tokens
    - Realiza serializacao/deserializacao
    Exemplos: user service que usa auth output, API route com query params

[3] MODERATE ATTACK SURFACE
    - Comunicacao entre servicos internos
    - Construcao de queries de banco
    - Parsing de configuracao
    - Logging com potencial de injection
    Exemplos: query builder, config loader, logger com user data

[2] LOW ATTACK SURFACE
    - Funcoes utilitarias internas com inputs ja validados
    - UI rendering (exceto se manipula input direto do usuario)
    - Scripts de build/deploy
    Exemplos: date formatter, CSS utility, build script

[1] MINIMAL ATTACK SURFACE
    - Constantes, enums, type definitions
    - Funcoes computacionais puras sem I/O
    - Test fixtures (exceto se testam seguranca)
    Exemplos: types.ts, constants.ts, math utils
```

**Output esperado:**
```
FILE PRIORITIZATION MAP
=======================
[5] src/api/auth/verify.ts           — JWT verification + session creation
[5] src/api/upload/handler.ts        — File upload parsing + storage
[5] src/middleware/auth.ts            — Auth decision gate for all routes
[4] src/services/user.ts             — Uses auth output, handles PII
[4] src/api/payments/webhook.ts      — Stripe webhook processing
[3] src/lib/db/queries.ts            — Query construction from params
[3] src/config/loader.ts             — Config parsing from env/files
[2] src/utils/format.ts              — Date/string formatting
[1] src/types/index.ts               — Type definitions only

HUNT ORDER: [5] → [4] → [3] se tempo permitir. Skip [2]-[1].
```

> Detalhes por linguagem/framework: `references/file-prioritization-matrix.md`

---

### Fase 3 — Deep Code Comprehension

> O diferencial do Mythos. Para cada arquivo priority 4-5, aplicar este protocolo.
> Detalhe completo: `references/deep-comprehension-protocol.md`

```
PROTOCOLO DE LEITURA PROFUNDA (por funcao em path critico):

1. LEITURA LINHA-A-LINHA
   Ler cada linha e declarar o que ela FAZ, nao o que PARECE fazer.
   Atencao especial a:
   - Error paths (nao so o happy path)
   - Aritmetica de inteiros: signed/unsigned, overflow/underflow, truncamento
   - Operacoes de string: encoding, null termination, calculo de length
   - Concorrencia: TOCTOU, lock ordering, atomicidade
   - Retornos: o que acontece se a funcao falha no meio?

2. EXTRACAO DE SUPOSICOES
   Para cada funcao, listar TODA suposicao implicita:
   - "Assume que input e null-terminated"
   - "Assume que length cabe em int32"
   - "Assume que caller ja validou auth"
   - "Assume UTF-8 encoding"
   → SUPOSICOES SAO ONDE BUGS MORAM

3. FIRST PRINCIPLES CHALLENGE
   Para cada suposicao:
   - "Quem GARANTE esta suposicao?"
   - "Um atacante pode VIOLAR esta suposicao?"
   - "O que acontece se esta suposicao for FALSA?"

4. 5 WHYS DE PROFUNDIDADE
   Para codigo suspeito:
   - Por que e implementado desta forma?
   - Por que este design foi escolhido?
   - Por que nao verifica X?
   - Por que este valor e usado como sentinel?
   - Por que esta operacao nao e atomica?

5. CROSS-BOUNDARY TRACING
   Seguir dados atraves de fronteiras de funcao/modulo:
   - Validacao no boundary A ainda vale no boundary B?
   - Dados podem ser modificados entre validacao e uso (TOCTOU)?
   - Suposicoes de length/size sao consistentes across boundaries?
```

---

### Fase 4 — Vulnerability Hunting

> 6 classes de bugs que scanners automatizados NAO pegam.
> Detalhes completos: `references/vulnerability-taxonomy.md`

**CLASSE 1: SENTINEL VALUE COLLISIONS**
- Valores de retorno que colidem com dados validos
- Magic numbers reutilizados entre contextos
- NULL usado como "vazio" E "erro" simultaneamente
- -1 usado como "nao encontrado" E indice valido (signed/unsigned mismatch)
- Exemplo Mythos: FFmpeg H.264 — slice numbering atinge 65536, colide com padding de inicializacao

**CLASSE 2: INTEGER ISSUES**
- Comparacao signed/unsigned (gcc -Wsign-compare pegaria, mas frequentemente suprimido)
- Integer overflow em calculos de tamanho (`malloc(n * sizeof(T))`)
- Truncamento em type narrowing (`size_t → int`, `int64 → int32`)
- Off-by-one em loop bounds e buffer sizes
- Exemplo Mythos: OpenBSD TCP SACK — signed integer overflow em comparacao de sequence numbers

**CLASSE 3: RACE CONDITIONS**
- TOCTOU entre check e uso (especialmente operacoes de filesystem)
- Atomicidade faltante em operacoes multi-step
- Lock ordering violations levando a deadlock
- Signal handler races com main thread

**CLASSE 4: MEMORY SAFETY (C/C++/Rust unsafe)**
- Use-after-free (objeto freed, referencia retida)
- Double-free (error paths freeing duas vezes)
- Buffer overflows (tamanhos mal calculados, off-by-one)
- Leitura de memoria nao inicializada

**CLASSE 5: LOGIC FLAWS**
- Authentication bypass por caminhos alternativos
- Authorization check no objeto errado (IDOR)
- Logica de negocio abusavel (quantidades negativas, overflow de creditos)
- State machine violations (pular estados obrigatorios)
- Mass assignment (aceitar campos nao previstos do client)

**CLASSE 6: CRYPTOGRAPHIC ISSUES**
- Timing side channels em comparacoes (usar `crypto.timingSafeEqual`)
- Randomness fraco para valores security-critical
- Nonce reuse em encryption
- Padding oracle susceptibility
- Hash sem salt para senhas

---

### Fase 5 — Exploit Chain Analysis

> Encadear 3-5 vulnerabilidades para avaliar impacto real.
> Padroes completos: `references/exploit-chain-patterns.md`

```
METODOLOGIA DE CHAIN:

1. Para cada finding, avaliar:
   - REACHABILITY: Atacante consegue alcancar este code path?
   - CONTROLLABILITY: Atacante controla o input que dispara?
   - IMPACT: Qual capability exploiting isso da? (read/write/execute/escalate)

2. Construcao de chain:
   ENTRY       → Como atacante entra? (rede, arquivo, IPC, API)
   PRIMITIVE   → Que primitiva o primeiro bug da? (info leak, write, type confusion)
   AMPLIFICATION → Primitiva pode ser amplificada? (heap spray, gadgets)
   ESCALATION  → Impacto pode ser escalado? (sandbox escape, privilege escalation)
   PERSISTENCE → Atacante pode manter acesso?

3. Scoring de chain:
   - Bug unico, sem chain: reportar com severity individual
   - Chain de 2 bugs: HIGH se ambos sao reachable
   - Chain de 3+ bugs: CRITICAL se demonstra full compromise path
   - Chain teorica (alguns bugs nao confirmados): MEDIUM, notar suposicoes

4. Output:
   CHAIN-001: [Entry via upload handler] → [Path traversal da write primitive]
              → [Overwrite config file] → [Inject admin credentials]
              → [Full admin access] = FULL COMPROMISE
   Confianca: HIGH (todos os bugs confirmados) / MEDIUM (step 3 teorico)
```

**REGRA DEFENSIVA:** Chains descrevem O QUE PODERIA acontecer e o IMPACTO. Nunca fornecer codigo de exploit funcional. Foco na REMEDIACAO de cada elo da chain.

---

### Fase 6 — Variant Analysis

> Dado um bug confirmado, buscar variantes no codebase inteiro.
> Playbook completo: `references/variant-analysis-playbook.md`

```
PROTOCOLO DE VARIANT ANALYSIS:

1. ABSTRAIR o bug para sua CLASSE:
   Bug: "Upload handler usa extensao do filename sem verificar content-type real"
   Classe: "Validacao insuficiente de tipo de arquivo"

2. FORMULAR search patterns:
   - Grep para todas as funcoes de upload/file handling
   - Para cada: verifica content-type real alem da extensao?
   - Para cada: tem whitelist de tipos permitidos?

3. EXPANDIR para patterns relacionados:
   - Mesma classe, funcao diferente (upload → import → config load)
   - Mesma funcao, contexto diferente (mesmo pattern em outro modulo)
   - Mesma root cause, manifestacao diferente

4. BUSCAR via subagentes (paralelo em L3):
   - Subagente 1: Match sintatico exato (grep pattern)
   - Subagente 2: Variantes semanticas (mesma classe, sintaxe diferente)
   - Subagente 3: Anti-patterns relacionados

5. Para cada variante encontrada:
   - Confirmar exploitabilidade no contexto
   - Avaliar se e mesma root cause ou independente
   - Adicionar aos findings com cross-reference ao original

CAP: Max 2 niveis de profundidade (original → variante → variante-de-variante → PARAR)
```

---

## 4. Subagent Orchestration (L3 Siege)

> Em modo L3, orquestrar 4 subagentes paralelos para hunting simultaneo.

```
PROTOCOLO DE HUNTING PARALELO:

SUBAGENTE 1: PARSER HUNTER (model: sonnet)
  Mandato: Analisar todos os arquivos priority-5 que parseiam input nao confiavel
  Protocolo: Deep Comprehension Protocol em cada parser
  Output: Lista de findings com severity

SUBAGENTE 2: AUTH/AUTHZ HUNTER (model: sonnet)
  Mandato: Tracar todos os caminhos de autenticacao e autorizacao
  Protocolo: Seguir cada decisao de auth do entry point ao enforcement
  Output: Lista de findings + caminhos de auth bypass

SUBAGENTE 3: DATA FLOW TRACER (model: sonnet)
  Mandato: Tracar dados nao confiaveis de entry point a dangerous sinks
  Protocolo: Mapear source→sink paths, identificar sanitizacao faltante
  Output: Mapa de taint analysis + findings de injection

SUBAGENTE 4: VARIANT SCANNER (model: haiku)
  Mandato: Dado findings dos outros subagentes, buscar variantes
  Protocolo: Variant Analysis Protocol (Fase 6)
  Output: Variant findings com cross-references

COORDENACAO (agente principal):
  - Cada subagente reporta findings independentemente
  - Coordenador deduplica e faz chain analysis
  - Se subagente encontra Critical: compartilhar com outros para chain analysis
  - Consolidacao final em report unico
```

---

## 5. False Positive Verification

> Compativel com `security-audit` Fase 3.3.

```
MYTHOS FP-CHECK:

Para cada finding:

1. DATA FLOW TRACE
   Dados controlados pelo atacante REALMENTE chegam neste ponto?
   - Tracar backwards do codigo vulneravel a TODOS os inputs possiveis
   - Se nenhum caminho de input nao confiavel existe: FALSE POSITIVE

2. CONSTRAINT ANALYSIS
   Ha constraints que impedem a exploracao?
   - Input validation upstream que bloqueia o vetor
   - Garantias do type system que previnem a condicao
   - Protecoes runtime (ASLR, stack canaries, CFI)

3. CONTEXT CHECK
   E exploravel no contexto de deployment?
   - Servico local-only sem exposicao de rede: downgrade severity
   - Atras de autenticacao: notar no report mas nao dismiss
   - Requer acesso fisico: LOW exceto se target justifica

4. CLASSIFICAR:
   TRUE POSITIVE   → Confirmado exploravel → adicionar ao report
   MITIGATED        → Bug real mas mitigado por outros controles → notar ambos
   FALSE POSITIVE   → Nao exploravel → documentar POR QUE (util para tuning)
   UNDETERMINED     → Nao confirmado → marcar para review humano
```

---

## 6. Severity Scoring

> Compativel com `security-audit` e `code-review`.

| Severity | CVSS | Criterio | Acao |
|----------|------|----------|------|
| 🔴 **CRITICAL** | 9.0-10.0 | RCE, auth bypass, full chain, data breach em escala | Fix IMEDIATO |
| 🟠 **HIGH** | 7.0-8.9 | Privilege escalation, injection exploravel, chain parcial | Fix antes de producao |
| 🟡 **MEDIUM** | 4.0-6.9 | Exploravel com constraints significativos, info leak | Fix no proximo sprint |
| 🔵 **LOW** | 0.1-3.9 | Teorico, mitigado, info leak menor | Backlog |
| ⚪ **INFO** | 0.0 | Best practice, hardening, sem exploitabilidade | Nota para melhoria |

**Anti severity inflation:** Perguntar sempre: "Um atacante com capacidades REALISTAS consegue explorar isso no contexto REAL de deployment?"

---

## 7. Report Template

> Formato completo: `references/report-template.md`
> Compativel com `security-audit` Fase 3.

```markdown
# Mythos Security Research Report

**Projeto:** {nome}
**Data:** {data} BRT
**Pesquisador:** Claude Code (metodologia Mythos) + {humano}
**Escopo:** {arquivos/modulos analisados}
**Metodologia:** Mythos Deep Comprehension + Variant Analysis + Exploit Chain
**Nivel:** L1 Recon / L2 Hunt / L3 Siege

## Resumo Executivo
- **Arquivos analisados:** X (de Y total)
- **Priority 5:** X | Priority 4: X | Priority 3: X
- **Findings:** X total
- 🔴 Critical: X | 🟠 High: X | 🟡 Medium: X | 🔵 Low: X | ⚪ Info: X
- **Exploit chains identificadas:** X
- **Variantes encontradas:** X (de Y findings originais)
- **Postura geral:** {Seguro / Necessita Atencao / Critico}

## File Prioritization Map
[Lista de arquivos priority 5-3 com justificativa]

## Findings
### [MYTH-001] {Titulo}
- **Severity:** 🔴 CRITICAL
- **Classe:** {Sentinel Collision / Integer Overflow / Race Condition / ...}
- **OWASP:** {A01-A10 se aplicavel}
- **CWE:** {CWE-XXX}
- **Localizacao:** `src/api/auth.ts:42-58`
- **Descricao:** {o que esta errado, from first principles}
- **Root Cause:** {a suposicao que e violada}
- **Impacto:** {o que um atacante poderia alcancar}
- **Exploit Chain:** {referencia a CHAIN-XXX se parte de uma chain}
- **Variantes:** {referencia a findings relacionados}
- **Reproducao:** {conceito de PoC — DEFENSIVO APENAS}
- **Remediacao:** {fix priorizado com exemplo de codigo}
- **Verificacao:** {como verificar que o fix esta correto}

## Exploit Chains
[Chains identificadas com steps e confidence level]

## Variant Analysis
[Agrupado por finding original]

## Recomendacoes de Defesa (Priorizadas)
1. **Imediato** — Fix de findings Critical
2. **Curto prazo** — Fix de findings High + adicionar mitigacoes
3. **Medio prazo** — Melhorias arquiteturais
4. **Longo prazo** — Prevencao sistematica
```

---

## 8. Anti-Patterns

| Anti-Pattern | Abordagem Correta |
|-------------|-------------------|
| Rodar Mythos em todo PR | `code-review` para PRs. Mythos para research dedicada |
| Pular file prioritization | SEMPRE ranquear 1-5 primeiro; hunting top-down |
| Fornecer guidance ofensiva | Descrever vulnerabilidade e impacto; foco na REMEDIACAO |
| Analisar node_modules/vendor | Foco em first-party code; `npm audit` para deps |
| Analise single-threaded exaustiva | Subagentes paralelos em L3 |
| Tratar chains teoricas como confirmadas | SEMPRE classificar nivel de confianca |
| L3 Siege sem time budget | Definir tempo maximo ANTES de iniciar (max 3h) |

---

## Handoff Points

| Quando | Repassar para | Condicao |
|--------|--------------|----------|
| Checklist OWASP suficiente | `security-audit` | Sem necessidade de deep hunting |
| Erro comum de AI coding detectado | `vibe-deploy-guard` | Pattern coberto pelo checklist |
| Dominio cyber especifico necessario | `/cyber` | Forensics, SIEM, malware analysis, etc. |
| Finding precisa de protecao runtime | `guardrails` | Deploy Input/Output/Action guards |
| Fix precisa de validacao iterativa | `alpha-loop` | Loop test→fix→retest ate resolver |
| Mapeamento de arquitetura necessario | `codebase-graph` | Attack surface como input |
| Code review padrao suficiente | `code-review` | Sem codigo security-critical |
| Remediacoes precisam de plano formal | `spec-planner` | Plano de implementacao para fixes |

---

## Gotchas

⚠️ Consulte `gotchas.md` para detalhes. Principais:

1. **Scope explosion** — Definir escopo e time budget ANTES (L1=10min, L2=40min, L3=3h max)
2. **Severity inflation** — CVSS rigoroso. Atacante REAL consegue explorar no contexto REAL?
3. **Offensive drift** — 100% DEFENSIVO. Nunca codigo de exploit funcional
4. **Pular Fase 1** — Sem context building = tempo desperdicado em arquivos irrelevantes
5. **Variant rabbit holes** — Cap em 2 niveis de profundidade

## Referencias

- [Anthropic Project Glasswing](https://www.anthropic.com/glasswing) — Lancamento oficial do Mythos Preview
- [Claude Mythos Preview Technical Report](https://red.anthropic.com/2026/mythos-preview/) — Detalhes tecnicos do Frontier Red Team
- [Trail of Bits Audit Methodology](https://github.com/trailofbits/publications) — Base da Fase 1 (Context Building)
- [OWASP Top 10 2025](https://owasp.org/Top10/) — Checklist base (complementado por Mythos)
- [CWE Database](https://cwe.mitre.org/) — Classificacao de vulnerabilidades
