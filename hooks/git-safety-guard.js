#!/usr/bin/env node
// git-safety-guard — preToolUse
// Enforce (Akita/Galego boas práticas + rules/test-integrity.md):
//   1. commit/push direto em main/master  -> ask (confirmar)
//   2. push --force/-f em main/master      -> ask (aviso forte)
//   3. remoção de arquivo de teste (rm/del/Remove-Item) -> ask (test-integrity)
//   4. inserir skip/xfail em teste via Edit/Write -> allow + agent_message (lembrete)
//   5. --dangerously-skip-permissions fora de sandbox -> allow + agent_message
//
// Fail-OPEN: se não conseguir parsear o input, permite (há o git pre-commit hook real
// como segunda camada). Só atua em sessões Cursor (isCursorHook); em Claude Code é no-op.

const {
  readStdinJson,
  emitCursorOutput,
  isCursorHook,
} = require("./caverna-runtime");

// Extrai a string de comando de shell de vários formatos possíveis de input.
function extractCommand(payload) {
  if (!payload || typeof payload !== "object") return "";
  const ti =
    payload.tool_input ||
    payload.toolInput ||
    payload.input ||
    payload.arguments ||
    {};
  const candidates = [
    ti.command,
    ti.cmd,
    ti.script,
    ti.code,
    payload.command,
    payload.cmd,
  ];
  for (const c of candidates) {
    if (typeof c === "string" && c.trim()) return c;
  }
  return "";
}

function getToolName(payload) {
  if (!payload || typeof payload !== "object") return "";
  return String(
    payload.tool_name || payload.toolName || payload.tool || "",
  ).toLowerCase();
}

// Para Edit/Write: pega o texto que está sendo inserido + o caminho do arquivo.
function extractEdit(payload) {
  const ti =
    (payload && (payload.tool_input || payload.toolInput || payload.input)) ||
    {};
  const filePath = ti.file_path || ti.filePath || ti.path || "";
  const content =
    ti.new_string || ti.newString || ti.content || ti.new_str || "";
  return { filePath: String(filePath), content: String(content) };
}

const TEST_FILE_RE =
  /(^|[\/\\])(test_|.*_test\.|.*\.(test|spec)\.)|([\/\\](tests?|__tests__)[\/\\])/i;
const DELETE_CMD_RE = /\b(rm|rmdir|del|erase|unlink)\b|remove-item\b/i;
const SKIP_RE =
  /\b(it\.skip|describe\.skip|test\.skip|xit\b|xdescribe\b|\.only\b)|@pytest\.mark\.(skip|xfail)|@unittest\.skip|t\.Skip\(|@Disabled\b|#\[ignore\]/;

function isMainBranch(cmd) {
  // push/commit que menciona explicitamente main/master como alvo
  return (
    /\b(origin\s+)?(main|master)\b/.test(cmd) ||
    /\bHEAD:(main|master)\b/.test(cmd)
  );
}

async function main() {
  if (!isCursorHook()) return; // no-op fora do Cursor

  const payload = await readStdinJson();
  if (!payload) {
    emitCursorOutput({ permission: "allow" });
    return;
  }

  const tool = getToolName(payload);
  const cmd = extractCommand(payload);

  // ---- Caminho shell (Bash / PowerShell / terminal) ----
  if (cmd) {
    const lc = cmd.toLowerCase();

    // 2. force push em main/master
    if (
      /git\s+push/.test(lc) &&
      /(--force\b|--force-with-lease\b|\s-f\b)/.test(lc) &&
      isMainBranch(lc)
    ) {
      emitCursorOutput({
        permission: "ask",
        user_message:
          "🛑 git-safety: force-push em main/master. Operação destrutiva e irreversível " +
          "(reescreve histórico remoto). Confirma?",
      });
      return;
    }

    // 1. commit/push direto em main/master
    if (/git\s+commit/.test(lc) && isMainBranch(lc)) {
      emitCursorOutput({
        permission: "ask",
        user_message:
          "⚠️ git-safety: commit mirando main/master. Padrão: branch dedicada + PR. Confirma?",
      });
      return;
    }
    if (/git\s+push/.test(lc) && isMainBranch(lc)) {
      emitCursorOutput({
        permission: "ask",
        user_message:
          "⚠️ git-safety: push direto p/ main/master. Padrão: PR com review-agent antes do merge. Confirma?",
      });
      return;
    }

    // 3. remoção de arquivo de teste
    if (DELETE_CMD_RE.test(lc) && TEST_FILE_RE.test(cmd)) {
      emitCursorOutput({
        permission: "ask",
        user_message:
          "🧪 test-integrity: este comando remove arquivo(s) de teste. Deletar teste exige " +
          "aceite explícito (rules/test-integrity.md). Confirma a remoção?",
      });
      return;
    }

    // 5. dangerously-skip-permissions fora de sandbox
    if (
      lc.includes("dangerously-skip-permissions") &&
      !process.env.SANDBOX &&
      !process.env.DEVCONTAINER
    ) {
      emitCursorOutput({
        permission: "allow",
        agent_message:
          "🛡️ sandbox-dangerous: --dangerously-skip-permissions deve rodar só em dev container/sandbox isolado (rules/sandbox-dangerous.md).",
      });
      return;
    }

    emitCursorOutput({ permission: "allow" });
    return;
  }

  // ---- Caminho Edit/Write: skip/xfail introduzido em arquivo de teste ----
  if (
    tool.includes("edit") ||
    tool.includes("write") ||
    tool.includes("update")
  ) {
    const { filePath, content } = extractEdit(payload);
    if (
      filePath &&
      TEST_FILE_RE.test(filePath) &&
      content &&
      SKIP_RE.test(content)
    ) {
      emitCursorOutput({
        permission: "allow",
        agent_message:
          "🧪 test-integrity: você está inserindo skip/xfail/only em arquivo de teste. " +
          "Desabilitar teste exige aceite explícito + motivo (rules/test-integrity.md). " +
          "Prefira corrigir o código.",
      });
      return;
    }
  }

  emitCursorOutput({ permission: "allow" });
}

main().catch(() => {
  // Fail-open: nunca travar a sessão por erro do guard.
  emitCursorOutput({ permission: "allow" });
});
