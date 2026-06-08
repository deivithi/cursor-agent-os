# 🪨 Caverna Compress — Comprime Arquivo em Caverna PT-BR

Comprime arquivo de linguagem natural (.md, .txt) em formato caverna p/ economizar tokens input. Uso: `/caverna-compress <caminho>`.

## Ação

Ativa skill `caverna-compress`. Pipeline:

1. Lê arquivo
2. Backup em `<arquivo>.original.md`
3. Aplica regras de compressão PT-BR
4. Valida (headings, code blocks, URLs, **acentos**)
5. Se OK: sobrescreve original
6. Se falhar: restaura backup

## Remove

- Artigos (o/a/os/as/um/uma/do/da)
- Filler (basicamente/realmente/literalmente/simplesmente)
- Pleasantries (claro/certamente/com prazer)
- Hedging (talvez/pode ser/acho que)
- Frases redundantes ("para que" → "p/")

## Preserva EXATAMENTE

- 🇧🇷 **Acentos** (á/é/ç/ã/ô) — INVIOLÁVEL
- 😀 **Emojis**
- Code blocks (``` e indentados)
- Código inline (`...`)
- URLs, caminhos, comandos
- Termos técnicos (useMemo, async)
- Nomes próprios (Deivithi, Febracis, Pulso)
- **Vocabulário Febracis** — Método CIS, DRE, Salesforce
- Datas, versões, env vars

## Exemplo

**Antes:**
> Você sempre deve se certificar de rodar a suíte de testes antes de fazer push de qualquer mudança para a branch main. Isso é importante porque ajuda a pegar bugs cedo.

**Depois:**
> Roda testes antes de push p/ main. Pega bugs cedo.

## Limites

- SÓ .md, .txt, sem extensão
- NUNCA modifica: .py, .js, .ts, .json, .yaml, .sql, .sh, .ps1
- Misto (prosa + código): comprime só prosa
- Nunca comprime `*.original.md` (pula)

## Meta

~46% economia de tokens input em arquivos naturais.

Ref: `.claude/skills/caverna-compress/SKILL.md`
