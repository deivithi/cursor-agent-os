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

  const context = buildActivationContext(profileId, domainState.rules);
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
