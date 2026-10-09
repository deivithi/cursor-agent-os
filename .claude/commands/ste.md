# ✈️ STE-PT — Português Técnico Simplificado

Escreve ou reescreve texto em STE-PT (adaptação PT-BR do ASD-STE100). Uso: `/ste [80|reescreva|lint <arquivo>|off] [texto ou pedido]`

Carregue `skills/ste-ptbr/SKILL.md` e siga o workflow.

## Modos

| Comando | Efeito |
|---|---|
| `/ste <pedido>` | Responde o pedido em STE-PT nível 100 (estrito) |
| `/ste 80 <pedido>` | Responde em nível 80 ("80% do caminho", Karpathy) |
| `/ste reescreva <texto>` | Reescreve o texto em STE-PT e mostra o resultado do linter |
| `/ste lint <arquivo>` | Roda `scripts/ste_lint.py` no arquivo e corrige até zero erro |
| `/ste off` | Volta ao estilo padrão da sessão |

## Ação

1. Escreva com as regras de `skills/ste-ptbr/references/regras.md`.
2. Grave o texto em arquivo no scratchpad.
3. Rode o linter:
   ```bash
   PYTHONIOENCODING=utf-8 py skills/ste-ptbr/scripts/ste_lint.py <arquivo> --nivel 100
   ```
4. Corrija até zero erro.
5. Entregue o texto e a linha `Resultado:` do linter.

## Regras invioláveis

- Acento obrigatório (`rules/pt-br-acentos.md`).
- Não corte artigo nem preposição. STE desliga a caverna naquele texto.
- Nome técnico fica como está: Lead, Método CIS, deploy, org, job.
- Palavra da interface do Salesforce vence sinônimo: "Excluir", não `deletar`.
