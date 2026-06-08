# universal-docs — Gotchas & Problemas Conhecidos

## 1. Pandoc --pdf-engine=typst requer Typst no PATH
**Problema:** Se Typst não está no PATH, Pandoc falha silenciosamente ou gera erro obscuro.
**Solução:** Verificar `typst --version` antes. Após instalar via winget, pode ser necessário reiniciar o shell.

## 2. Fontes Typst: nem todas as fontes do sistema estão disponíveis
**Problema:** Typst usa suas próprias fontes embedded. Fontes do sistema podem não ser encontradas.
**Solução:** Usar `--font-path ./fonts/` para apontar para diretório de fontes locais, ou usar fontes padrão do Typst (New Computer Modern, etc.).

## 3. Pandoc PPTX→PDF perde formatação
**Problema:** Pandoc converte PPTX para PDF via intermediário texto, perdendo layout.
**Solução:** Para PPTX→PDF com fidelidade, usar LibreOffice CLI: `soffice --headless --convert-to pdf input.pptx`.

## 4. Tabelas Markdown complexas podem quebrar na conversão
**Problema:** Tabelas com células multiline, colspan ou formatação interna podem renderizar mal.
**Solução:** Para tabelas complexas, usar pipe tables do Pandoc Markdown ou grid tables. Ou gerar a tabela direto no Typst.

## 5. Imagens com paths relativos falham se o CWD mudar
**Problema:** `![img](./images/foto.png)` falha se o Pandoc rodar de outro diretório.
**Solução:** Usar `--resource-path=./` no Pandoc ou converter para paths absolutos.

## 6. Encoding UTF-8 em Windows
**Problema:** Caracteres especiais (acentos, emojis) podem corromper em conversões no Windows.
**Solução:** Garantir que todos os arquivos são UTF-8. Adicionar `--metadata encoding=utf-8` no Pandoc. No Typst, UTF-8 é padrão.

## 7. Typst packages (@preview/) requerem internet na primeira compilação
**Problema:** `#import "@preview/package:version"` baixa da internet. Falha offline.
**Solução:** Compilar uma vez online para cachear. Ou copiar packages para diretório local.
