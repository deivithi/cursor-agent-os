# Referência de Conectores Composio

Guia dos conectores mais utilizados no ecossistema e suas ações principais.

---

## 1. GitHub Conector (`github`)

- **Ações Frequentes:**
  - `GITHUB_CREATE_ISSUE`: Cria issue com título, corpo e labels.
  - `GITHUB_GET_PULL_REQUEST`: Obtém detalhes e diff de PR.
  - `GITHUB_LIST_REPOSITORIES`: Lista repositórios acessíveis pela conta conectada.
- **Exemplo de Payload (`create_issue`):**
  ```json
  {
    "owner": "deivithi",
    "repo": "cursor-agent-os",
    "title": "feat: nova automação Gauntlet",
    "body": "Descrição estruturada da issue..."
  }
  ```

---

## 2. Slack Conector (`slack`)

- **Ações Frequentes:**
  - `SLACK_SEND_MESSAGE`: Envia mensagem formatada em Markdown/Blocks para um canal ou usuário.
  - `SLACK_ADD_REACTION`: Reage a uma mensagem com emoji.
- **Exemplo de Payload (`send_message`):**
  ```json
  {
    "channel": "C01234567",
    "text": "🚀 Deploy do DRE Eventos concluído com sucesso no Zo Computer."
  }
  ```

---

## 3. Salesforce Conector (`salesforce`)

- **Ações Frequentes:**
  - `SALESFORCE_CREATE_RECORD`: Cria Lead, Contact, Opportunity ou Custom Object.
  - `SALESFORCE_EXECUTE_SOQL`: Executa query SOQL de leitura.
  - `SALESFORCE_UPDATE_RECORD`: Atualiza campos de um registro específico por ID.
- **Exemplo de Payload (`execute_soql`):**
  ```json
  {
    "query": "SELECT Id, Name, Email, Status FROM Lead WHERE Status = 'Novo' LIMIT 10"
  }
  ```

---

## 4. Google Calendar (`googlecalendar`)

- **Ações Frequentes:**
  - `GOOGLECALENDAR_CREATE_EVENT`: Cria evento na agenda com data/hora de início/fim e participantes.
  - `GOOGLECALENDAR_LIST_EVENTS`: Lista compromissos do dia.
