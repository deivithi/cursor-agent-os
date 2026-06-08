#!/usr/bin/env node
// Runtime compartilhado: profiles + domain activation rules

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

function getCursorHome() {
  return process.env.CURSOR_HOME || path.join(os.homedir(), '.cursor');
}

function getProfileFlagPath() {
  return path.join(getCursorHome(), '.profile-active');
}

function getDomainActivePath() {
  return path.join(getCursorHome(), '.domain-active.json');
}

function getProfilesDir() {
  return path.join(getCursorHome(), 'profiles');
}

function getRulesDir() {
  return path.join(getCursorHome(), 'rules');
}

function readText(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8').trim();
  } catch (e) {
    return '';
  }
}

function readJson(filePath, fallback) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (e) {
    return fallback;
  }
}

function writeJson(filePath, data) {
  const dir = path.dirname(filePath);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

function loadManifest() {
  const manifestPath = path.join(getRulesDir(), 'activation-manifest.json');
  return readJson(manifestPath, { profiles: [], activationRules: [] });
}

function listProfiles() {
  const manifest = loadManifest();
  const dir = getProfilesDir();
  const fromManifest = manifest.profiles.map((p) => p.id);
  let fromDisk = [];
  try {
    fromDisk = fs.readdirSync(dir)
      .filter((f) => f.endsWith('.md') && f !== 'README.md')
      .map((f) => f.replace(/\.md$/, ''));
  } catch (e) { /* ignore */ }
  return [...new Set([...fromManifest, ...fromDisk])].sort();
}

function loadProfile(profileId) {
  if (!profileId) return '';
  const filePath = path.join(getProfilesDir(), profileId + '.md');
  return readText(filePath);
}

function loadActivationRule(ruleId) {
  if (!ruleId) return '';
  const manifest = loadManifest();
  const entry = manifest.activationRules.find((r) => r.id === ruleId);
  const fileName = entry ? entry.file : ruleId + '.md';
  return readText(path.join(getRulesDir(), fileName));
}

function readProfileFlag() {
  const raw = readText(getProfileFlagPath()).toLowerCase();
  return raw || null;
}

function writeProfileFlag(profileId) {
  const flagPath = getProfileFlagPath();
  if (!profileId) {
    try { fs.unlinkSync(flagPath); } catch (e) { /* ignore */ }
    return;
  }
  fs.mkdirSync(path.dirname(flagPath), { recursive: true });
  fs.writeFileSync(flagPath, profileId, 'utf8');
}

function readDomainActive() {
  return readJson(getDomainActivePath(), { rules: [], sources: {} });
}

function writeDomainActive(state) {
  writeJson(getDomainActivePath(), state);
}

function getWorkspaceRoot(fallback) {
  return process.env.CURSOR_PROJECT_DIR || fallback || process.cwd();
}

function getGitBranch(cwd) {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD', {
      cwd,
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8',
    }).trim().toLowerCase();
  } catch (e) {
    return '';
  }
}

function pathExists(base, relativePath) {
  try {
    return fs.existsSync(path.join(base, relativePath));
  } catch (e) {
    return false;
  }
}

function matchesAny(value, patterns) {
  const hay = (value || '').toLowerCase();
  return (patterns || []).some((pattern) => hay.includes(String(pattern).toLowerCase()));
}

function detectProfileFromSignals(cwd) {
  const manifest = loadManifest();
  const branch = getGitBranch(cwd);
  const hay = (cwd + ' ' + branch).toLowerCase();

  for (const profile of manifest.profiles || []) {
    if (matchesAny(hay, profile.pathPatterns) || matchesAny(branch, profile.branchPatterns)) {
      return profile.id;
    }
  }
  return null;
}

function detectDomainsFromWorkspace(cwd) {
  const manifest = loadManifest();
  const activated = [];
  for (const rule of manifest.activationRules || []) {
    const hit = (rule.workspaceMarkers || []).some((marker) => pathExists(cwd, marker));
    if (hit) activated.push(rule.id);
  }
  return activated;
}

function detectDomainsFromPrompt(prompt) {
  const manifest = loadManifest();
  const text = (prompt || '').toLowerCase();
  const activated = [];
  for (const rule of manifest.activationRules || []) {
    const hit = (rule.keywords || []).some((keyword) => text.includes(String(keyword).toLowerCase()));
    if (hit) activated.push(rule.id);
  }
  return activated;
}

function mergeDomainState(existing, nextRuleIds, source) {
  const state = existing && existing.rules ? existing : { rules: [], sources: {} };
  const rules = new Set(state.rules || []);
  const sources = { ...(state.sources || {}) };

  for (const ruleId of nextRuleIds) {
    rules.add(ruleId);
    sources[ruleId] = source;
  }

  return {
    rules: [...rules],
    sources,
  };
}

function buildActivationContext(profileId, domainRuleIds) {
  const sections = [];

  if (profileId) {
    const profileBody = loadProfile(profileId);
    if (profileBody) {
      sections.push('# Profile ativo: ' + profileId + '\n\n' + profileBody);
    }
  }

  for (const ruleId of domainRuleIds) {
    const ruleBody = loadActivationRule(ruleId);
    if (ruleBody) {
      sections.push('# Domain rule ativa: ' + ruleId + '\n\n' + ruleBody);
    }
  }

  if (!sections.length) return '';

  return sections.join('\n\n---\n\n');
}

function buildDomainReminder(domainRuleIds) {
  if (!domainRuleIds.length) return '';
  const manifest = loadManifest();
  const labels = domainRuleIds.map((ruleId) => {
    const entry = (manifest.activationRules || []).find((r) => r.id === ruleId);
    return entry ? entry.skill || ruleId : ruleId;
  });
  return '🧭 Domain rules ativas: ' + labels.join(', ') + '. Carregar skills correspondentes antes de responder.';
}

module.exports = {
  getCursorHome,
  getProfileFlagPath,
  getDomainActivePath,
  loadManifest,
  listProfiles,
  loadProfile,
  loadActivationRule,
  readProfileFlag,
  writeProfileFlag,
  readDomainActive,
  writeDomainActive,
  getWorkspaceRoot,
  detectProfileFromSignals,
  detectDomainsFromWorkspace,
  detectDomainsFromPrompt,
  mergeDomainState,
  buildActivationContext,
  buildDomainReminder,
};
