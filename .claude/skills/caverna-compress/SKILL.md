---
name: caverna-compress
description: >
  Comprime arquivos de linguagem natural (CLAUDE.md, todos, preferences) em formato
  caverna PT-BR p/ economizar tokens input. Preserva toda substância técnica, código,
  URLs, estrutura E acentos. Versão comprimida sobrescreve original. Backup legível
  salvo como ARQUIVO.original.md.
  Trigger: /caverna-compress <caminho> ou "comprime arquivo de memória"
type: tool
---

# 🪨 Caverna Compress

## Propósito

Comprime arquivos de linguagem natural (CLAUDE.md, todos, preferences) em caverna-speak PT-BR p/ reduzir tokens input. Versão comprimida sobrescreve original. Backup legível salvo como `<arquivo>.original.md`.

## Trigger

`/caverna-compress <caminho>` ou quando user pede p/ comprimir arquivo de memória.

## Processo

1. Identifica tipo de arquivo (via extensão)
2. Lê conteúdo original
3. Backup: copia p/ `<arquivo>.original.md`
4. Aplica regras de compressão PT-BR (ver abaixo)
5. Valida: heading preservadas, code blocks intactos, URLs exatas, acentos mantidos
6. Se falhar: restaura do backup, reporta erro
7. Se OK: sobrescreve arquivo original

## Regras de compressão

### Remover
- Artigos: o, a, os, as, um, uma, do/da/dos/das, no/na/nos/nas, ao/aos, à/às
- Filler: basicamente, realmente, literalmente, simplesmente, apenas, meio que, tipo
- Pleasantries: "claro", "certamente", "com prazer", "posso te ajudar"
- Hedging: "talvez", "pode ser", "acho que", "parece que", "aparentemente"
- Frases redundantes: "para que" → "p/", "fazer com que" → "fazer", "a razão é porque" → "porque"
- Conectivos-enfeite: "entretanto", "além disso", "adicionalmente", "por outro lado"

### Preservar EXATAMENTE (nunca modificar)
- 🇧🇷 **Acentos** (á, é, ç, ã, ô, ó, ú, í, ü, â, ê) — REGRA INVIOLÁVEL
- 😀 **Emojis** (🔴, 🟡, 🔵, ⚠️, ✅, ❌, 🛡️, 🪨, etc.)
- Code blocks (cercados ``` e indentados)
- Código inline (`conteúdo em backtick`)
- URLs e links (URLs completas, markdown links)
- Caminhos de arquivo (`/src/components/...`, `./config.yaml`)
- Comandos (`npm install`, `git commit`, `docker build`)
- Termos técnicos (nomes de lib, API, protocolos, algoritmos)
- Nomes próprios (projetos, pessoas, empresas) — Deivithi, Febracis, Pulso, Aria
- Datas, versões, valores numéricos
- Variáveis env (`$HOME`, `NODE_ENV`)
- **Vocabulário Febracis** — Método CIS, DRE, Salesforce, Sales/Service/Experience/Marketing Cloud

### Preservar estrutura
- Todas markdown headings (texto exato, comprime só body abaixo)
- Hierarquia de bullets (nível de indentação)
- Listas numeradas (numeração)
- Tabelas (comprime célula, mantém estrutura)
- Frontmatter YAML em arquivos markdown

### Comprimir
- Sinônimos curtos: "grande" não "extensivo", "corrigir" não "implementar solução p/", "usar" não "utilizar"
- Fragmentos OK: "Roda testes antes de commit" não "Você deve sempre rodar os testes antes de commitar"
- Dropar "você deve", "certifique-se de", "lembre-se de" — só escreve a ação
- Mergear bullets redundantes que dizem o mesmo de formas diferentes
- Manter UM exemplo quando múltiplos mostram o mesmo padrão

### REGRA CRÍTICA
Qualquer coisa dentro de ``` ... ``` copiada EXATAMENTE.
Não:
- remover comentários
- remover espaçamento
- reordenar linhas
- encurtar comandos
- simplificar nada

Código inline (`...`) preservado EXATAMENTE. Não modifica nada dentro de backticks.

Se arquivo tem code blocks:
- Trata blocos como regiões read-only
- Só comprime texto fora deles
- Não mergeia seções ao redor de código

## Padrão

Original:
> Você sempre deve se certificar de rodar a suíte de testes antes de fazer push de qualquer mudança pra branch main. Isso é importante porque ajuda a pegar bugs cedo e previne builds quebradas sendo deployadas em produção.

Comprimido:
> Roda testes antes de push p/ main. Pega bugs cedo, previne prod quebrado.

Original:
> A aplicação usa uma arquitetura de microsserviços com os seguintes componentes. O API gateway trata todas as requisições que chegam e roteia p/ o serviço apropriado. O serviço de autenticação é responsável por gerenciar sessões de usuário e tokens JWT.

Comprimido:
> Arquitetura microserviços. API gateway roteia reqs p/ serviços. Serviço aut gerencia sessões user + tokens JWT.

## Limites

- SÓ comprime arquivos de linguagem natural (.md, .txt, sem extensão)
- NUNCA modifica: .py, .js, .ts, .json, .yaml, .yml, .toml, .env, .lock, .css, .html, .xml, .sql, .sh, .ps1
- Se arquivo tem conteúdo misto (prosa + código), comprime SÓ seções de prosa
- Se incerto se algo é código ou prosa, deixa inalterado
- Arquivo original backup como FILE.original.md antes de sobrescrever
- Nunca comprime FILE.original.md (pula)
- **NUNCA dropa acentos** — valida output final com regex `[áéíóúâêôãçü]`
