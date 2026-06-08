#!/usr/bin/env node
// Runtime compartilhado: Cursor Hooks (primário) + Claude Code (fallback)

const fs = require('fs');
const path = require('path');
const os = require('os');

function isCursorHook() {
  return Boolean(process.env.CURSOR_VERSION || process.env.CURSOR_PROJECT_DIR);
}

function getCursorHome() {
  return process.env.CURSOR_HOME || path.join(os.homedir(), '.cursor');
}

function getClaudeHome() {
  return process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
}

function getFlagPath() {
  if (process.env.CAVERNA_FLAG_PATH) {
    return process.env.CAVERNA_FLAG_PATH;
  }
  if (isCursorHook()) {
    return path.join(getCursorHome(), '.caverna-active');
  }
  return path.join(getClaudeHome(), '.caverna-active');
}

function getCavernaSkillPath() {
  const candidates = [
    path.join(getCursorHome(), 'skills', 'caverna', 'SKILL.md'),
    path.join(__dirname, '..', 'skills', 'caverna', 'SKILL.md'),
    path.join(getClaudeHome(), 'skills', 'caverna', 'SKILL.md'),
  ];
  for (const candidate of candidates) {
    try {
      if (fs.existsSync(candidate)) return candidate;
    } catch (e) { /* ignore */ }
  }
  return null;
}

function readStdinJson() {
  return new Promise((resolve) => {
    let input = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { input += chunk; });
    process.stdin.on('end', () => {
      if (!input.trim()) {
        resolve(null);
        return;
      }
      try {
        resolve(JSON.parse(input));
      } catch (e) {
        resolve(null);
      }
    });
    if (process.stdin.isTTY) {
      resolve(null);
    }
  });
}

function emitCursorOutput(payload) {
  process.stdout.write(JSON.stringify(payload));
}

function emitClaudeText(text) {
  process.stdout.write(text);
}

function emitClaudeHookOutput(hookEventName, additionalContext) {
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName,
      additionalContext,
    },
  }));
}

function buildReinforcement(mode) {
  const base = '🪨 CAVERNA ATIVA (' + mode + '). ' +
    'Dropa artigos/filler/pleasantries/hedging. Fragmentos OK. ' +
    '🇧🇷 Acentos obrigatórios (á/é/ç/ã). 😀 Emojis preservados. ' +
    '💻 Código/commits/PRs: normal. ' +
    '🛡️ Safety carve-out: Supabase destructive, deploy prod, decisões arquiteturais → verbose.';

  if (mode === 'ultra') {
    return base + ' ⚡ Ultra: abrevia (BD/aut/config/req/res/fn/impl), setas → p/ causalidade, 1 palavra quando 1 basta.';
  }
  if (mode === 'completo') {
    return base + ' Dropa artigos, fragmentos OK, sinônimos curtos.';
  }
  if (mode === 'leve') {
    return base + ' Mantém artigos + frases completas. Só dropa filler/hedging.';
  }
  return base;
}

module.exports = {
  isCursorHook,
  getCursorHome,
  getClaudeHome,
  getFlagPath,
  getCavernaSkillPath,
  readStdinJson,
  emitCursorOutput,
  emitClaudeText,
  emitClaudeHookOutput,
  buildReinforcement,
};
