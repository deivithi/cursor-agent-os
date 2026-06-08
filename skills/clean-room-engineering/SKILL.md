---
name: clean-room-engineering
description: >
  Clean Room Engineering com IA: workflow profissional de 7 passos para reimplementar
  software sem copiar codigo — spec-first, isolamento de contaminacao, provenance
  verification, framework etico e estrategias de defesa para maintainers open source.
  Ativa em: clean room, reimplementar, reescrever sem copiar, licenca, GPL, copyleft,
  sala limpa, behavioral spec, spec-first rewrite, license laundering, relicenciar,
  recriar software, equivalencia funcional, proprietary rewrite, audit provenance.
domain: software-engineering
subdomain: reverse-engineering
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - clean-room
  - spec-first
  - license
  - GPL
  - copyleft
  - reimplementation
  - behavioral-spec
  - provenance
  - reverse-engineering
  - open-source
  - license-compliance
  - audit
  - ethical-engineering
---

# Clean Room Engineering — Reimplementacao Profissional com IA

> **"Ideias sao livres. Implementacao e protegida. IA turbinou a distancia entre os dois."**
> — Principio fundamental desde Baker v. Selden (1879), agora em escala industrial.

**Dados de contexto (2026):**
- Cloudflare reescreveu Next.js em 1 semana com IA (vinext — 1.700+ testes, 94% API surface)
- chardet 7.0.0: rewrite completo LGPL→MIT via Claude Code — 0.04% similaridade (JPlag), controversia legal ativa
- MALUS (FOSDEM 2026): "Clean Room as a Service" demonstrado como produto viavel
- Claw Code: 50k stars em 2h — clean-room Rust rewrite do Claude Code apos leak acidental
- Custo caiu de ~US$150k (Compaq, 1982) para ~US$0 com LLMs

## File Structure

- `SKILL.md` — Voce esta aqui. Workflow + fundamentos + etica + defesa.
- `references/legal-cases.md` — 7 cases legais detalhados + caso chardet 2026.
- `references/spec-templates.md` — Templates de Behavioral Spec, Provenance Report, Checklist.
- `gotchas.md` — Falsos positivos, limitacoes, jurisdicoes.

## Related Skills

- `spec-driven-core` — Pipeline spec-driven (Epic→Phases→Plan→Verify). Clean room usa spec-first como fundacao
- `code-review` — Review do codigo gerado. Rodar APOS step 4 (implementacao)
- `security-audit` — Auditoria profunda Trail of Bits. Handoff se o codigo reimplementado toca auth/crypto
- `vibe-deploy-guard` — Enforcement de seguranca no codigo gerado. Complementar ao step 6
- `clean-code-rules` — Patterns de codigo limpo aplicados a implementacao isolada

---

## Quando Usar

| Cenario | Nivel |
|---------|-------|
| Reimplementar lib/tool a partir do comportamento publico | Full Clean Room |
| Documentar comportamento de software para spec interna | Spec-Only |
| Reescrever componente para mudar licenca (ex: GPL→MIT) | Full Clean Room |
| Auditar se codigo existente tem contaminacao de fonte GPL | Audit |
| Criar alternativa proprietaria a ferramenta open source | Full Clean Room |
| Entender como defender seu projeto open source contra clean room | Defense (secao 9) |
| Avaliar risco juridico de codigo gerado por IA | Audit |

## Quando NAO Usar (→ Handoff)

- **Fork legitimo** — Use fork + respeite a licenca original. Clean room e para reimplementacao, nao fork
- **Contribuicao upstream** — Se quer melhorar o projeto original, contribua diretamente
- **Copia direta** — Se precisa do codigo exato, use sob a licenca original. Nao tente lavar licenca
- **Projeto sob NDA/contrato** — Obrigacoes contratuais superam qualquer estrategia de clean room
- **Codigo trivial** — Padroes universais (sort, debounce, singleton) nao precisam de clean room

---

## Fundamentos Legais

> **Principio-chave:** Copyright protege a **expressao** (como voce escreveu), nunca a **ideia** (o que faz).

| Caso | Ano | Decisao | Principio |
|------|-----|---------|-----------|
| Baker v. Selden | 1879 | Metodos/ideias nao tem copyright | Dicotomia ideia-expressao |
| Apple v. Franklin | 1983 | Object code e protegido | Software tem copyright |
| Compaq BIOS | 1982 | Clean room two-team validado | Isolamento = validade juridica |
| Sega v. Accolade | 1992 | Reverse engineering = fair use | Desmontagem para interop e legal |
| Lotus v. Borland | 1995 | UI/menus = metodo de operacao | Estruturas de API nao protegidas |
| Oracle v. Google | 2021 | Uso de Java API = fair use (SCOTUS 6-2) | APIs declarativas podem ser copiadas |
| Doe v. GitHub (Copilot) | 2022+ | Licencas open source sao contratos validos | Treinamento em GPL tem implicacoes |

> **Detalhe completo:** `references/legal-cases.md`

### O que e protegido vs o que e livre

| Protegido (Expressao) | Livre (Ideias/Funcoes) |
|------------------------|----------------------|
| Codigo-fonte especifico | Comportamento funcional, algoritmos |
| Estrutura criativa unica | APIs e interfaces (per Oracle v. Google) |
| Comentarios/docs criativos | Especificacoes de interoperabilidade |
| Elementos artisticos de UI | Metodos de operacao (Lotus v. Borland) |

---

## O Workflow de 7 Passos

> **Modelo Compaq (1982) adaptado para era IA.** Cada passo gera artefato auditavel.

### Passo 1 — Behavioral Analysis (Dirty Room)

**Objetivo:** Documentar O QUE o software faz, sem tocar no codigo-fonte.

**Fontes permitidas:**
- Documentacao publica (README, docs, man pages)
- Exemplos de uso e tutoriais
- Especificacoes de protocolo/formato
- Comportamento observavel (rodar o software como usuario)
- Mensagens de erro e outputs

**Fontes PROIBIDAS:**
- Codigo-fonte do projeto original
- Decompilacao ou disassembly (exceto para interop sob Sega v. Accolade)
- PRs, issues com trechos de codigo
- Diffs ou changelogs com detalhes de implementacao

**Artefato:** `spec/behavioral-analysis.md` — lista de funcoes, I/O, edge cases, erros esperados.

**Prompt sugerido para LLM:**
```
Analise a documentacao publica de [SOFTWARE]. Documente:
1. Todas as funcoes/APIs publicas com assinatura e descricao
2. Inputs validos e invalidos para cada funcao
3. Outputs esperados (incluindo erros)
4. Edge cases documentados
5. Comportamento em condicoes limite

NAO leia, referencie ou reproduza codigo-fonte. Apenas comportamento observavel.
```

---

### Passo 2 — Specification Sanitization (Gate)

**Objetivo:** Garantir que a spec contem APENAS requisitos funcionais — zero expressao.

**Checklist de sanitizacao:**
```
[ ] Nenhuma variavel, funcao ou classe nomeada identicamente ao original?
[ ] Nenhum trecho de codigo (mesmo pseudocodigo similar)?
[ ] Apenas comportamento descrito (O QUE), nunca algoritmo especifico (COMO)?
[ ] Nenhuma estrutura de dados interna exposta?
[ ] Edge cases descritos por comportamento, nao por implementacao?
[ ] Spec poderia descrever QUALQUER implementacao equivalente?
```

**Regra de ouro:** Se alguem que NUNCA viu o original poderia escrever uma implementacao diferente a partir desta spec, a spec esta limpa.

**Artefato:** `spec/sanitized-spec.md` — spec revisada, marcada como sanitizada.

---

### Passo 3 — Test Suite Generation (TDD Reverso)

**Objetivo:** Transformar a spec em testes executaveis. Testes = contrato comportamental.

**Regras:**
- Gerar testes a partir da spec sanitizada (Passo 2), NUNCA do test suite original
- Cobrir: happy path, edge cases, error handling, performance bounds
- Testes definem O QUE esperar, nao COMO implementar
- Nomear testes descritivamente (ex: `should_return_empty_array_for_null_input`)

**Artefato:** `tests/` — suite de testes executavel.

**Prompt sugerido:**
```
A partir desta especificacao funcional, gere uma test suite completa em [LINGUAGEM]:

[COLAR SPEC SANITIZADA]

Regras:
- Testes baseados APENAS na spec acima
- NAO consulte nenhuma implementacao existente
- Cubra: happy path, edge cases, erros, limites
- Use [FRAMEWORK] (jest/pytest/vitest/etc)
```

---

### Passo 4 — Isolated Implementation (Clean Room)

**Objetivo:** Implementar do zero, APENAS a partir da spec + testes.

**Requisitos de isolamento:**
- Nova sessao do LLM (sem historico da analise comportamental)
- Se possivel, usar modelo diferente do usado no Passo 1
- Zero acesso ao codigo-fonte original
- Input: APENAS `sanitized-spec.md` + `tests/`

**Prompt sugerido:**
```
Implemente o seguinte software do zero, baseado APENAS nesta especificacao e testes:

[COLAR SPEC SANITIZADA]

Testes que devem passar: [REFERENCIA AOS TESTES]

Regras:
- Implemente do zero. NAO copie ou referencie nenhuma implementacao existente
- Use seus proprios nomes de variaveis, estruturas e algoritmos
- Priorize clareza e correcao sobre performance prematura
- Linguagem: [LINGUAGEM]
```

**Artefato:** Codigo-fonte implementado de forma isolada.

---

### Passo 5 — Provenance Verification

**Objetivo:** Provar que o codigo novo e independente do original.

**Ferramentas de verificacao:**
- **JPlag** — deteccao de similaridade academica (< 15% = seguro)
- **MOSS** (Stanford) — Measure of Software Similarity
- **difflib** (Python) — comparacao basica de sequencias
- **Copyscape** / ferramentas de plagio — para documentacao

**Metricas-alvo:**

| Metrica | Threshold seguro | Alerta | Critico |
|---------|-----------------|--------|---------|
| JPlag token similarity | < 15% | 15-30% | > 30% |
| Identical line ratio | < 5% | 5-15% | > 15% |
| Function name overlap | < 10% | 10-25% | > 25% |
| Structure similarity | < 20% | 20-40% | > 40% |

**Artefato:** `audit/provenance-report.md` — scores documentados, ferramenta usada, data.

---

### Passo 6 — Validation

**Objetivo:** Confirmar equivalencia comportamental.

**Checklist:**
```
[ ] Test suite completa passando (100% green)?
[ ] Edge cases cobertos e validados?
[ ] Performance dentro dos bounds especificados?
[ ] Comportamento identico ao descrito na spec?
[ ] Nenhuma regressao em cenarios nao-triviais?
[ ] Code review por humano (foco em qualidade, nao contaminacao)?
```

**Handoff:** Se o codigo toca auth, crypto, ou dados sensiveis → rodar `security-audit` e `vibe-deploy-guard` ANTES de prosseguir.

---

### Passo 7 — License Assignment + Audit Trail

**Objetivo:** Atribuir licenca e documentar todo o processo.

**Artefatos finais:**
```
project/
├── src/                          # Codigo implementado (Passo 4)
├── tests/                        # Test suite (Passo 3)
├── spec/
│   ├── behavioral-analysis.md    # Passo 1
│   └── sanitized-spec.md         # Passo 2
├── audit/
│   ├── provenance-report.md      # Passo 5
│   ├── validation-results.md     # Passo 6
│   └── process-log.md            # Timeline completa do processo
├── LICENSE                       # Licenca escolhida
└── ATTRIBUTION.md                # Atribuicao etica (opcional mas recomendado)
```

**`process-log.md` deve conter:**
- Data/hora de cada passo
- Modelo(s) de IA usado(s)
- Prompts enviados (sem respostas completas — apenas intencao)
- Decisoes humanas tomadas
- Resultados de provenance verification

---

## Riscos de Contaminacao

| Risco | Descricao | Mitigacao |
|-------|-----------|-----------|
| **Training data** | LLM foi treinado no codigo original | Usar modelos com dados de treino documentados; aceitar que risco nao e eliminavel |
| **Developer familiarity** | Humano conhece profundamente o original | Minimizar steering humano; documentar todos os prompts |
| **Cross-session leakage** | Mesma sessao IA para analise e implementacao | Sessoes estritamente isoladas; modelos diferentes se possivel |
| **Spec leakage** | Detalhes de expressao na spec | Gate de sanitizacao (Passo 2) com checklist |
| **Test copying** | Testes copiados do projeto original | Gerar testes da spec, NUNCA do test suite original |
| **Naming contamination** | Mesmos nomes de funcao/variavel | Renomear deliberadamente; vocabulario proprio |

> **Questao legal aberta (abril 2026):** Nenhum tribunal decidiu se treinamento em codigo copyleft invalida o status de "sala limpa" da LLM. O caso chardet 7.0.0 e o mais proximo de um teste, mas nao chegou a tribunal. Proceder com cautela.

---

## Progressive Disclosure

| Nivel | Trigger | Comportamento |
|-------|---------|---------------|
| **Spec-Only** | "documenta comportamento", "gera spec de X" | Executar apenas Passos 1-2. Entregar spec sanitizada |
| **Full Clean Room** | "reimplementa", "reescreve sem copiar", "clean room" | Workflow completo 7 passos |
| **Audit** | "verifica contaminacao", "audit provenance" | Executar Passo 5 em codigo existente + relatorio |
| **Defense** | "proteger meu open source", "defender contra clean room" | Secao 9 — estrategias de defesa |

---

## Framework Etico

> **Legal ≠ Legitimo.** Algo pode ser juridicamente valido e eticamente questionavel.

### Checklist etico OBRIGATORIO antes de iniciar clean room:

```
REFLEXAO PRE-EXECUCAO
[ ] O projeto original e mantido por voluntarios/independentes?
    → Se sim: considerar contribuicao upstream ou patrocinio ANTES de reimplementar
[ ] O maintainer depende de contribuicoes para sustentar o projeto?
    → Se sim: clean room pode drenar o ecossistema que voce esta usando
[ ] Existe alternativa com licenca permissiva (MIT/Apache)?
    → Se sim: usar a alternativa. Clean room so quando necessario
[ ] Voce esta disposto a dar credito publico ao projeto original?
    → Criar ATTRIBUTION.md mesmo sem obrigacao legal
[ ] A reimplementacao beneficia a comunidade ou apenas sua empresa?
    → Se so sua empresa: refletir sobre o impacto

TRANSPARENCIA
[ ] Documentar que IA foi usada no processo
[ ] Manter ATTRIBUTION.md com credito ao projeto inspirador
[ ] Se publicar: ser transparente sobre a origem da spec
```

**Citacao de Hong Minhee (2026):**
> *"Se essa tecnica e legitima, todo projeto copyleft existente esta a uma sessao de Claude de virar MIT."*

---

## Estrategias de Defesa (para Maintainers Open Source)

### Licencas Defensivas

| Licenca | Protecao | Usada por | Limitacao |
|---------|----------|-----------|-----------|
| **AGPL v3** | Obriga disclosure em uso via rede | Redis (2025), Elastic | Nao impede clean room da spec |
| **SSPL** | Obriga abrir TODO o stack de servico | MongoDB | Nao e OSI-approved |
| **FSL** (Functional Source License) | Proibe competir por tempo limitado, depois vira open | Sentry | Tempo-limitada |
| **BSL** (Business Source License) | Source-available, converte para open apos delay | MariaDB, CockroachDB, HashiCorp | Nao e open source |
| **Dual License** | GPL + licenca comercial paga | Muitos enterprise OSS | Requer CLA |

### Estrategias Nao-Licenciarias

| Estrategia | Como funciona |
|-----------|---------------|
| **CLA (Contributor License Agreement)** | Contribuidores cedem IP ao projeto — projeto tem standing legal para enforcement |
| **DCO (Developer Certificate of Origin)** | Contribuidor certifica autoria — conflita com codigo IA |
| **AI Ban Policy** | Proibir contribuicoes geradas por IA (ex: QEMU) |
| **Test suite como moat** | Suite de testes massiva e anos de edge cases = dificil de replicar |
| **Ecossistema como moat** | Plugins, integracao, comunidade, docs ricas = valor alem do codigo |
| **Monetizacao de servico** | Managed service, SLA, suporte = moat operacional |

### Modelo Redis (Case Study)

```
2024: BSD → Dual SSPL + RSALv2 (gatilhou fork Valkey pela Linux Foundation/AWS/Google)
2025: Adicionou AGPLv3 (voltou a ser OSI-approved)
Licao: Mudancas agressivas de licenca gatilham forks. Comunidade tem poder.
```

---

## Handoff Points

| Quando | Repassar para | Condicao |
|--------|--------------|----------|
| Codigo toca auth/crypto/dados sensiveis | `security-audit` | Auditoria profunda obrigatoria |
| Codigo gerado precisa de review de qualidade | `code-review` | Apos Passo 4 (implementacao) |
| Reimplementacao e parte de projeto maior com fases | `spec-driven-core` | Pipeline Epic→Phases→Verify |
| Vulnerabilidade especifica encontrada | `/cyber` | Router de 572 skills cybersecurity |
| Pre-deploy do codigo reimplementado | `vibe-deploy-guard` | 18 checks de seguranca |
| Codigo precisa de testes adicionais | `spec-verify` | Verificacao contra spec |

---

## Referencias

### Jurisprudencia
- Baker v. Selden (1879) — SCOTUS, dicotomia ideia-expressao
- Compaq BIOS (1982) — Modelo two-team validado
- Sega v. Accolade (1992) — Reverse engineering = fair use
- Oracle v. Google (2021) — SCOTUS 6-2, APIs = fair use

### Casos Contemporaneos (2025-2026)
- Cloudflare vinext — Reimplementacao Next.js em 1 semana com IA
- chardet 7.0.0 — Rewrite LGPL→MIT via Claude Code (Dan Blanchard, marco 2026)
- MALUS (FOSDEM, fevereiro 2026) — "Clean Room as a Service" demonstracao
- Claw Code — Clean-room Rust rewrite do Claude Code (50k stars em 2h)
- Doe v. GitHub/Copilot (2022+) — Licencas open source = contratos validos

### Especialistas
- **Heather Meeker** — "AI Could Be Your Next Team for Clean Room Development" (marco 2025)
- **Simon Willison** — Analise chardet: "argumentos dos dois lados sao inteiramente crediveis"
- **Hong Minhee** — "Legal e o mesmo que legitimo?" (marco 2026)
- **Red Hat** — Recomendacoes para codigo assistido por IA (disclosure, oversight, project rules)

### Organizacoes
- Linux Foundation — DCO e politicas de IA
- QEMU — Ban formal de contribuicoes geradas por IA
- FSF — GPL e copyleft enforcement

> **Templates detalhados:** `references/spec-templates.md`
> **Cases legais completos:** `references/legal-cases.md`
> **Edge cases e armadilhas:** `gotchas.md`
