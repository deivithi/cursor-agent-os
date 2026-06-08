# Templates — Clean Room Engineering

> Templates reutilizaveis para cada passo do workflow de 7 passos.
> Copie, adapte e preencha conforme necessidade.

---

## Template 1: Behavioral Specification

```markdown
# Behavioral Specification — [NOME DO SOFTWARE]

## Metadata
- **Software alvo:** [nome e versao]
- **Data da analise:** [DD/MM/YYYY]
- **Fontes consultadas:** [docs oficiais, README, tutoriais — listar URLs]
- **Analista:** [nome]
- **Status:** [ ] Draft  [ ] Sanitizado  [ ] Aprovado

---

## 1. Proposito
[Uma frase descrevendo o que o software faz]

## 2. Interfaces Publicas

### 2.1 Funcao/API: `[nome_descritivo]`
- **Descricao:** [o que faz]
- **Input:** [tipo e formato]
- **Output:** [tipo e formato]
- **Erros:** [condicoes de erro e mensagens esperadas]
- **Edge cases:**
  - [caso 1]: [comportamento esperado]
  - [caso 2]: [comportamento esperado]

### 2.2 Funcao/API: `[nome_descritivo]`
[repetir estrutura acima]

## 3. Comportamento Global
- **Inicializacao:** [como o software inicializa]
- **Estado:** [stateful ou stateless? que estado mantem?]
- **Concorrencia:** [thread-safe? async?]
- **Performance:** [bounds conhecidos — tempo, memoria]

## 4. Formatos de Dados
- **Input format:** [JSON, CSV, binario, etc + estrutura]
- **Output format:** [idem]
- **Configuracao:** [parametros, env vars, arquivos de config]

## 5. Restricoes e Limites
- [limite de tamanho de input]
- [caracteres especiais]
- [encoding suportado]
- [plataformas suportadas]

## 6. Notas de Sanitizacao
- [ ] Nenhum nome de variavel/funcao do original
- [ ] Nenhum algoritmo especifico descrito
- [ ] Apenas comportamento observavel
- [ ] Revisado por: [nome] em [data]
```

---

## Template 2: Provenance Report

```markdown
# Provenance Report — [NOME DO PROJETO]

## Metadata
- **Data:** [DD/MM/YYYY]
- **Projeto original:** [nome, versao, licenca]
- **Projeto reimplementado:** [nome, versao, licenca atribuida]
- **Responsavel:** [nome]

---

## 1. Processo Executado

| Passo | Data | Artefato | Modelo IA |
|-------|------|----------|-----------|
| 1. Behavioral Analysis | [data] | spec/behavioral-analysis.md | [modelo ou N/A] |
| 2. Spec Sanitization | [data] | spec/sanitized-spec.md | Revisao humana |
| 3. Test Generation | [data] | tests/ | [modelo] |
| 4. Implementation | [data] | src/ | [modelo — diferente do passo 1] |
| 5. Provenance Check | [data] | Este documento | [ferramenta] |
| 6. Validation | [data] | audit/validation-results.md | Automatizado |
| 7. License Assignment | [data] | LICENSE | Decisao humana |

## 2. Isolamento

- [ ] Sessoes de IA separadas para analise (Passo 1) e implementacao (Passo 4)?
- [ ] Modelos diferentes usados? Se nao, justificar:
- [ ] Desenvolvedor tinha conhecimento previo do codigo original? Nivel: [ ] Nenhum [ ] Basico [ ] Profundo
- [ ] Medidas de mitigacao para conhecimento previo:

## 3. Similaridade

### Ferramenta: [JPlag / MOSS / difflib / outra]

| Metrica | Resultado | Threshold | Status |
|---------|-----------|-----------|--------|
| Token similarity | [X%] | < 15% | [OK/ALERTA/CRITICO] |
| Identical line ratio | [X%] | < 5% | [OK/ALERTA/CRITICO] |
| Function name overlap | [X%] | < 10% | [OK/ALERTA/CRITICO] |
| Structure similarity | [X%] | < 20% | [OK/ALERTA/CRITICO] |

### Detalhes
- Arquivos com maior similaridade: [listar]
- Justificativa para similaridades acima do threshold: [explicar — ex: padrao universal]

## 4. Validacao

- Total de testes: [N]
- Passando: [N] ([X%])
- Falhando: [N] (justificativas:)
- Cobertura estimada: [X%]

## 5. Decisao de Licenca

- **Licenca atribuida:** [MIT / Apache-2.0 / outra]
- **Justificativa:** [por que esta licenca foi escolhida]
- **ATTRIBUTION.md criado?** [ ] Sim  [ ] Nao (justificar)

## 6. Conclusao

[ ] Processo clean room seguido integralmente
[ ] Provenance verification dentro dos thresholds
[ ] Testes passando
[ ] Licenca atribuida com justificativa
[ ] Documentacao completa

**Assinado por:** [nome] — [data]
```

---

## Template 3: Checklist Rapido (Pre-Execucao)

```markdown
## Clean Room Pre-Flight Checklist

### Etica
[ ] Projeto original e mantido por empresa (nao voluntarios)?
[ ] Existe alternativa com licenca permissiva?
[ ] ATTRIBUTION.md sera criado?
[ ] Contribuicao upstream foi considerada?

### Isolamento
[ ] Fontes de analise: APENAS documentacao publica?
[ ] Spec sanitizada: APENAS O QUE, nunca COMO?
[ ] Implementacao em sessao/modelo isolado?
[ ] Zero acesso ao codigo-fonte original durante implementacao?

### Verificacao
[ ] Test suite gerada da spec (nao do test suite original)?
[ ] Provenance check executado (JPlag/MOSS)?
[ ] Todos os thresholds de similaridade OK?
[ ] Testes passando 100%?

### Documentacao
[ ] behavioral-analysis.md criado?
[ ] sanitized-spec.md criado e revisado?
[ ] provenance-report.md preenchido?
[ ] process-log.md com timeline completa?
[ ] LICENSE atribuido?
```

---

## Template 4: ATTRIBUTION.md (Credito Etico)

```markdown
# Attribution

This project was independently implemented using clean room engineering methodology.

## Inspiration

This software was inspired by the **public behavior and documentation** of
[NOME DO PROJETO ORIGINAL] ([URL]), originally licensed under [LICENCA ORIGINAL].

No source code from the original project was read, copied, or referenced during
implementation. The behavioral specification was derived exclusively from public
documentation and observable behavior.

## Process

- Behavioral analysis: [data]
- Independent implementation: [data]
- Provenance verification: [ferramenta] — [X%] similarity (threshold: <15%)
- Full process documentation available in `audit/`

## Acknowledgment

We acknowledge and appreciate the work of the original maintainers and contributors
of [PROJETO ORIGINAL]. Their public documentation and API design informed our
behavioral specification.

If you maintain or contribute to [PROJETO ORIGINAL], consider supporting them:
- [link para patrocinio/donation]
- [link para contribuicao]
```
