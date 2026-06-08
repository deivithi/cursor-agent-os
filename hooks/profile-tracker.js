#!/usr/bin/env node
// profile — beforeSubmitPrompt: /profile + detecção por keywords

const { readStdinJson, emitCursorOutput, isCursorHook } = require('./caverna-runtime');
const {
  listProfiles,
  readProfileFlag,
  writeProfileFlag,
  readDomainActive,
  writeDomainActive,
  detectDomainsFromPrompt,
  mergeDomainState,
} = require('./profile-runtime');

async function main() {
  const input = await readStdinJson();
  const prompt = ((input && input.prompt) || '').trim();
  const lower = prompt.toLowerCase();

  if (prompt.startsWith('/profile')) {
    handleProfileCommand(prompt);
    if (isCursorHook()) emitCursorOutput({ continue: true });
    return;
  }

  const promptDomains = detectDomainsFromPrompt(prompt);
  if (promptDomains.length) {
    const next = mergeDomainState(readDomainActive(), promptDomains, 'prompt');
    writeDomainActive(next);
  }

  if (isCursorHook()) emitCursorOutput({ continue: true });
}

function handleProfileCommand(prompt) {
  const parts = prompt.split(/\s+/).filter(Boolean);
  const sub = (parts[1] || '').toLowerCase();

  if (!sub || sub === 'current') {
    const active = readProfileFlag() || 'nenhum';
    return;
  }

  if (sub === 'list') {
    listProfiles();
    return;
  }

  if (sub === 'off' || sub === 'none' || sub === 'clear') {
    writeProfileFlag(null);
    return;
  }

  const available = listProfiles();
  if (available.includes(sub)) {
    writeProfileFlag(sub);
    return;
  }

  const fuzzy = available.find((id) => id.includes(sub) || sub.includes(id));
  if (fuzzy) writeProfileFlag(fuzzy);
}

main().catch(() => {
  if (isCursorHook()) emitCursorOutput({ continue: true });
});
