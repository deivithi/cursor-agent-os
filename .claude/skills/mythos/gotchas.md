# Mythos — Gotchas

## 1. Scope Explosion

**Problema:** Mythos deep hunting pode consumir horas analisando codigo irrelevante.
**Solucao:** Definir escopo e time budget ANTES de iniciar. L1=10min, L2=40min, L3=3h max. Se o budget acabou, parar e reportar o que foi encontrado.

## 2. False Confidence in Chains

**Problema:** Exploit chains teoricas que assumem condicoes que podem nao existir em producao (ex: "se ASLR estiver desabilitado E o atacante tiver acesso local E...").
**Solucao:** SEMPRE classificar confianca da chain: HIGH (todos os bugs confirmados), MEDIUM (alguns teoricos), LOW (maioria teorica). Chains LOW nao devem ser reportadas como Critical.

## 3. Severity Inflation

**Problema:** Analise profunda faz tudo parecer critico. Um info leak menor vira "potencial data breach" se voce especular longe o suficiente.
**Solucao:** Aplicar CVSS rigorosamente. Perguntar: "Um atacante com capacidades REALISTAS consegue explorar isso no contexto REAL de deployment?" Se precisa de 5 condicoes improvavels = LOW, nao CRITICAL.

## 4. Pular Fase 1 (Context Building)

**Problema:** Tentacao de ir direto para vulnerability hunting sem entender a arquitetura. Resultado: tempo desperdicado em arquivos priority-1 ou findings que sao false positives por falta de contexto.
**Solucao:** SEMPRE executar Fase 1 (Attack Surface Mapping) e Fase 2 (File Prioritization) antes de hunting. E mais rapido no total.

## 5. Offensive Drift

**Problema:** A linha entre "descrever o impacto de uma vulnerabilidade" e "fornecer um exploit funcional" e tenue. Mythos e 100% DEFENSIVO.
**Solucao:** PoC descreve O QUE aconteceria e o IMPACTO, nunca fornece codigo weaponizado. Foco na REMEDIACAO. Se o finding precisa de PoC detalhado, isso e trabalho de um pentest contratado com escopo formal.

## 6. Overhead de Subagentes (L3)

**Problema:** 4 subagentes paralelos em L3 Siege geram muitos findings, incluindo duplicatas e false positives. Sem deduplicacao, o report fica poluido e ilegivel.
**Solucao:** O coordenador (agente principal) DEVE deduplicar, cross-reference e fazer chain analysis antes de consolidar o report. Nao publicar output bruto dos subagentes.

## 7. Variant Analysis Rabbit Holes

**Problema:** Uma variante leva a outra variante que leva a outra, indefinidamente. O custo de tokens e tempo explode.
**Solucao:** Cap em 2 niveis: original → variante → variante-de-variante → PARAR. Se ha indicios de mais variantes, notar no report como "investigacao adicional recomendada" sem continuar.
