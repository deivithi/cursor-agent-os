# Fork — Ramificar Sessão para Exploração Alternativa

Criando fork a partir da sessão: **$ARGUMENTS**

## Protocolo

1. **Identificar ponto de fork:**
   - Se argumento é timestamp: usar snapshot específico
   - Se sem argumento: usar snapshot mais recente
   - Se argumento é descrição: usar como nome do branch

2. **Criar branch isolado:**
```bash
# Gerar nome do branch
TOPIC=$(echo "$ARGUMENTS" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | head -c 30)
BRANCH_NAME="fork/$(date +%Y%m%d)-${TOPIC:-exploration}"

# Criar e mudar para o branch
git checkout -b "$BRANCH_NAME"
```

3. **Carregar contexto do snapshot** (mesmo protocolo do `/resume`)

4. **Informar ao usuário:**
```
Fork criado: {branch_name}
Base: {commit_hash} ({branch_original})
Snapshot: {timestamp}

Você está agora em um branch isolado. Mudanças aqui não afetam o branch original.
Para voltar: git checkout {branch_original}
Para mesclar: git merge {branch_name}
```

## Quando Usar

- Testar abordagem alternativa sem perder trabalho atual
- Explorar refatoração arriscada em isolamento
- Criar variante de feature para comparação
- "E se eu fizesse diferente?" — fork e testa

## Integração

- Ativado por `/fork [descrição]`
- Complementa `/resume` (resume carrega contexto, fork cria branch)
- O `/go` roteia automaticamente quando detecta intenção de fork/branch
