# 🔨 UI Forge — Geração de UI Orquestrada

Tarefa solicitada: **$ARGUMENTS**

## Instruções

Ativar skill `ui-forge` (`.claude/skills/ui-forge/SKILL.md`) e executar o workflow completo:

1. **DETECT** — Ler `package.json`, `tailwind.config.*`, `components.json` (shadcn) do diretório atual para detectar framework, styling e component library. Se nenhum projeto → modo HTML standalone.

2. **MODE** — Classificar a intenção do usuário:
   - Sem URL → **Prompt mode** (gerar do zero)
   - URL + "clonar/copiar/replicar" → **Clone mode**
   - URL + "melhorar/modernizar" → **Enhance mode**
   - URL + "inspirar/estilo de/como o" → **Inspire mode**

3. **REFERENCE** (se URL fornecida) — Usar `browser-use` para capturar screenshot + extrair dados visuais da URL de referência.

4. **DESIGN** — Aplicar princípios da skill `frontend-design`:
   - Anti-AI-slop (zero gradientes genéricos, zero cards uniformes)
   - Paleta derivada do conteúdo/marca
   - Tipografia com personalidade (combo serif + sans-serif)
   - MagicUI components quando relevante (150+ disponíveis)
   - Motion Primitives (scroll reveal, stagger, hover lift)
   - Responsive mobile-first

5. **OUTPUT** — Salvar resultado:
   - Projeto React/Next.js → `src/components/<Name>.tsx`
   - HTML standalone → `output/<descritivo>.html`

6. **VERIFY** — Abrir no browser/dev server, mostrar preview ao usuário. Se feedback → refinar.
