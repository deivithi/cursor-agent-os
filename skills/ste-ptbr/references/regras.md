# STE-PT — Regras de escrita

Parte 1 da especificação adaptada. A Parte 2 (dicionário) está em `dicionario.json`.
Cada seção tem o código do linter que a verifica.

## Seção 1 — Palavras (E04)

1. Use só palavras aprovadas ou nomes técnicos.
2. Use cada palavra com um só sentido e uma só classe gramatical.
3. Use a mesma palavra para a mesma coisa em todo o texto.
4. Não troque a palavra por sinônimo para "variar". Variação faz o leitor achar que são duas coisas.

| Palavra aprovada | Sentido único | Não use para |
|---|---|---|
| VALIDAR | regra automática bloqueia dado inválido | conferência manual → VERIFICAR |
| VERIFICAR | conferir um valor | aceite formal → HOMOLOGAR |
| HOMOLOGAR | aceite do PO em homologação | teste automatizado → TESTAR |
| CONVERTER | Lead → Conta + Contato + Oportunidade | formato → TRANSFORMAR |
| SANITIZAR | limpar e padronizar campos | dado pessoal → ANONIMIZAR |
| PRÓXIMO | seguinte | distância → PERTO DE |

## Seção 2 — Grupos nominais (A07)

1. Use no máximo 3 palavras de conteúdo num grupo nominal.
2. Quebre cadeias de "de": "a taxa de conversão de leads do evento" → "a conversão dos leads no evento".

## Seção 3 — Verbos (E04, E06, A09)

| Forma | Exemplo | Status |
|---|---|---|
| Imperativo | Exclua o lead duplicado. | ✓ aprovado |
| Presente | O job executa às 6h. | ✓ aprovado |
| Pretérito perfeito | O job executou às 6h. | ✓ aprovado |
| Futuro (ir + infinitivo) | O job vai executar às 6h. | ✓ aprovado |
| Infinitivo | Use o filtro para encontrar o lead. | ✓ aprovado |
| Particípio como adjetivo | o lead convertido | ✓ aprovado |
| Futuro do subjuntivo, só em condição | Se o lead for duplicado, exclua o lead. | ✓ aprovado |
| Gerundismo | Vou estar enviando o relatório. | ✕ não aprovado |
| Futuro do pretérito | O job deveria executar às 6h. | ✕ não aprovado (o linter dá aviso A09) |
| "Deverá" / "deve-se" em procedimento | O analista deverá exportar. | ✕ não aprovado |
| Passiva em procedimento | O campo deve ser preenchido. | ✕ não aprovado |

## Seção 4 — Frases (E02)

1. Escreva uma ideia por frase.
2. Frase descritiva: máximo 25 palavras.
3. Não omita artigo nem preposição. "Abra o lead" e não "Abra lead".

## Seção 5 — Procedimentos (E01, E08)

1. Escreva cada passo como item numerado ou item de checklist (`- [ ]`).
   Uma linha indentada logo abaixo continua o mesmo passo e conta no mesmo limite.
2. Comece o passo com o verbo no imperativo.
3. Escreva uma instrução por passo. Exceção: duas ações simultâneas.
4. Máximo 20 palavras por passo.
5. Escreva a condição antes da ação: "Se o status for Qualificado, converta o lead."

## Seção 6 — Texto descritivo (E03)

1. Escreva o tópico na primeira frase do parágrafo.
2. Máximo 6 frases por parágrafo. Um tópico por parágrafo.
3. Use lista vertical para texto complexo.

## Seção 7 — Avisos de segurança

1. Escreva o comando primeiro. Depois, escreva o risco.
2. `⛔ BLOQUEIO:` perda irreversível de dados (DROP, DELETE em massa, deploy em produção, LGPD).
3. `⚠️ ATENÇÃO:` dado errado ou retrabalho (comissão, duplicado, regra de lead do Método CIS).
4. O linter trata a linha de aviso como procedimento (limite de 20 palavras por frase).
5. Em artefato formal (Jira, Confluence, e-mail externo), escreva só `BLOQUEIO:` ou `ATENÇÃO:`, sem emoji (AGENTS.md §7).

## Seção 8 — Pontuação e contagem

1. Palavra com hífen ou sublinhado conta 1 (e-mail, Data_Evento__c).
2. Número conta 1 (1.000, 6h, 25%).
3. Código inline, link Markdown e URL contam 1.
4. Rótulo `[conf: X]` conta 0.
5. Não use ponto e vírgula em procedimento. Faça dois passos.

## Seção 9 — Práticas de escrita (E04)

1. Escreva o número exato. "Cerca de" só quando o número exato não existe.
2. Não use `etc.`. Liste os itens.
3. Não use `e/ou`. Escolha "e" ou "ou".
4. Não use "o mesmo" como pronome. Repita o nome.
5. Escreva o fato. Remova `vale ressaltar`, `é importante destacar`, `no cenário atual`.

## Nível 80 — "80% do caminho"

Karpathy sugere pedir "80% do caminho até o ASD-STE100" quando o estrito fica rígido demais.

| Item | Nível 100 | Nível 80 |
|---|---|---|
| Limite do procedimento | 20 | 25 |
| Limite do descritivo | 25 | 30 |
| Frases por parágrafo | 6 | 8 |
| Categoria `registro` (efetuar, utilizar) | erro | aviso |
| Categoria `verbo` (deverá) | erro | aviso |
| Categoria `slop` e `ambiguidade` | erro | erro |
| Voz passiva em procedimento | erro | aviso |
