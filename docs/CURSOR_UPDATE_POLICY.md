# Politica de Atualizacao do Cursor no Windows

## Decisao

O Cursor deve ser mantido como uma unica instalacao User em:

`C:\Users\deivithi.lopes\AppData\Local\Programs\cursor`

O canal oficial de atualizacao e o updater nativo do Cursor. Como MCPs stdio
podem deixar o `node.exe` embutido vivo depois que o app fecha, o updater e
protegido por uma unica tarefa persistente e invisivel:

`Febracis-Cursor-UpdateWatchdog`

Ela executa `scripts\cursor-update-watchdog.ps1` a cada 2 segundos enquanto o
usuario esta logado. O watchdog age somente quando o `Cursor.exe` principal nao
esta aberto: encerra apenas `resources\app\resources\helpers\node.exe` orfao e,
se um update abortou, conclui o swap somente quando o staging possui assinatura
Authenticode valida da Anysphere e nenhum updater esta rodando.

O script local:

`scripts\Atualizar-Cursor-Seguro.ps1`

serve para auditoria, preflight e reparo do canal User. Ele tambem valida e
reinstala a tarefa preventiva durante `-RepairUserInstall`. Ele nao edita
`product.json` e nao reinstala plugins, MCPs, hooks ou skills.

## O que nao fazer

- Nao manter instalacao System em `C:\Program Files\cursor`.
- Nao manter dois Cursors instalados ao mesmo tempo.
- Nao usar `winget` como rotina principal de update do Cursor.
- Nao editar `product.json`.
- Nao criar guards paralelos, tarefas horarias ou scripts que matem todo
  processo do Cursor indiscriminadamente.
- Nao promover staging sem validar assinatura da Anysphere e ausencia do updater.
- Nao clicar em retry repetidamente quando houver erro; executar o preflight e reparar a causa.

## Procedimento padrao

1. Fechar o Cursor.
2. Auditar o ambiente:

```powershell
& "C:\Users\deivithi.lopes\Documents\Cursor\scripts\Atualizar-Cursor-Seguro.ps1" -ValidateOnly
```

3. Se aprovado, abrir o Cursor e usar o update nativo do app.
4. Depois do update, rodar a auditoria novamente.

Para instalar ou reconstruir apenas a protecao automatica:

```powershell
& "C:\Users\deivithi.lopes\Documents\Cursor\scripts\install-cursor-update-watchdog.ps1"
```

## Reparo controlado

Quando houver duplicidade, staging pendente, PATH incorreto ou processo preso:

```powershell
& "C:\Users\deivithi.lopes\Documents\Cursor\scripts\Atualizar-Cursor-Seguro.ps1" -RepairUserInstall
```

O reparo fecha processos do Cursor, valida a instalacao User, corrige o PATH de
usuario e reinstala o watchdog. Se ainda existir instalacao System ou resquicio
em `C:\Program Files\cursor`, remover com backup e permissao elevada antes de
tentar novo update.

## Criterios de aceite

- Registro do Windows tem exatamente uma entrada: `Cursor (User)`.
- `C:\Program Files\cursor` nao existe.
- `where cursor` aponta apenas para `AppData\Local\Programs\cursor\resources\app\bin`.
- `cursor --version`, `product.json` e registro mostram a mesma versao.
- Nao existe staging pendente em `AppData\Local\Programs\cursor\_`.
- `Febracis-Cursor-UpdateWatchdog` esta `Running` com exatamente um processo.
- Um helper `node.exe` orfao sintetico e encerrado automaticamente.
- Abrir o Cursor normalmente nao e interrompido pelo watchdog.

## Seguranca / TI

Se o instalador oficial travar ou for bloqueado, tratar como politica de seguranca ou allowlist. Nao contornar com promocao manual de pasta. Validar permissao para:

- `C:\Users\deivithi.lopes\AppData\Local\Programs\cursor\`
- instaladores oficiais baixados de `downloads.cursor.com`
- updater/installer Inno do Cursor
- executaveis assinados pela Anysphere
