# TDD — Gotchas (Armadilhas Conhecidas)

## 1. "Teste verde de primeira" — suspeito

Se um teste novo passa sem você ter escrito o código, ele provavelmente testa o nada
(import errado, asserção sempre-verdadeira, mock que se auto-satisfaz). Veja-o falhar
primeiro (Red real) antes de implementar.

## 2. Mocar demais → testa o mock, não o sistema

Mock só nas fronteiras (rede, disco, relógio, aleatoriedade). Mocar lógica interna faz
o teste verificar a sua suposição sobre a implementação, não o comportamento real.

## 3. Assert frouxo disfarçado de robusto

`expect(x).toBeTruthy()` / `assert x is not None` passam com valores errados. Asserte o
valor exato. Frouxidão só quando o valor é legitimamente não-determinístico (e aí teste a
propriedade, ex.: `len == 10`, não o conteúdo).

## 4. Go: esquecer `-race`

`go test ./...` sem `-race` não detecta data races. Em código concorrente isso é um falso
verde perigoso. Sempre `go test -race ./...` (ver `golang-activate.md`).

## 5. Flaky por tempo/ordem

Testes que dependem de `sleep`, ordem de map, timezone ou `Date.now()` quebram
intermitentemente. Injete relógio/seed; ordene coleções antes de comparar. Flaky ≠ "rodar
de novo até passar".

## 6. Refactor que vira mudança de comportamento

No passo Refactor é tentador "melhorar" o que o código faz. Isso é novo comportamento →
exige novo ciclo Red. Refactor = só forma, suíte permanece verde sem editar asserção.

## 7. A tentação proibida: apagar o teste

Quando o teste teima em falhar perto do prazo, a saída fácil é `skip`/deletar. É
exatamente o antipadrão de `rules/test-integrity.md`. Corrija o código ou peça aceite
explícito com o porquê. Teste desabilitado não é "pronto".

## 8. Cobertura como meta, não como bússola

100% de cobertura com asserts fracos é pior que 70% com asserts de intenção. Cobertura
mede linhas executadas, não correção. Não persiga o número; persiga a intenção testada.

## 9. TDD em código legado sem testes

Não pare tudo p/ cobrir o legado. Aplique a regra do escoteiro: ao tocar uma função,
escreva o teste de caracterização (Red sobre o comportamento atual) antes de mudar.

## 10. Skill referenciada mas ausente

Esta skill resolve a referência quebrada que `alpha-loop` e `golang-activate.md`
apontavam. Se outra rule/skill referenciar uma skill inexistente, crie-a ou corrija a
referência — link morto em rule é bug, não detalhe.
