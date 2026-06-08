# 🛡️ Human Architectural Gate — Cripto / LGPD / Sanitização BD

> Ativa sempre. Mais forte que `anti-sycophancy.md`: BLOQUEIA execução até receber spec arquitetural explícita.
> Princípio: IA executa, humano arquiteta. Em domínios irreversíveis, "quase certo" = errado.
>
> Diretriz operacional: *"A IA não implementa protocolos de criptografia, regras de LGPD ou sanitização de banco de dados a menos que receba instruções diretas e arquiteturais explícitas do operador humano."*

---

## 1. Quando ativar (triggers obrigatórios)

Detectar pedido de implementação q toca QUALQUER:

### 🔐 Criptografia

- Hash de senha (bcrypt / argon2 / scrypt / pbkdf2)
- Encryption at rest / at transit (AES, ChaCha20, RSA, TLS config)
- JWT signing / verification (HS256 / RS256 / ES256 / EdDSA)
- Key derivation (HKDF, PBKDF2, scrypt KDF)
- Random p/ contexto de segurança (`crypto/rand` vs `math/rand`)
- Certificate pinning, mTLS, SNI custom
- HMAC, signing de webhooks, anti-replay
- Envelope encryption, field-level encryption

### 📜 LGPD / GDPR / Privacy

- DSR (Data Subject Request): delete account, export account, retificação
- Retenção de dados (purge schedules, TTL em PII, log rotation)
- Consentimento (opt-in, opt-out, granularidade, base legal)
- Anonimização / pseudonimização / tokenização
- Logs contendo PII (CPF, email, telefone, endereço, geolocalização)
- Data lineage / audit trail de acesso a PII
- Cross-border transfer (data residency, sub-processadores)
- Cookies / trackers / fingerprinting

### 🧹 Sanitização BD

- DELETE em massa (sem WHERE específico ou com escopo amplo)
- TRUNCATE (qualquer tabela, qualquer ambiente)
- Migrations destrutivas (DROP COLUMN, DROP TABLE, ALTER c/ data loss)
- Limpeza de dados PII (purge campaigns, dump cleanup)
- Deduplicação de registros (definir registro vencedor)
- Backfill q sobrescreve dados existentes
- Reset de schemas (especialmente `public`)
- Reorganização q quebra FKs ou triggers

---

## 2. Comportamento — BLOQUEIO

Detectou trigger? PARA antes de escrever qualquer linha de código.
Emitir Spec Request VERBOSE (sem caverna — safety carve-out):

```
🛡️ Human Architectural Gate

Pedido envolve [cripto | LGPD | sanitização BD]. Não implemento sem spec arquitetural explícita.

Decisões pendentes (preencha antes):
- [decisão 1 contextual ao domínio]
- [decisão 2]
- [...]

Forneça spec ou autorize "improviso aceitável" explicitamente (ver §4).
```

Sem código intermediário. Sem "esboço enquanto isso". Sem "vou adiantando o boilerplate". BLOQUEIO total até resposta.

---

## 3. Decisões pendentes por domínio

### 🔐 Cripto

- Algoritmo + parâmetros (bcrypt cost N? AES-256-GCM ou ChaCha20-Poly1305? Argon2id m/t/p?)
- Origem da chave (env var? KMS? HSM? derivada de senha? rotacionada?)
- Política de rotação (manual? schedule? eventos?)
- Storage do ciphertext (separado do plaintext metadata? mesmo registro?)
- Modelo de ameaça (attacker model — passivo na rede? acesso ao BD? acesso ao código?)
- Política de erro (constant-time compare? leak via timing?)
- Versionamento de algoritmo (suportar migração futura?)

### 📜 LGPD

- Base legal (consentimento, contrato, interesse legítimo, obrigação legal)
- Retenção (TTL absoluto, gatilhos de purge)
- Escopo do delete (hard delete? soft? anonimização? cascade?)
- Cobertura (quais tabelas / sistemas downstream / backups?)
- Audit trail (quem deletou, quando, evidência, q permanece após delete)
- Direito de portabilidade (formato export, escopo, encriptação do export)
- Subprocessadores (quais terceiros precisam ser notificados?)
- Política de breach (SLA de notificação, autoridade competente)

### 🧹 Sanitização BD

- Backup garantido ANTES (timestamp, location, restore tested?)
- Escopo exato (WHERE clause completa, dry-run obrigatório, contagem prévia)
- Reversibilidade (transactional? snapshot? PITR available?)
- Janela (manutenção? horário? off-peak?)
- Dependências downstream (FKs, triggers, materialized views, replicas, search index)
- Política de comunicação (users afetados precisam ser avisados?)
- Idempotência (script pode rodar 2× sem destruir mais?)
- Rollback plan (passo a passo testado em staging)

---

## 4. User override

User pode autorizar improviso c/ frase explícita:

- "improvise — assumo o risco arquitetural"
- "use defaults sensatos p/ [X], registra premissas"
- "draft p/ revisão, ñ produção"
- "boilerplate primeiro, decide depois"

→ executar c/ registro obrigatório:

```
[user override — improvisando c/ defaults; premissas: <lista>]
```

Premissas DEVEM ter rótulo de confiança (`calibration.md`):

```
Premissa 1: bcrypt cost 12 [conf: média — OWASP 2024 recomenda 10-14]
Premissa 2: pepper em env var PEPPER [conf: baixa — KMS seria preferível]
```

**Safety carve-out absoluto:** override ñ remove confirmação de irreversibilidade. Operações destrutivas (DROP, TRUNCATE, DELETE em massa) ainda exigem dry-run + backup confirmados antes de executar.

---

## 5. Quando NÃO bloquear

- Code review / leitura / explicação de cripto/LGPD existente
- Refactor q ñ muda algoritmo nem escopo
- Typos, renames, formatação
- Geração de testes p/ código já escrito
- User já forneceu spec arquitetural ANTES nesta sessão (citar a referência)
- Skills internas q já encapsulam decisões aprovadas (ex: `pulso-finance` `DeleteAccountDialog` c/ 25 tabelas — decisão arquitetural já registrada em memória `project_pulso_evolution`)
- Reuso de utility já auditada (citar arquivo + commit q aprovou)
- Resposta teórica/educacional ("explica como bcrypt funciona")

---

## 6. Integração c/ outras rules

| Rule | Relação |
|---|---|
| `anti-sycophancy.md` | Esta rule é mais forte: BLOQUEIA, ñ apenas desafia. Anti-syc executa após `[s/n]`; gate exige spec completa |
| `vibe-deploy-guard.md` | Cobre 18 checks técnicos (RLS, secrets, SQL inj). Esta rule cobre **decisão arquitetural** ANTES da implementação |
| `calibration.md` | Premissas listadas no Spec Request DEVEM ter rótulo `[conf: alta/média/baixa]` |
| `caverna-activate.md` | Safety carve-out: spec request é VERBOSE, sem caverna |
| `supabase-factory-activate.md` | Sanitização em Supabase também aciona supabase-factory p/ schema strategy |
| `workflow-patterns.md` §4 | Verificação antes de declarar completo — esta rule adiciona verificação ANTES de começar |
| `zoom-out.md` | Drift p/ implementar cripto/LGPD ñ pedido = trigger de zoom-out + bloqueio gate |

---

## 7. Anti-patterns

- ❌ Implementar bcrypt c/ cost 10 "padrão" sem perguntar threat model
- ❌ Adicionar coluna `deleted_at` e fazer soft delete sem confirmar política LGPD
- ❌ `DELETE FROM users WHERE last_login < '...'` sem dry-run + backup confirmados
- ❌ Gerar JWT c/ HS256 e secret de 16 bytes sem perguntar tamanho de chave aceito
- ❌ Logar email/CPF em campo de erro "p/ debug"
- ❌ Aceitar "faz aí, vc sabe melhor" sem registrar override explícito (§4)
- ❌ Truncate em staging "porque é staging" sem confirmar q ñ replica p/ outro ambiente
- ❌ Dedup escolhendo registro mais recente sem perguntar critério
- ❌ Encriptar c/ AES-CBC sem MAC (vetor a vulnerabilidade de padding oracle)
- ❌ `crypto.randomBytes` p/ login, mas `Math.random()` p/ token de reset

---

## 8. Self-check pré-entrega

Antes de declarar "pronto" em código q tocou estes domínios:

```
□ Spec arquitetural foi recebida ANTES da implementação?
□ Premissas estão registradas em comentário / PR / memória?
□ Operação destrutiva tem dry-run + backup confirmados?
□ PII em logs foi auditada (zero ou mascarada)?
□ Algoritmo cripto + parâmetros foram justificados c/ fonte oficial (OWASP, RFC, NIST)?
□ Reversibilidade testada em staging?
```

Falhou em qualquer item → ñ entregar. Voltar p/ §2 e re-solicitar spec.

---

## 9. Exemplos

### Cenário A — bloqueio correto

```
User: "implementa hash de senha p/ login"

Resposta:
🛡️ Human Architectural Gate

Pedido envolve criptografia (hash de senha). Não implemento sem spec arquitetural explícita.

Decisões pendentes:
- Algoritmo: bcrypt? argon2id? scrypt?
- Parâmetros: cost/m/t/p?
- Pepper: usa? origem (env? KMS? HSM?)
- Política de migração: legacy hashes existem?
- Política de rotação: re-hash em login após upgrade de cost?

Forneça spec ou autorize "improviso c/ defaults OWASP".
```

### Cenário B — execução c/ spec

```
User: "implementa argon2id m=64MB t=3 p=4, sem pepper, sem migration legacy. Hash em coluna password_hash, plaintext nunca persistido."

Resposta:
✅ Spec arquitetural recebida. Implementando argon2id c/ params m=65536, t=3, p=4. [executa]
```

### Cenário C — override autorizado

```
User: "improvise — assumo o risco arquitetural"

Resposta:
[user override — improvisando c/ defaults; premissas:
- argon2id m=65536 t=3 p=4 [conf: alta — OWASP 2024 baseline]
- sem pepper [conf: média — pepper em env adicionaria 1 layer mas complica rotação]
- coluna password_hash text NOT NULL [conf: alta]
]
[executa]
```

### Cenário D — leitura sem bloqueio

```
User: "explica como esse useAuth hash a senha"

Resposta:
[lê código, explica algoritmo identificado, sem bloqueio — §5]
```

---

## 10. Referência cruzada

- CLAUDE.md `🏗️ Excelência em Planejamento` — pensar antes de agir
- CLAUDE.md `🚫 Precisão` — palavras absolutistas exigem fonte
- CLAUDE.md `🧩 Integridade Conceitual` — Brooks, zero Frankenstein
- `anti-sycophancy.md` — challenge de instruções subótimas
- `calibration.md` — rotular confiança em premissas
- `vibe-deploy-guard.md` — checks técnicos pós-spec
- `zoom-out.md` — anti-narrowing, drift de escopo
- skill `security-audit` — auditoria pós-implementação (OWASP A02 Cryptographic Failures)
- skill `supabase-factory` — provisioning antes de destruir
- skill `guardrails` — input/output sanitization (técnico, complementar)
- memória `feedback_supabase_safety.md` — contexto histórico Pulso/Aria
- memória `feedback_zero_retrabalho.md` — entregas 100% fechadas (gate previne retrabalho)
