#!/usr/bin/env node
// caverna — sessionStart (Cursor) / SessionStart (Claude Code)

const fs = require('fs');
const path = require('path');
const { getDefaultMode, safeWriteFlag } = require('./caverna-config');
const {
  isCursorHook,
  getClaudeHome,
  getFlagPath,
  getCavernaSkillPath,
  readStdinJson,
  emitCursorOutput,
  emitClaudeText,
} = require('./caverna-runtime');

const INDEPENDENT_MODES = new Set(['commit', 'review', 'compress']);

async function main() {
  const mode = getDefaultMode();
  const flagPath = getFlagPath();

  if (mode === 'off') {
    try { fs.unlinkSync(flagPath); } catch (e) { /* ignore */ }
    if (isCursorHook()) {
      emitCursorOutput({});
    } else {
      emitClaudeText('OK');
    }
    return;
  }

  safeWriteFlag(flagPath, mode);

  if (INDEPENDENT_MODES.has(mode)) {
    const message = 'CAVERNA ATIVA — modo: ' + mode + '. Comportamento definido pela skill /caverna-' + mode + '.';
    if (isCursorHook()) {
      emitCursorOutput({
        additional_context: message,
        env: { CAVERNA_MODE: mode },
      });
    } else {
      emitClaudeText(message);
    }
    return;
  }

  let skillContent = '';
  const skillPath = getCavernaSkillPath();
  if (skillPath) {
    try {
      skillContent = fs.readFileSync(skillPath, 'utf8');
    } catch (e) { /* fallback abaixo */ }
  }

  let output;
  if (skillContent) {
    const body = skillContent.replace(/^---[\s\S]*?---\s*/, '');
    const filtered = body.split('\n').reduce((acc, line) => {
      const tableRowMatch = line.match(/^\|\s*\*\*(\S+?)\*\*\s*\|/);
      if (tableRowMatch) {
        if (tableRowMatch[1] === mode) acc.push(line);
        return acc;
      }
      const exampleMatch = line.match(/^-\s+\*?\*?(\S+?):\*?\*?\s/);
      if (exampleMatch) {
        if (exampleMatch[1] === mode) acc.push(line);
        return acc;
      }
      acc.push(line);
      return acc;
    }, []);
    output = '🪨 CAVERNA ATIVA — modo: ' + mode.toUpperCase() + ' (PT-BR)\n\n' + filtered.join('\n');
  } else {
    output =
      '🪨 CAVERNA ATIVA — modo: ' + mode.toUpperCase() + ' (PT-BR)\n\n' +
      'Responde terso como caverna inteligente. Toda substância técnica fica. Só enfeite morre.\n\n' +
      'Modo atual: **' + mode + '**. Trocar: `/caverna leve|completo|ultra|off`.\n\n' +
      '🇧🇷 Acentos obrigatórios. 😀 Emojis preservados. 💻 Código/commits/PRs: normal.';
  }

  if (!isCursorHook()) {
    output += buildClaudeStatuslineNudge();
  }

  if (isCursorHook()) {
    await readStdinJson();
    emitCursorOutput({
      additional_context: output,
      env: { CAVERNA_MODE: mode },
    });
    return;
  }

  emitClaudeText(output);
}

function buildClaudeStatuslineNudge() {
  try {
    const claudeDir = getClaudeHome();
    const settingsPath = path.join(claudeDir, 'settings.json');
    const localSettingsPath = path.join(claudeDir, 'settings.local.json');
    let hasStatusline = false;

    for (const candidate of [settingsPath, localSettingsPath]) {
      if (!fs.existsSync(candidate)) continue;
      const settings = JSON.parse(fs.readFileSync(candidate, 'utf8'));
      if (settings.statusLine) {
        hasStatusline = true;
        break;
      }
    }

    if (hasStatusline) return '';

    const isWindows = process.platform === 'win32';
    const scriptName = isWindows ? 'caverna-statusline.ps1' : 'caverna-statusline.sh';
    const scriptPath = path.join(__dirname, scriptName);
    const command = isWindows
      ? 'powershell -ExecutionPolicy Bypass -File "' + scriptPath + '"'
      : 'bash "' + scriptPath + '"';
    const statusLineSnippet = '"statusLine": { "type": "command", "command": ' + JSON.stringify(command) + ' }';
    return '\n\n💡 STATUSLINE Claude Code: badge [🪨 CAVERNA:ULTRA]. Adiciona em settings.local.json: ' + statusLineSnippet;
  } catch (e) {
    return '';
  }
}

main().catch(() => {
  if (isCursorHook()) {
    emitCursorOutput({});
  } else {
    emitClaudeText('OK');
  }
});
