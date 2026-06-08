# Guia de Autenticação — App Store Connect CLI

## Pré-requisitos

- Conta Apple Developer ativa ($99/ano)
- Acesso Admin ou Account Holder ao App Store Connect

## Passo 1 — Gerar API Key

1. Acessar [App Store Connect](https://appstoreconnect.apple.com/)
2. Ir para **Users and Access** → **Integrations** → **App Store Connect API**
3. Clicar em **Generate API Key**
4. Nome: `asc-cli` (ou nome descritivo)
5. Role: **Admin** (necessário para operações de escrita)
6. Anotar:
   - **Key ID** (10 caracteres, ex: `ABC1234DEF`)
   - **Issuer ID** (UUID, ex: `12345678-1234-1234-1234-123456789abc`)
7. Baixar o arquivo `.p8` (só pode ser baixado UMA vez)

## Passo 2 — Armazenar a Chave

```bash
# Criar diretório seguro
mkdir -p ~/.asc
chmod 700 ~/.asc

# Mover a chave
mv ~/Downloads/AuthKey_ABC1234DEF.p8 ~/.asc/
chmod 600 ~/.asc/AuthKey_ABC1234DEF.p8
```

## Passo 3 — Configurar Auth

### macOS (com Keychain)

```bash
asc auth login \
  --key-id ABC1234DEF \
  --issuer-id 12345678-1234-1234-1234-123456789abc \
  --private-key-path ~/.asc/AuthKey_ABC1234DEF.p8
```

### Windows (sem Keychain)

```bash
# Adicionar ao ~/.bashrc
export ASC_BYPASS_KEYCHAIN=1
export ASC_KEY_ID="ABC1234DEF"
export ASC_ISSUER_ID="12345678-1234-1234-1234-123456789abc"
export ASC_PRIVATE_KEY_PATH="$HOME/.asc/AuthKey_ABC1234DEF.p8"

# Recarregar
source ~/.bashrc
```

### CI/CD (Base64)

```bash
# Encodar a chave
base64 -w0 ~/.asc/AuthKey_ABC1234DEF.p8 > /dev/clipboard
# Salvar como secret no CI (ex: ASC_PRIVATE_KEY_B64)

# No CI
export ASC_BYPASS_KEYCHAIN=1
export ASC_PRIVATE_KEY_B64="$ASC_PRIVATE_KEY_B64_SECRET"
```

## Passo 4 — Validar

```bash
# Status da auth
asc auth status --validate

# Diagnóstico
asc auth doctor

# Teste funcional (read-only)
asc apps list --output table
```

## Passo 5 — Verificar Permissões

```bash
# Experimental: listar capabilities da key
asc web auth capabilities
```

## Troubleshooting

| Problema | Causa | Fix |
|----------|-------|-----|
| `401 Unauthorized` | Key ID ou Issuer ID incorretos | Verificar valores no App Store Connect |
| `403 Forbidden` | Role insuficiente | Recriar key com role Admin |
| `keychain not available` | Windows sem Keychain | `ASC_BYPASS_KEYCHAIN=1` |
| `multiple auth sources` | Conflito keychain + env vars | `ASC_STRICT_AUTH=1` |
| `token expired` | Clock do sistema dessincronizado | Sincronizar relógio do sistema |
| `private key not found` | Path incorreto ou permissão | Verificar path e `chmod 600` |
