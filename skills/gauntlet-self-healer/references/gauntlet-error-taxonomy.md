# Taxonomia de Erros do Gauntlet & Estratégias de Autocorreção

Guia prático para classificação e resolução automatizada de falhas durante a execução do Gauntlet.

---

## 1. Classificação de Erros

| Classe | Causa Raiz Típica | Estratégia de Cura Automática |
|---|---|---|
| **E1: Syntax / Compilation** | Erro de sintaxe, imports inexistentes, parênteses/chaves desbalanceados. | 1. Localizar linha e coluna no traceback.<br>2. Corrigir símbolo ou import quebrado.<br>3. Recompilar com tool de sintaxe antes de rodar os testes. |
| **E2: Type-Checking (tsc, mypy)** | Propriedade inexistente, incompatibilidade de tipo `null`/`undefined`, type narrowing ausente. | 1. Revisar interfaces/tipos declarados.<br>2. Adicionar guard clauses (`if (x != null)`) ou type predicates.<br>3. **Nunca** usar `any` ou `@ts-ignore` indiscriminadamente. |
| **E3: Linter & Formatting (ruff, eslint)** | Variáveis não usadas, imports fora de ordem, regras de aspas ou trailing commas. | 1. Rodar ferramenta de fix automático (`ruff check --fix` ou `eslint --fix`).<br>2. Se persistir, remover variáveis órfãs manualmente. |
| **E4: Assertion Failure em Testes** | O valor retornado pela função difere do esperado pelo teste. | 1. Avaliar se o erro é regressão de código ou mock desatualizado.<br>2. Corrigir a lógica interna da função sob teste mantendo as asserções existentes.<br>3. Proibido relaxar ou remover asserções sem justificativa explícita. |
| **E5: Coverage Gap (< 80%)** | Branches condicionais (`if/else`, `try/catch`, early returns) não exercitados pelos testes. | 1. Inspecionar relatório de linhas faltantes (`coverage report -m`).<br>2. Criar casos de teste específicos para cobrir os fluxos de exceção e condições de borda. |
| **E6: Dependency / Env Missing** | Pacote ausente no `package.json` ou `requirements.txt`. | 1. Identificar módulo não encontrado.<br>2. Adicionar dependência ao manifesto e reinstalar no ambiente de isolamento. |

---

## 2. Regras de Não-Regressão

1. **Integridade de Testes:** É terminantemente proibido silenciar testes com `it.skip()`, `@pytest.mark.skip`, `pass` ou supressão de exceção só para passar no gauntlet.
2. **Escopo Atômico:** Cada correção de autocura deve focar exclusivamente no erro apontado pelo linter/runner.
3. **Limite de 3 Iterações:** Se em 3 tentativas o agente não conseguir passar o gauntlet de forma limpa, o fluxo deve parar imediatamente e exibir o traceback exato ao operador.
