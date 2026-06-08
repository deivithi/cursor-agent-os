# Template de Documentacao de Projeto

> Use este template para documentar projetos longos com ondas/fases.
> Inspirado no GitHub Spec-Kit (Constitution), Addy Osmani (6 core areas),
> e nas praticas de Harness Engineering (OpenAI, Anthropic, Martin Fowler).

---

## Como usar

1. Copiar este template para `docs/project-[nome].md` na raiz do projeto
2. Preencher cada secao progressivamente (nao precisa tudo de uma vez)
3. Atualizar `Current State` ao final de cada onda/fase
4. Manter no git como living document

---

```markdown
# [Nome do Projeto]

## 1. Vision & Goals

### Problema
[Qual problema estamos resolvendo e para quem]

### Objetivo
[O que o sistema faz quando estiver pronto — comportamento observavel]

### Metricas de Sucesso
- [ ] [Metrica mensuravel 1]
- [ ] [Metrica mensuravel 2]

---

## 2. Boundaries (3-Tier)

> Derivado do Addy Osmani / GitHub analysis de 2500+ agent configurations.

### Always Do (sem perguntar)
- Rodar testes antes de commitar
- Seguir conventions do style guide
- Logar erros para monitoramento
- [projeto-especifico]

### Ask First (requer aprovacao humana)
- Modificar schemas de banco de dados
- Adicionar novas dependencias
- Alterar configuracoes de CI/CD
- Mudancas arquiteturais significativas
- [projeto-especifico]

### Never Do (proibicoes absolutas)
- Commitar secrets ou API keys
- Editar node_modules/ ou vendor/
- Remover testes que estao falhando sem aprovacao
- Operacoes destrutivas em dados de producao
- [projeto-especifico]

---

## 3. Tech Stack

| Camada | Tecnologia | Versao | Justificativa |
|--------|------------|--------|---------------|
| Frontend | [framework] | [x.y.z] | [por que] |
| Backend | [framework] | [x.y.z] | [por que] |
| Database | [DB] | [x.y.z] | [por que] |
| Deploy | [plataforma] | — | [por que] |
| CI/CD | [ferramenta] | — | [por que] |

### Dependencias-chave
- [lib]: [versao] — [para que serve]

---

## 4. Architecture

### Diagrama
[Diagrama Mermaid — graph, C4, ou flowchart]

### Decisoes Arquiteturais (ADRs)

#### ADR-001: [Titulo da decisao]
- **Data:** [DD/MM/YYYY]
- **Status:** Aceita / Proposta / Superseded
- **Contexto:** [Por que essa decisao foi necessaria]
- **Decisao:** [O que decidimos]
- **Alternativas descartadas:** [O que consideramos e por que rejeitamos]
- **Consequencias:** [O que muda por causa dessa decisao]

#### ADR-002: [Titulo]
...

---

## 5. Waves (Ondas de Desenvolvimento)

> Cada onda e uma unidade de entrega independente com milestone verificavel.
> Formato: Onda → Sprints → Features → Acceptance Criteria.

### Onda 1: [Nome — ex: Fundacao]
**Objetivo:** [o que esta onda entrega]
**Status:** Concluida / Em Progresso / Pendente
**Data:** [DD/MM/YYYY inicio] → [DD/MM/YYYY fim]

| Sprint | Features | Status | Score |
|--------|----------|--------|-------|
| Sprint 1.1: [nome] | [feature A, B] | Done | 0.95 |
| Sprint 1.2: [nome] | [feature C] | Done | 0.88 |

**Milestone:** [Como sabemos que esta onda esta completa]
**Aprendizados:** [O que descobrimos durante esta onda]

### Onda 2: [Nome — ex: Core Features]
**Objetivo:** [o que esta onda entrega]
**Status:** Em Progresso
**Depende de:** Onda 1

| Sprint | Features | Status | Score |
|--------|----------|--------|-------|
| Sprint 2.1: [nome] | [feature D, E] | In Progress | — |
| Sprint 2.2: [nome] | [feature F] | Pending | — |

### Onda N: [Nome]
...

---

## 6. Current State (auto-atualizado)

> Atualizar ao final de cada onda ou sprint significativo.

**Ultima atualizacao:** [DD/MM/YYYY HH:MM BRT]
**Onda atual:** [N] — [nome]
**Sprint atual:** [N.M] — [nome]
**Proxima acao:** [o que precisa acontecer em seguida]

### Health Check
| Dimensao | Status | Nota |
|----------|--------|------|
| Funcionalidade | OK / Warning / Critical | [detalhe] |
| Performance | OK / Warning / Critical | [detalhe] |
| Seguranca | OK / Warning / Critical | [detalhe] |
| Documentacao | OK / Warning / Critical | [detalhe] |
| Testes | OK / Warning / Critical | [coverage %] |

### Issues Conhecidos
| # | Issue | Severidade | Onda de Correcao |
|---|-------|-----------|-----------------|
| 1 | [descricao] | Critical/Major/Minor | [onda N] |

---

## 7. Progress Log

> Registro cronologico de marcos importantes.

| Data | Onda | Evento | Impacto |
|------|------|--------|---------|
| [DD/MM/YYYY] | 1 | Fundacao concluida | Base pronta |
| [DD/MM/YYYY] | 2 | Feature X entregue | Core funcional |
```

---

## Regras de Uso

1. **Living document** — manter atualizado no git, nao deixar virar snapshot obsoleto
2. **ADRs sao permanentes** — nao deletar ADRs antigos, marcar como "Superseded by ADR-XXX"
3. **Waves sao sequenciais** — cada onda depende da anterior (explicitar se paralela)
4. **Current State e a verdade** — se conflitar com o codigo, o codigo vence; atualizar o doc
5. **Boundaries sao enforcement** — alimentam spec-evaluate (C8) e spec-verify (sensores)
