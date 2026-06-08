#!/usr/bin/env node
// domain — preToolUse: lembrete curto das domain rules ativas na sessão

const { readStdinJson, emitCursorOutput, isCursorHook } = require('./caverna-runtime');
const { readDomainActive, buildDomainReminder } = require('./profile-runtime');

async function main() {
  if (!isCursorHook()) return;

  await readStdinJson();
  const state = readDomainActive();
  const reminder = buildDomainReminder(state.rules || []);

  if (!reminder) {
    emitCursorOutput({ permission: 'allow' });
    return;
  }

  emitCursorOutput({
    permission: 'allow',
    agent_message: reminder,
  });
}

main().catch(() => {
  emitCursorOutput({ permission: 'allow' });
});
