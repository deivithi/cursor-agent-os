---
name: skill-health
description: >
  Analisa o ecossistema de skills e gera relatório de saúde. Identifica skills sem
  gotchas, sem references, sem progressive disclosure, sem Related Skills e skills
  nunca usadas. Auto-manutenção do ecossistema de skills.
allowed-tools: Bash, Read, Glob, Grep, Agent
---

# 🏥 Skill Health Check — Auto-Manutenção do Ecossistema

Analise o ecossistema completo de skills e gere um relatório de saúde.

## Instruções

Execute as verificações abaixo **nesta ordem** e compile o relatório final.

### 1. Inventário de Skills Customizadas

Listar todas as skills em `.claude/skills/` (excluindo `_templates/`):

```bash
ls -d .claude/skills/*/ | grep -v _templates | sed 's|.claude/skills/||;s|/||'
```

Para cada skill, verificar existência de:
- `SKILL.md` (obrigatório)
- `gotchas.md` (esperado — best practice Thariq)
- `references/` (esperado — progressive disclosure)
- `scripts/` (desejável — automação)

### 2. Verificar Progressive Disclosure

Para cada skill, verificar se SKILL.md contém seção `## 📁 File Structure`:

```bash
grep -l "File Structure" .claude/skills/*/SKILL.md
```

Skills SEM header = **gap de progressive disclosure**.

### 3. Verificar Composição (Related Skills)

Para cada skill, verificar se SKILL.md contém seção `## 🔗 Related Skills`:

```bash
grep -l "Related Skills" .claude/skills/*/SKILL.md
```

Skills SEM Related Skills = **skills isoladas** (potencial de composição perdido).

### 4. Verificar Uso (se skill-usage-log.jsonl existir)

Se `.claude/data/skill-usage-log.jsonl` existir, analisar:

```bash
# Skills mais usadas
cat .claude/data/skill-usage-log.jsonl | jq -r '.skill' | sort | uniq -c | sort -rn

# Skills nunca usadas (comparar com inventário)
```

Skills nunca usadas = **candidatas a revisão ou remoção**.

### 5. Verificar Trigger Evals (Quality Check — Together AI Pattern)

Para cada skill, verificar se existe `quality/trigger-evals/routing.json`:

```bash
ls .claude/skills/*/quality/trigger-evals/routing.json 2>/dev/null
```

Para cada arquivo encontrado, validar estrutura:

```bash
node -e "
const fs=require('fs'),path=require('path'),glob=require('child_process').execSync('ls .claude/skills/*/quality/trigger-evals/routing.json 2>/dev/null',{encoding:'utf8'}).trim().split('\n').filter(Boolean);
glob.forEach(f=>{const d=JSON.parse(fs.readFileSync(f,'utf8'));const pos=d.filter(x=>x.should_trigger).length;const neg=d.filter(x=>!x.should_trigger).length;const ok=pos>=3&&neg>=3;console.log((ok?'✅':'❌')+' '+path.basename(path.resolve(f,'../../..'))+': '+d.length+' cases ('+pos+'+/'+neg+'-)'+(ok?'':' — NEED 3+/3-'))})
"
```

Skills SEM trigger-evals = **sem contrato de qualidade de routing**.
Skills com < 3 positivos ou < 3 negativos = **trigger-evals incompleto**.

### 6. Verificar Handoff Points

Para cada skill, verificar se SKILL.md contém seção `## Handoff Points`:

```bash
grep -l "Handoff Points" .claude/skills/*/SKILL.md
```

Skills SEM Handoff Points = **skills desconectadas do grafo de routing**.

### 7. Verificar Limites de SKILL.md

Para cada skill, verificar tamanho do SKILL.md (recomendado < 500 linhas):

```bash
wc -l .claude/skills/*/SKILL.md | sort -rn | head -20
```

Skills com > 500 linhas = **candidatas a extrair conteúdo para references/**.

### 8. Verificar Frontmatter Completo

Para cada skill, verificar campos obrigatórios no frontmatter (`name`, `description`):

```bash
for f in .claude/skills/*/SKILL.md; do
  skill=$(basename $(dirname "$f"))
  has_name=$(head -20 "$f" | grep -c "^name:")
  has_desc=$(head -20 "$f" | grep -c "^description:")
  if [ "$has_name" -eq 0 ] || [ "$has_desc" -eq 0 ]; then
    echo "❌ $skill — missing: $([ $has_name -eq 0 ] && echo 'name ')$([ $has_desc -eq 0 ] && echo 'description')"
  fi
done
```

### 9. Verificar Cyber Skills Customizadas

Verificar as 5 skills customizadas em `.claude/cybersecurity-skills/skills/`:
- `implementing-lgpd-data-protection-compliance`
- `hardening-salesforce-platform-security`
- `implementing-secure-coding-practices-owasp`
- `designing-secure-api-architecture`
- `implementing-sbom-management-cyclonedx`

Cada uma deve ter: `SKILL.md` + `gotchas.md` + `references/`.

### 10. Verificar Hooks

Verificar que `settings.local.json` contém:
- `SessionStart` hook ✅
- `PreToolUse` hook (skill usage tracker) ✅
- `PostToolUse` hook (file tracker) ✅
- `Stop` hook (session tracker) ✅

### 11. Verificar config.json e CLAUDE_PLUGIN_DATA

- `.claude/config.json` existe?
- `.claude/data/` existe com subpastas?

---

## Formato do Relatório

```markdown
# 🏥 Skill Health Report — DD/MM/YYYY HH:MM BRT

## Resumo
- **Total de skills customizadas:** X
- **Score de saúde:** X/100

## Conformidade Anthropic (Thariq) + Together AI Patterns
| # | Critério | Status | Detalhe |
|---|---------|--------|---------|
| 1 | Gotchas em todas as skills | ✅/❌ | X/Y skills |
| 2 | Progressive disclosure | ✅/❌ | X/Y skills |
| 3 | Related Skills (composição) | ✅/❌ | X/Y skills |
| 4 | Scripts executáveis | ✅/❌ | X/Y skills |
| 5 | **Trigger Evals (routing quality)** | ✅/❌ | X/Y skills com routing.json |
| 6 | **Handoff Points (grafo de routing)** | ✅/❌ | X/Y skills |
| 7 | **SKILL.md < 500 linhas** | ✅/❌ | X skills acima do limite |
| 8 | **Frontmatter completo (name+desc)** | ✅/❌ | X/Y skills |
| 9 | PreToolUse hook (medição) | ✅/❌ | |
| 10 | config.json global | ✅/❌ | |
| 11 | CLAUDE_PLUGIN_DATA | ✅/❌ | |
| 12 | On-demand hooks | ✅/❌ | /careful, /freeze |
| 13 | 9/9 tipos de skill | ✅/❌ | X/9 tipos |

## 9 Tipos de Skills (Thariq)
| # | Tipo | Skill | Status |
|---|------|-------|--------|
| 1 | Library & API Reference | api-forge | ✅ |
| 2 | Product Verification | product-verification | ✅ |
| 3 | Data Fetching & Analysis | (via /science) | ✅ |
| 4 | Business Process | lead-audit, commission-audit | ✅ |
| 5 | Code Scaffolding | scaffolding | ✅ |
| 6 | Code Quality & Review | code-review | ✅ |
| 7 | CI/CD & Deployment | cicd | ✅ |
| 8 | Runbooks | runbook | ✅ |
| 9 | Infrastructure Ops | (via /cicd + /careful) | ✅ |

## Skills com Gaps
| Skill | Gotchas | References | Disclosure | Related |
|-------|---------|-----------|-----------|---------|
| ... | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |

## Uso de Skills (Últimos 30 dias)
(dados de skill-usage-log.jsonl se disponível)

## Ações Recomendadas
1. ...
2. ...
```
