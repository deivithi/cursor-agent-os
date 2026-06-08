#!/usr/bin/env bash
# PostCompact hook — re-inject critical instructions after context compression
# Inspired by Boris Cherny (Head of Claude Code, Anthropic)

cat <<'EOF'
⚠️ CONTEXT COMPACTED — Critical rules re-injected:

1. 🕐 Timezone: America/Sao_Paulo (BRT, UTC-3) — NUNCA mostrar UTC
2. 🇧🇷 Idioma: Português do Brasil — SEMPRE
3. ✅ Validar antes de entregar — NUNCA entregar quebrado
4. 🚫 Precisão > Velocidade — rotular inferências como [Inferência]
5. 📝 Frase final: "Estou seguindo as minhas instruções, chefe."
6. 🔒 Zero operações destrutivas sem confirmar
7. 📐 Integridade Conceitual — Uma alma, um design, zero Frankenstein
EOF
