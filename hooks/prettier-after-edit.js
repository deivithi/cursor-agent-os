#!/usr/bin/env node
/**
 * PostToolUse prettier — fail-open.
 * Sem interpolação $ no command string (Grok trata $f como env var obrigatória).
 */
const { spawnSync } = require("child_process");
const { readStdinJson } = require("./caverna-runtime");

function extractPath(payload) {
  if (!payload || typeof payload !== "object") return "";
  const ti = payload.tool_input || payload.toolInput || payload.input || {};
  const tr = payload.tool_response || payload.toolResponse || {};
  const candidates = [
    ti.file_path,
    ti.filePath,
    ti.path,
    tr.filePath,
    tr.file_path,
    payload.file_path,
    payload.filePath,
  ];
  for (const c of candidates) {
    if (typeof c === "string" && c.trim()) return c.trim();
  }
  return "";
}

async function main() {
  const payload = await readStdinJson(800);
  const file = extractPath(payload);
  if (!file) process.exit(0);
  spawnSync(
    "npx",
    ["--yes", "prettier", "--ignore-unknown", "--write", file],
    {
      stdio: "ignore",
      timeout: 20000,
      windowsHide: true,
    }
  );
  process.exit(0);
}

main().catch(() => process.exit(0));
