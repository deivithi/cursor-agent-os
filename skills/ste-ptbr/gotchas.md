# ✈️ STE-PT — Gotchas

## Falsos positivos do linter

### "é + particípio" sem agente
"O lead é duplicado" descreve um estado. O linter só marca "é/são + particípio" quando há agente ("por", "pelo", "pela"). "Foi/será/ser + particípio" é sempre marcado, porque descreve um evento.

### Adjetivo terminado em -ido / -ado
"válido", "rápido", "resultado", "cuidado" estão na lista `ADJETIVOS_NAO_PASSIVOS`. Achou outro falso positivo? Adicione a palavra na lista e crie um teste.

### Cadeia de "de" com nome próprio
"Relatório de Comissões de Vendas do Método CIS" gera aviso A07. Se for nome de relatório do Salesforce, mantenha o nome. É nome técnico. O aviso não bloqueia.

### "etc" dentro de caminho
Caminho sem crase (`/etc/hosts` escrito sem a crase) gera E04. Ponha caminho, código e palavra citada sempre em crase.

### Comando em maiúsculas
Palavra toda em maiúsculas (DELETE, DROP) é nome técnico. O linter não aplica o dicionário a ela.

### "Em nível de"
"Segurança em nível de campo" é termo do Salesforce. O dicionário só marca `a nível de`.

### Futuro do pretérito
A09 é aviso, não erro. "Poderia" às vezes é pedido educado em e-mail. Em procedimento, troque pelo imperativo.

### Verbo igual a substantivo
"Isso alavanca a venda" (verbo) tem a mesma forma de "uma alavanca" (substantivo). O dicionário não marca `alavanca`, para não pegar o substantivo. Já `garante` é marcado mesmo como substantivo, porque o verbo é muito mais comum.

## Limites do linter (exige revisão do agente)

1. **Sentido não é detectável.** "Próximo" (seguinte) vs "próximo" (perto). "Validar" usado como "verificar". O agente revisa.
2. **Imperativo não é detectável.** O linter não sabe se o passo começa com verbo. O agente revisa.
3. **Duas instruções com "e" simples** ("Abra o lead e exclua o campo") passam no linter. O agente separa.

## Conflitos com outras regras

### Caverna
Caverna corta artigo ("Abre lead"). STE proíbe ("Abra o lead"). Texto em STE desliga a caverna só naquele texto.

### Calibration
`calibration.md` pede `[conf: X]` e "Premissa:". O rótulo conta 0 palavra. "Premissa:" é frase normal e conta.

### Termo técnico em inglês
deploy, org, job, sandbox, pipeline são nomes técnicos aprovados (ver `nomes_tecnicos` no dicionário). Não traduza: o time usa a palavra da ferramenta.

### Interface do Salesforce
Use a palavra que a tela mostra. A tela diz "Excluir", então o texto diz "excluir", não `deletar`.
