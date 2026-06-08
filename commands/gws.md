# GWS — Google Workspace CLI

Operação solicitada: **$ARGUMENTS**

## Ferramenta

`gws` v0.16.0 — CLI Rust nativo para Google Workspace (Drive, Sheets, Gmail, Calendar, Docs, Slides, Tasks, Chat, Meet, Forms, Keep, Admin, People).

## Serviços Disponíveis

| Serviço | Exemplos de Uso |
|---------|-----------------|
| **drive** | Upload, download, compartilhar, organizar arquivos |
| **sheets** | Ler/escrever planilhas, ranges, fórmulas |
| **gmail** | Enviar, ler, buscar emails, labels |
| **calendar** | Eventos, agenda, disponibilidade |
| **docs** | Criar, editar, exportar documentos |
| **slides** | Criar, editar apresentações |
| **tasks** | Listas de tarefas, gerenciamento |
| **chat** | Mensagens, spaces |
| **meet** | Criar reuniões |
| **forms** | Criar formulários, ler respostas |
| **keep** | Notas e listas |
| **people** | Contatos |
| **admin-reports** | Audit logs, relatórios de uso |

## Sintaxe

```bash
gws <serviço> <recurso> <método> --params '<JSON>'
```

## Exemplos Práticos

### Drive
```bash
gws drive files list --params '{"pageSize": 10}' --format table
gws drive files get --params '{"fileId": "abc123"}'
gws drive files create --json '{"name": "relatorio.txt", "mimeType": "text/plain"}'
```

### Sheets
```bash
gws sheets spreadsheets get --params '{"spreadsheetId": "ID_AQUI"}'
gws sheets spreadsheets.values get --params '{"spreadsheetId": "ID", "range": "Sheet1!A1:Z100"}' --format csv
gws sheets spreadsheets.values update --params '{"spreadsheetId": "ID", "range": "A1"}' --json '{"values": [["Novo", "Dado"]]}'
```

### Gmail
```bash
gws gmail users messages list --params '{"userId": "me", "q": "from:cliente@email.com"}' --format table
gws gmail users messages get --params '{"userId": "me", "id": "MSG_ID"}'
```

### Calendar
```bash
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-03-15T00:00:00Z"}' --format table
gws calendar events insert --params '{"calendarId": "primary"}' --json '{"summary": "Reunião", "start": {"dateTime": "2026-03-16T10:00:00-03:00"}, "end": {"dateTime": "2026-03-16T11:00:00-03:00"}}'
```

### Tasks
```bash
gws tasks tasklists list --format table
gws tasks tasks list --params '{"tasklist": "LISTA_ID"}' --format table
```

## Flags Importantes

| Flag | Função |
|------|--------|
| `--format table` | Saída em tabela legível |
| `--format csv` | Saída CSV (para planilhas) |
| `--format json` | JSON estruturado (padrão) |
| `--page-all` | Auto-paginação (todos os resultados) |
| `--page-limit N` | Limitar páginas |
| `--output arquivo.pdf` | Salvar resposta binária em arquivo |
| `--upload ./arquivo` | Upload de arquivo |

## Cenários Febracis

| Cenário | Comando |
|---------|---------|
| Listar leads em planilha | `gws sheets spreadsheets.values get --params '{"spreadsheetId":"ID","range":"Leads!A:Z"}' --format table` |
| Exportar relatório de comissões | `gws sheets spreadsheets.values get ... --format csv > comissoes.csv` |
| Buscar emails de cliente | `gws gmail users.messages list --params '{"userId":"me","q":"subject:CIS"}' --format table` |
| Criar evento de alinhamento | `gws calendar events insert ...` |
| Backup de docs importantes | `gws drive files list --params '{"q":"mimeType=\"application/vnd.google-apps.document\""}' --page-all` |

## Schema Discovery

Para descobrir os parâmetros de qualquer endpoint:
```bash
gws schema drive.files.list
gws schema sheets.spreadsheets.values.get
gws schema gmail.users.messages.list
```

## Segurança

- Auth via OAuth 2.0 (credenciais encriptadas no OS Keyring)
- Model Armor para sanitização de input (anti prompt injection)
- Nenhum dado sensível exposto no contexto
