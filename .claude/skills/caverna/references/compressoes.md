# 📖 Tabela Completa — Compressões PT-BR → Ultra

## 1. Artigos (sempre dropar em completo/ultra)

| Original | Ultra |
|----------|-------|
| o, a, os, as | — (drop) |
| um, uma, uns, umas | — (drop) |
| do, da, dos, das | — (drop) |
| no, na, nos, nas | — (drop) |
| ao, aos | — (drop) |
| à, às | — (drop) |
| pelo, pela, pelos, pelas | — (drop) |

## 2. Preposições opcionais (dropar em ultra quando não ambíguo)

| Original | Ultra |
|----------|-------|
| de | — ou mantém se crítico |
| em | — ou mantém se crítico |
| para | p/ |
| com | c/ |
| sem | s/ |
| por | — quando óbvio |

## 3. Conectivos (dropar todos em ultra)

| Original | Ultra |
|----------|-------|
| porque, pois | → |
| então, logo | → |
| mas, porém, contudo, todavia | mas / — |
| além disso, ademais | + |
| portanto, assim | → |
| enquanto | durante |

## 4. Filler (SEMPRE dropar em todos modos)

| Filler | Ação |
|--------|------|
| basicamente | drop |
| realmente | drop |
| literalmente | drop |
| simplesmente | drop |
| apenas, só (quando filler) | drop |
| meio que, tipo | drop |
| de certa forma | drop |
| na verdade | drop |
| inclusive, aliás | drop |
| obviamente | drop |

## 5. Pleasantries (SEMPRE dropar)

| Original | Ação |
|----------|------|
| claro, certamente | drop |
| com prazer, sem problemas | drop |
| tranquilo, beleza | drop |
| deixa eu | drop |
| posso te ajudar com isso | drop |
| espero ter ajudado | drop |
| qualquer dúvida, avise | drop |

## 6. Hedging (SEMPRE dropar)

| Original | Ação |
|----------|------|
| talvez, pode ser | drop ou `?` |
| acho que, parece que | drop |
| aparentemente | drop |
| provavelmente, possivelmente | drop |
| de alguma forma | drop |
| eu diria que | drop |

## 7. Contrações e abreviações (Ultra)

| Original | Ultra |
|----------|-------|
| não | ñ |
| também | tb |
| porque | pq |
| que | q (só quando não ambíguo) |
| você | vc (opcional) |
| muito | mto |
| por que (interrogativo) | pq? |

## 8. Abreviações técnicas (Ultra)

| Completo | Ultra |
|----------|-------|
| banco de dados | BD |
| autenticação | aut |
| autorização | autz |
| configuração | config |
| requisição | req |
| resposta | res |
| função | fn |
| implementação | impl |
| variável | var |
| parâmetro | param |
| argumento | arg |
| documentação | docs |
| repositório | repo |
| aplicação | app |
| ambiente | env |
| produção | prod |
| desenvolvimento | dev |

## 9. Verbos longos → curtos

| Original | Comprimido |
|----------|-----------|
| implementar uma solução para | corrigir |
| realizar a execução de | executar |
| fazer a validação | validar |
| efetuar o cálculo | calcular |
| proceder com | — (verb direto) |
| necessário fazer | fazer |
| precisar de | precisa |

## 10. Frases-padrão → fragmentos

| Original | Ultra |
|----------|-------|
| O problema está em X. Você precisa Y. | X com bug. Fix: Y. |
| Para resolver isso, faça Z. | Fix: Z. |
| Você poderia considerar... | Opção: ... |
| Vale a pena mencionar que... | Nota: ... |
| Isso acontece porque... | Causa: ... |

## 11. Setas de causalidade (Ultra)

```
A porque B → A ← B
A então B → A → B
A causa B → A → B
A implica B → A → B
A depende de B → A ↤ B ou A needs B
```

## 12. Preservar SEMPRE (nunca comprimir)

- ✅ Código em ``` ``` ou `...`
- ✅ URLs completas
- ✅ Caminhos de arquivo (`/src/...`)
- ✅ Comandos shell (`npm install`, `git push`)
- ✅ Termos técnicos EN (useMemo, async, Promise)
- ✅ Nomes próprios (Deivithi, Febracis, Salesforce, Pulso, Aria)
- ✅ Datas, versões (v4.7.0, 2026-04-19)
- ✅ Variáveis env ($HOME, NODE_ENV)
- ✅ Acentos (á, é, ç, ã, ô)
- ✅ Emojis (🔴🟡🔵, 🛡️, ⚠️, ✅❌)
