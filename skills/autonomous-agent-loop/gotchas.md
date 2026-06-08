# ⚠️ Gotchas — Autonomous Agent Loop

> Problemas conhecidos ao aplicar os padrões de agente autônomo. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## 1. Métrica de avaliação que muda entre iterações invalida todo o ledger

- **Sintoma:** Resultados do ledger (TSV) parecem inconsistentes — experimentos antigos parecem melhores/piores do que realmente eram
- **Causa raiz:** A métrica de sucesso foi alterada no meio do loop (ex: mudou de "taxa de conversão" para "taxa de conversão qualificada"). Isso viola o Padrão 3 (The Firewall — avaliação é imutável)
- **Solução:** Nunca alterar a métrica durante um ciclo de experimentos. Se precisar mudar, criar novo ledger e resetar o baseline
- **Prevenção:** Definir métrica no `Program.md` com label `IMMUTABLE`. O agente deve recusar instruções para alterá-la mid-loop
- **Descoberto em:** 2026-03-18

---

## 2. Blast radius excedido causa efeitos colaterais em componentes adjacentes

- **Sintoma:** Experimento modifica mais arquivos/componentes do que o escopo definido. Outros subsistemas quebram
- **Causa raiz:** O agente interpretou "otimizar scoring de leads" como permissão para alterar tanto as regras de scoring quanto o pipeline de ingestão de dados
- **Solução:** Definir blast radius EXPLICITAMENTE no `Program.md`: "Modifique APENAS o arquivo `scoring-rules.json`. Não toque em `pipeline.ts`"
- **Prevenção:** Usar Padrão 8 (Blast Radius) com lista whitelist de arquivos modificáveis, não blacklist
- **Descoberto em:** 2026-03-18

---

## 3. Git como lab notebook falha quando commits são squashados

- **Sintoma:** Histórico de experimentos desaparece após `git squash` ou `rebase -i`
- **Causa raiz:** O Padrão 10 (Git as Lab) depende de 1 commit = 1 experimento. Squash destrói essa relação
- **Solução:** Nunca squash em branches de experimentação. Usar branch dedicada `experiments/nome` com merge (não rebase) de volta para main
- **Prevenção:** Adicionar regra no `Program.md`: "Branch de experimentos: NUNCA rebase ou squash"
- **Descoberto em:** 2026-03-18

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (mais recentes primeiro, renumere)
2. Use o formato acima para consistência
3. Se um gotcha for resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->
