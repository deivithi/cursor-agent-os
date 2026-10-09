#!/usr/bin/env node
// profile — sessionStart: injeta profile + domain activation rules

const {
  readStdinJson,
  emitCursorOutput,
  emitClaudeText,
  isCursorHook,
} = require("./caverna-runtime");
const {
  readProfileFlag,
  writeProfileFlag,
  readDomainActive,
  writeDomainActive,
  getWorkspaceRoot,
  detectProfileFromSignals,
  detectDomainsFromWorkspace,
  mergeDomainState,
  buildActivationContext,
} = require("./profile-runtime");
// Fail-open: sem o módulo do painel, o profile e as domain rules continuam.
let textoManutencao = () => "";
try {
  ({ textoManutencao } = require("./manutencao-painel"));
} catch {
  /* painel indisponível */
}

async function main() {
  const input = await readStdinJson();
  const cwd = getWorkspaceRoot(input && input.cwd);

  let profileId = readProfileFlag();
  let profileSource = profileId ? "manual" : null;

  if (!profileId) {
    profileId = detectProfileFromSignals(cwd);
    profileSource = profileId ? "auto" : null;
    if (profileId) writeProfileFlag(profileId);
  }

  const workspaceDomains = detectDomainsFromWorkspace(cwd);
  const domainState = mergeDomainState(
    readDomainActive(),
    workspaceDomains,
    "workspace",
  );
  writeDomainActive(domainState);

  // Painel da manutenção contínua: pendências do PO em toda sessão, sem comando.
  const manutencao = textoManutencao();
  const ativacao = buildActivationContext(profileId, domainState.rules);
  const context = [ativacao, manutencao].filter(Boolean).join("\n\n---\n\n");
  if (!context) {
    if (isCursorHook()) emitCursorOutput({});
    return;
  }

  const env = {};
  if (profileId) {
    env.ACTIVE_PROFILE = profileId;
    env.ACTIVE_PROFILE_SOURCE = profileSource || "manual";
  }
  if (domainState.rules.length) {
    env.ACTIVE_DOMAIN_RULES = domainState.rules.join(",");
  }

  if (!isCursorHook()) {
    emitClaudeText(context);
    return;
  }

  emitCursorOutput({
    additional_context: context,
    env,
  });
}

main().catch(() => {
  if (isCursorHook()) emitCursorOutput({});
});
