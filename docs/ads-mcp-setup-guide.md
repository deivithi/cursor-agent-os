# Guia de Setup — Google Ads + Meta Ads MCP

> Infraestrutura já instalada. Este guia cobre apenas a criação de credenciais.
> Custo: **R$ 0** — ambas APIs são gratuitas para uso próprio.

---

## Parte 1: Google Ads MCP

### 1.1 Criar Projeto no Google Cloud

1. Acesse https://console.cloud.google.com/
2. Clique em **Select a project** → **New Project**
3. Nome sugerido: `claude-ads-mcp`
4. Clique **Create**

### 1.2 Ativar a Google Ads API

1. No projeto criado, vá para **APIs & Services** → **Library**
2. Busque `Google Ads API`
3. Clique **Enable**

### 1.3 Criar Credenciais OAuth2

1. Vá para **APIs & Services** → **Credentials**
2. Clique **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Se pedido, configure a **OAuth consent screen**:
   - User Type: **External** (ou Internal se Google Workspace)
   - App name: `Claude Ads MCP`
   - Scopes: adicione `https://www.googleapis.com/auth/adwords`
   - Test users: adicione seu email
4. Tipo de aplicação: **Desktop app**
5. Nome: `Claude Ads MCP`
6. Clique **Create**
7. **Anote** o `Client ID` e `Client Secret`

### 1.4 Obter Developer Token

1. Acesse https://ads.google.com/
2. Vá para **Tools & Settings** → **API Center** (ou **Setup** → **API Center**)
3. Se não aparecer: sua conta precisa ser MCC (Manager Account)
   - Crie uma MCC gratuita em https://ads.google.com/home/tools/manager-accounts/
4. Copie o **Developer Token** (começa com uma string alfanumérica)
5. O token começa em status **Test** (suficiente para leitura da própria conta)

### 1.5 Gerar Refresh Token

Execute no terminal (já temos o venv pronto):

```bash
~/.google-ads-mcp-env/Scripts/python.exe -c "
from google_ads.client import GoogleAdsClient
import google.auth.transport.requests
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/adwords']
CLIENT_ID = 'SEU_CLIENT_ID_AQUI'
CLIENT_SECRET = 'SEU_CLIENT_SECRET_AQUI'

flow = InstalledAppFlow.from_client_config(
    {'installed': {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
        'token_uri': 'https://oauth2.googleapis.com/token',
    }},
    scopes=SCOPES
)
flow.run_local_server(port=8080)
print(f'Refresh Token: {flow.credentials.refresh_token}')
"
```

Isso abre o navegador para autenticar. Após login, o refresh token é impresso no terminal.

### 1.6 Preencher google-ads.yaml

Edite o arquivo `C:\Users\PC\google-ads.yaml`:

```yaml
client_id: "123456789-xxxxx.apps.googleusercontent.com"
client_secret: "GOCSPX-xxxxxxxxxxxxx"
refresh_token: "1//0xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
developer_token: "ABcDeFgHiJkLmNoPqR"
login_customer_id: "1234567890"  # sem hífens, só números
```

O `login_customer_id` é o número da sua conta Google Ads (visível no canto superior direito do Google Ads UI).

### 1.7 Testar

Reinicie o Claude Code e digite:
```
Liste minhas campanhas do Google Ads
```

Se der erro de credenciais, verifique:
- O arquivo `google-ads.yaml` está em `C:\Users\PC\`
- O `developer_token` está correto
- O `login_customer_id` não tem hífens

---

## Parte 2: Meta Ads MCP

### 2.1 Criar Meta Developer App

1. Acesse https://developers.facebook.com/
2. Clique **My Apps** → **Create App**
3. Tipo: **Business** (ou **Other** → **Consumer**)
4. Nome: `Claude Ads MCP`
5. Clique **Create App**

### 2.2 Adicionar Produto Marketing API

1. Na dashboard do app, clique **Add Products**
2. Encontre **Marketing API** e clique **Set Up**
3. Isso ativa o acesso à API de anúncios

### 2.3 Gerar Access Token

**Método rápido (Graph API Explorer):**

1. Acesse https://developers.facebook.com/tools/explorer/
2. Selecione seu App no dropdown
3. Clique **Generate Access Token**
4. Marque as permissões:
   - `ads_read` (leitura de campanhas e métricas)
   - `ads_management` (gerenciamento — opcional)
   - `pages_read_engagement` (opcional, para page posts)
5. Clique **Generate Access Token**
6. Autentique com sua conta Facebook
7. **Copie** o token gerado

### 2.4 Converter para Long-Lived Token (60 dias)

O token do Explorer dura ~1 hora. Converta para 60 dias:

```bash
curl "https://graph.facebook.com/v21.0/oauth/access_token?grant_type=fb_exchange_token&client_id=SEU_APP_ID&client_secret=SEU_APP_SECRET&fb_exchange_token=SEU_SHORT_TOKEN"
```

Substitua:
- `SEU_APP_ID`: ID do app (visível na dashboard do app)
- `SEU_APP_SECRET`: App Secret (Settings → Basic)
- `SEU_SHORT_TOKEN`: token gerado no passo anterior

A resposta JSON contém o `access_token` de longa duração.

### 2.5 Configurar no MCP

Edite o arquivo `.mcp.json` na raiz do projeto e substitua o placeholder:

```json
"meta-ads": {
  "command": "C:\\Users\\PC\\.meta-ads-mcp-env\\Scripts\\python.exe",
  "args": [
    "C:\\Users\\PC\\.claude\\repos\\facebook-ads-mcp-server\\server.py",
    "--fb-token",
    "SEU_LONG_LIVED_TOKEN_AQUI"
  ]
}
```

### 2.6 Testar

Reinicie o Claude Code e digite:
```
Quais são minhas contas de anúncio no Meta?
```

Se der erro 401:
- Token expirou (gere um novo long-lived token)
- Permissões insuficientes (verifique `ads_read`)
- App não tem acesso Marketing API

### 2.7 Renovação do Token

O long-lived token expira em 60 dias. Para renovar:
1. Repita os passos 2.3 e 2.4
2. Atualize o token no `.mcp.json`
3. Reinicie o Claude Code

> Dica: Coloque um lembrete no calendário para renovar a cada 50 dias.

---

## Parte 3: Verificação Cruzada

Após configurar ambos, teste o dashboard unificado:

```
/ads-live dashboard
```

Ou peça diretamente:
```
Como estão minhas campanhas? Me dê um resumo de Google Ads e Meta Ads.
```

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Google: `FileNotFoundError: google-ads.yaml` | Verificar que o arquivo está em `C:\Users\PC\google-ads.yaml` |
| Google: `AuthenticationError` | Refresh token expirado ou client_id/secret errados |
| Google: `PERMISSION_DENIED` | Developer token em modo test — só acessa a própria conta |
| Meta: `Error 401` | Token expirado — renovar via Graph API Explorer |
| Meta: `Error 190` | Token inválido ou permissões insuficientes |
| MCP não conecta | Reiniciar Claude Code após editar `.mcp.json` |
| Python não encontrado | Verificar que os venvs existem: `~/.google-ads-mcp-env/` e `~/.meta-ads-mcp-env/` |
