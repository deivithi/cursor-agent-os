# 🌐 Agent-Browser Patterns

> Referência rápida de patterns de uso do agent-browser para verificação de produtos.

## Comandos Essenciais

```bash
# Navegação
agent-browser open "<url>"                    # Abrir URL
agent-browser open "<url>" --session nome     # Sessão nomeada (mantém estado)

# Observação
agent-browser snapshot                        # Snapshot completo do DOM
agent-browser snapshot -i                     # Só elementos interativos (economiza tokens)

# Interação (sempre por ref, não por selector)
agent-browser click @e1                       # Clicar por referência
agent-browser type @e2 "texto"                # Digitar em campo
agent-browser select @e3 "opção"              # Selecionar dropdown
agent-browser scroll down 500                 # Scroll (pixels)

# Evidência
agent-browser screenshot ./path/file.png      # Capturar screenshot
agent-browser pdf ./path/file.pdf             # Capturar como PDF

# Sessão
agent-browser close                           # Fechar sessão ativa
```

## Regras de Ouro

1. **SEMPRE snapshot antes de interagir** — Refs só existem após snapshot
2. **SEMPRE re-snapshot após ação** — DOM mudou, refs invalidados
3. **Use `-i` flag** — Snapshot compacto, só interativos, menos tokens
4. **Use `--session`** — Para fluxos multi-step que precisam manter estado
5. **Nunca senhas em plain text** — Use `agent-browser auth save`
6. **Fechar ao terminar** — `agent-browser close`

## Pattern: Fluxo de Login

```bash
agent-browser open "https://app.example.com/login" --session teste
sleep 2
agent-browser snapshot -i           # Capturar form
agent-browser type @e1 "user@test"  # Email
agent-browser type @e2 "password"   # Senha
agent-browser click @e3             # Botão login
sleep 2
agent-browser snapshot -i           # Verificar dashboard
agent-browser screenshot ./login-ok.png
agent-browser close
```

## Pattern: Verificar Elemento Existe

```bash
# Capturar snapshot e buscar por texto
SNAP=$(agent-browser snapshot 2>/dev/null)
if echo "$SNAP" | grep -q "Dashboard"; then
    echo "✅ Dashboard carregado"
else
    echo "❌ Dashboard não encontrado"
fi
```

## Gotchas Específicos

- **SPA delay:** Esperar 2-3s após navegação para React/Next renderizar
- **Modals:** Podem bloquear elementos — fechar antes de interagir com background
- **Iframes:** agent-browser pode não acessar conteúdo dentro de iframes
- **Auth cookies:** Usar `--session` para manter sessão autenticada entre comandos
