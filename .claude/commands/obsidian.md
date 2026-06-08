# Obsidian — Agente de Knowledge Base

Operacao solicitada: **$ARGUMENTS**

## Vault
Caminho do vault: `C:\Users\PC\Documents\Obsidian Vault\`

## Subcomandos

### `/obsidian status`
Mostrar estatisticas do vault:
1. Usar `Glob` para listar todos os `.md` no vault
2. Contar total de notas por pasta
3. Listar as 10 notas mais recentes (por data de modificacao)
4. Extrair tags unicas encontradas nos frontmatters

### `/obsidian search <termo>`
Buscar termo em todas as notas do vault:
1. Usar `Grep` para buscar o termo em `C:\Users\PC\Documents\Obsidian Vault\**/*.md`
2. Mostrar resultados com contexto (3 linhas antes/depois)
3. Agrupar por pasta

### `/obsidian summarize`
Resumir notas modificadas nas ultimas 24h:
1. Usar `Bash` com `find` para listar arquivos modificados nas ultimas 24h no vault
2. Ler cada nota encontrada
3. Gerar resumo conciso de cada nota
4. Identificar temas recorrentes e conexoes entre notas

### `/obsidian create <titulo>`
Criar nova nota no vault:
1. Perguntar em qual pasta salvar (Projetos, Ideias, Reunioes, Aprendizados)
2. Se for reuniao, usar template `Templates/nota-reuniao.md`
3. Preencher frontmatter com data atual e tags
4. Salvar no caminho escolhido

### `/obsidian daily`
Gerar briefing diario manualmente:
1. Listar notas modificadas nas ultimas 24h
2. Ler conteudo de cada nota modificada
3. Buscar todas as tarefas pendentes (`- [ ]`) no vault inteiro
4. Identificar temas recorrentes e conexoes entre notas
5. Gerar briefing seguindo template `Templates/daily-briefing.md`
6. Salvar em `Daily Briefings/YYYY-MM-DD.md` (data de hoje)
7. Mostrar o briefing ao usuario

### `/obsidian weekly`
Gerar resumo semanal:
1. Ler todos os daily briefings da semana (`Daily Briefings/`)
2. Consolidar temas, tarefas completadas vs pendentes
3. Gerar retrospectiva semanal
4. Salvar em `Daily Briefings/weekly-YYYY-WNN.md`

## Regras
- NUNCA deletar notas sem confirmacao explicita
- Sempre preservar frontmatter existente ao editar notas
- Usar links internos do Obsidian (`[[nota]]`) quando referenciar outras notas
- Datas sempre em formato YYYY-MM-DD
- Tags em lowercase, sem espacos (usar hifens)
