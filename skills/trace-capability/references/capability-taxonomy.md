# Taxonomia de Capacidades — v1.0

> Categorias nomeadas e estáveis para classificar gaps de capacidade de agentes.
> Nova capacidade confirmada após aparecer em 2+ análises independentes.

---

## IG — Information Gathering (Coleta de Informação)

| ID | Nome | Descrição | Sinais de Falha |
|---|---|---|---|
| IG-01 | Source Completeness | Agente lê todas as fontes relevantes antes de agir | Decisão baseada em leitura parcial; arquivo relevante ignorado |
| IG-02 | Context Verification | Agente verifica pressupostos contra estado real | Assume estado sem checar; usa info desatualizada |
| IG-03 | Iterative Retrieval | Agente faz buscas de follow-up quando primeira é insuficiente | Para na primeira busca; aceita resultado incompleto |

## PR — Planning & Reasoning (Planejamento e Raciocínio)

| ID | Nome | Descrição | Sinais de Falha |
|---|---|---|---|
| PR-01 | Decomposition | Agente quebra tarefas complexas em sub-tarefas ordenadas | Tenta resolver tudo de uma vez; pula etapas |
| PR-02 | Edge Case Awareness | Agente considera condições de contorno | Só testa happy path; ignora inputs extremos |
| PR-03 | Dependency Ordering | Agente respeita ordem de dependências | Executa passos fora de ordem; referência antes de definição |

## TU — Tool Selection & Use (Seleção e Uso de Ferramentas)

| ID | Nome | Descrição | Sinais de Falha |
|---|---|---|---|
| TU-01 | Right Tool | Agente escolhe a ferramenta mais apropriada | Usa Bash quando deveria usar Read; grep em vez de Grep |
| TU-02 | Tool Chaining | Agente encadeia ferramentas corretamente | Resultado de tool A não alimenta tool B; dados perdidos entre calls |
| TU-03 | Error Recovery | Agente trata erros de ferramentas graciosamente | Ignora erro e continua; repete mesma call sem ajuste |

## OQ — Output Quality (Qualidade de Saída)

| ID | Nome | Descrição | Sinais de Falha |
|---|---|---|---|
| OQ-01 | Structural Compliance | Saída segue formato/estrutura esperada | YAML malformado; seções faltando; template ignorado |
| OQ-02 | Completeness | Todos os campos/seções obrigatórios presentes | Entrega parcial; "TODO" deixados; items faltando |
| OQ-03 | Actionability | Saída permite ação imediata sem ambiguidade | Instruções vagas; próximo passo unclear; dependências não listadas |

## SR — Self-Regulation (Auto-Regulação)

| ID | Nome | Descrição | Sinais de Falha |
|---|---|---|---|
| SR-01 | Scope Control | Agente permanece dentro dos limites da skill | Escopo creep; modifica arquivos não relacionados |
| SR-02 | Halt Condition | Agente reconhece quando parar de iterar | Loop infinito; continua sem progresso; ignora stagnation |
| SR-03 | Validation | Agente verifica própria saída antes de entregar | Entrega sem testar; não roda eval; não checa resultado |

---

## Regras de Governança

1. **Estabilidade:** IDs são permanentes. Nunca reutilizar um ID deletado
2. **Adição:** Nova capacidade requer evidência em 2+ análises contrastivas independentes
3. **Remoção:** Capacidade só é removida se 0 ocorrências em 20+ análises consecutivas
4. **Extensão:** Novas dimensões (ex: CO — Collaboration) podem ser adicionadas seguindo o mesmo formato
5. **Rastreabilidade:** Cada gap identificado referencia o ID da taxonomia no relatório
