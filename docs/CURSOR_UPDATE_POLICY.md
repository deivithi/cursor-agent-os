# Politica de Atualizacao do Cursor no Windows

## Decisao

O Cursor deve ser mantido como uma unica instalacao User em:

`C:\Users\deivithi.lopes\AppData\Local\Programs\cursor`

O canal oficial de atualizacao e o updater nativo do Cursor. O script local:

`scripts\Atualizar-Cursor-Seguro.ps1`

serve para auditoria, preflight e reparo do canal User. Ele nao promove staging manualmente, nao edita arquivos internos e nao reinstala plugins, MCPs, hooks ou skills.

## O que nao fazer

- Nao manter instalacao System em `C:\Program Files\cursor`.
- Nao manter dois Cursors instalados ao mesmo tempo.
- Nao usar `winget` como rotina principal de update do Cursor.
- Nao editar `product.json` ou mover conteudo de `_` para concluir update.
- Nao usar watchdog/guard para interferir no updater nativo.
- Nao clicar em retry repetidamente quando houver erro; executar o preflight e reparar a causa.

## Procedimento padrao

1. Fechar o Cursor.
2. Auditar o ambiente:

```powershell
& "C:\Users\deivithi.lopes\Documents\Cursor\scripts\Atualizar-Cursor-Seguro.ps1" -ValidateOnly
```

3. Se aprovado, abrir o Cursor e usar o update nativo do app.
4. Depois do update, rodar a auditoria novamente.

## Reparo controlado

Quando houver duplicidade, staging pendente, PATH incorreto ou processo preso:

```powershell
& "C:\Users\deivithi.lopes\Documents\Cursor\scripts\Atualizar-Cursor-Seguro.ps1" -RepairUserInstall
```

O reparo fecha processos do Cursor, valida a instalacao User e corrige o PATH de usuario. Se ainda existir instalacao System ou resquicio em `C:\Program Files\cursor`, remover com backup e permissao elevada antes de tentar novo update.

## Criterios de aceite

- Registro do Windows tem exatamente uma entrada: `Cursor (User)`.
- `C:\Program Files\cursor` nao existe.
- `where cursor` aponta apenas para `AppData\Local\Programs\cursor\resources\app\bin`.
- `cursor --version`, `product.json` e registro mostram a mesma versao.
- Nao existe staging pendente em `AppData\Local\Programs\cursor\_`.
- Logs do Composer continuam sem rajada de MCPs de plugin.

## Seguranca / TI

Se o instalador oficial travar ou for bloqueado, tratar como politica de seguranca ou allowlist. Nao contornar com promocao manual de pasta. Validar permissao para:

- `C:\Users\deivithi.lopes\AppData\Local\Programs\cursor\`
- instaladores oficiais baixados de `downloads.cursor.com`
- updater/installer Inno do Cursor
- executaveis assinados pela Anysphere
