# Variáveis de Ambiente — asc CLI

## Autenticação

| Variável | Descrição | Obrigatória |
|----------|-----------|-------------|
| `ASC_KEY_ID` | ID da API Key do App Store Connect | Sim (se não usar keychain) |
| `ASC_ISSUER_ID` | Issuer ID da organização | Sim (se não usar keychain) |
| `ASC_PRIVATE_KEY_PATH` | Caminho para o arquivo .p8 | Uma das 3 |
| `ASC_PRIVATE_KEY` | Conteúdo raw da chave privada | Uma das 3 |
| `ASC_PRIVATE_KEY_B64` | Chave privada em Base64 (CI/CD) | Uma das 3 |
| `ASC_BYPASS_KEYCHAIN` | `1` = forçar auth via env vars (Windows) | Sim no Windows |
| `ASC_STRICT_AUTH` | `1` = falhar se múltiplas fontes de credenciais | Opcional |

## Defaults

| Variável | Descrição | Default |
|----------|-----------|---------|
| `ASC_APP_ID` | App ID padrão (evita `--app` em cada comando) | — |
| `ASC_VENDOR_NUMBER` | Vendor number para relatórios financeiros | — |
| `ASC_DEFAULT_OUTPUT` | Formato de saída: `json`, `table`, `markdown` | `table` (TTY) / `json` (pipe) |

## Timeouts

| Variável | Descrição | Default |
|----------|-----------|---------|
| `ASC_TIMEOUT` | Timeout de requests em segundos | 30s |
| `ASC_UPLOAD_TIMEOUT` | Timeout de upload em segundos | 300s |

## Debug

| Variável | Descrição |
|----------|-----------|
| `ASC_DEBUG` | Habilitar debug logging. `api` = log HTTP requests/responses |

## Setup Recomendado (Windows)

Adicionar ao `~/.bashrc` ou `~/.bash_profile`:

```bash
# App Store Connect CLI
export ASC_BYPASS_KEYCHAIN=1
export ASC_KEY_ID="YOUR_KEY_ID"
export ASC_ISSUER_ID="YOUR_ISSUER_ID"
export ASC_PRIVATE_KEY_PATH="$HOME/.asc/AuthKey_XXXXXXXX.p8"
export ASC_DEFAULT_OUTPUT=json
# export ASC_APP_ID="YOUR_DEFAULT_APP_ID"  # Descomente após configurar
```

## Setup CI/CD

```bash
# GitHub Actions — usar secrets
export ASC_KEY_ID="${{ secrets.ASC_KEY_ID }}"
export ASC_ISSUER_ID="${{ secrets.ASC_ISSUER_ID }}"
export ASC_PRIVATE_KEY_B64="${{ secrets.ASC_PRIVATE_KEY_B64 }}"
export ASC_BYPASS_KEYCHAIN=1
```
