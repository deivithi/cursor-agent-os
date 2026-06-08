#!/usr/bin/env node
// caverna — preToolUse (Cursor): lembrete curto antes de cada tool quando caverna ativa.
// Compensa a limitação do beforeSubmitPrompt (sem additional_context no Cursor).

const { readFlag } = require('./caverna-config');
const {
  isCursorHook,
  getFlagPath,
  readStdinJson,
  emitCursorOutput,
  buildReinforcement,
} = require('./caverna-runtime');

const INDEPENDENT_MODES = new Set(['commit', 'review', 'compress']);

async function main() {
  if (!isCursorHook()) return;

  await readStdinJson();
  const activeMode = readFlag(getFlagPath());
  if (!activeMode || INDEPENDENT_MODES.has(activeMode)) {
    emitCursorOutput({ permission: 'allow' });
    return;
  }

  emitCursorOutput({
    permission: 'allow',
    agent_message: buildReinforcement(activeMode),
  });
}

main().catch(() => {
  emitCursorOutput({ permission: 'allow' });
});
