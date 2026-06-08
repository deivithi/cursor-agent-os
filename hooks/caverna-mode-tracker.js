#!/usr/bin/env node
// caverna — beforeSubmitPrompt (Cursor) / UserPromptSubmit (Claude Code)

const fs = require('fs');
const { getDefaultMode, safeWriteFlag, readFlag } = require('./caverna-config');
const {
  isCursorHook,
  getFlagPath,
  readStdinJson,
  emitCursorOutput,
  emitClaudeHookOutput,
  buildReinforcement,
} = require('./caverna-runtime');

const INDEPENDENT_MODES = new Set(['commit', 'review', 'compress']);

async function main() {
  const flagPath = getFlagPath();
  const data = await readStdinJson();
  const prompt = ((data && data.prompt) || '').trim().toLowerCase();

  if (prompt) {
    applyPromptRules(prompt, flagPath);
  }

  const activeMode = readFlag(flagPath);
  if (activeMode && !INDEPENDENT_MODES.has(activeMode)) {
    if (isCursorHook()) {
      emitCursorOutput({ continue: true });
      return;
    }
    emitClaudeHookOutput('UserPromptSubmit', buildReinforcement(activeMode));
    return;
  }

  if (isCursorHook()) {
    emitCursorOutput({ continue: true });
  }
}

function applyPromptRules(prompt, flagPath) {
  const activationPattern =
    /\b(ativa|ativar|liga|ligar|usa|usar|comeca|começa|inicia|iniciar|fala)\b.*\bcaverna\b(?!-)/i;
  const activationReversePattern =
    /\bcaverna\b(?!-).*\b(modo|ativa|ativar|liga|ligar|iniciar)\b/i;

  if (activationPattern.test(prompt) || activationReversePattern.test(prompt)) {
    if (!/\b(para|parar|desliga|desligar|desativa|desativar)\b/i.test(prompt)) {
      const mode = getDefaultMode();
      if (mode !== 'off') safeWriteFlag(flagPath, mode);
    }
  }

  if (prompt.startsWith('/caverna')) {
    const parts = prompt.split(/\s+/);
    const cmd = parts[0];
    const arg = parts[1] || '';
    let mode = null;

    if (cmd === '/caverna-commit') mode = 'commit';
    else if (cmd === '/caverna-review') mode = 'review';
    else if (cmd === '/caverna-compress') mode = 'compress';
    else if (cmd === '/caverna-help') mode = null;
    else if (cmd === '/caverna') {
      if (arg === 'leve') mode = 'leve';
      else if (arg === 'completo') mode = 'completo';
      else if (arg === 'ultra') mode = 'ultra';
      else if (arg === 'off') mode = 'off';
      else mode = getDefaultMode();
    }

    if (mode && mode !== 'off') safeWriteFlag(flagPath, mode);
    else if (mode === 'off') {
      try { fs.unlinkSync(flagPath); } catch (e) { /* ignore */ }
    }
  }

  const deactivationPattern =
    /\b(para|parar|desliga|desligar|desativa|desativar|pausa|pausar)\s+(a\s+|o\s+modo\s+)?caverna\b(?!-)/i;
  const deactivationReverse =
    /\bcaverna\b(?!-).*\b(para|parar|desliga|desligar|desativa|desativar)\b/i;

  if (deactivationPattern.test(prompt) ||
      deactivationReverse.test(prompt) ||
      /\bmodo\s+normal\b/i.test(prompt)) {
    try { fs.unlinkSync(flagPath); } catch (e) { /* ignore */ }
  }
}

main().catch(() => {
  if (isCursorHook()) {
    emitCursorOutput({ continue: true });
  }
});
