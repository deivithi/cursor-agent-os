# Skill Install — Instalar Skills da Comunidade

Instalando: **$ARGUMENTS**

## Protocolo

### 1. Parsear Fonte
Aceita:
- URL GitHub: `https://github.com/user/repo` (clona inteiro)
- URL de diretório: `https://github.com/user/repo/tree/main/skills/nome`
- URL Gist: `https://gist.github.com/user/id`
- Nome local: path relativo a um diretório com SKILL.md

### 2. Baixar e Validar

```bash
# Clonar em temp
TEMP=$(mktemp -d)
git clone --depth 1 "$URL" "$TEMP" 2>/dev/null

# Validar estrutura
if [ ! -f "$TEMP/SKILL.md" ]; then
    echo "ERROR: SKILL.md não encontrado. Skill inválida."
    exit 1
fi

# Extrair nome da skill
SKILL_NAME=$(grep -m1 '^name:' "$TEMP/SKILL.md" | sed 's/name: *//')
```

### 3. Instalar

```bash
# Copiar para skills dir
cp -r "$TEMP" ".claude/skills/$SKILL_NAME/"
rm -rf "$TEMP"
```

### 4. Verificar
Executar `/skill-health` na skill instalada para garantir que segue os padrões.

### 5. Reportar
```
Skill "$SKILL_NAME" instalada em .claude/skills/$SKILL_NAME/
Arquivos: SKILL.md, [gotchas.md], [references/], [scripts/]
Status: OK
```
