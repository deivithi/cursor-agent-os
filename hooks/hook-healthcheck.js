#!/usr/bin/env node
/**
 * hook-healthcheck.js — Auditoria, validação e correção idempotente de hooks
 * Cursor dialect: beforeSubmitPrompt, preToolUse, afterFileEdit, beforeShellExecution → version: 1
 * Claude dialect: PreToolUse, PostToolUse, SessionStart, Stop, UserPromptSubmit → preservar description
 *
 * Uso:
 *   node hook-healthcheck.js --check
 *   node hook-healthcheck.js --fix --dry-run
 *   node hook-healthcheck.js --fix
 *   node hook-healthcheck.js --audit   (read-only, leve, exit 0)
 */

const fs = require("fs");
const path = require("path");

const USER_HOME = process.env.USERPROFILE || process.env.HOME || "";
const CURSOR_ROOT = path.join(USER_HOME, ".cursor");
const CLAUDE_ROOT = path.join(USER_HOME, ".claude");
const REPORT_PATH = path.join(CURSOR_ROOT, "hook-health-report.json");
const BACKUP_ROOT = path.join(CURSOR_ROOT, "backups", "hooks");

const CURSOR_EVENTS = new Set([
  "beforeSubmitPrompt",
  "preToolUse",
  "afterFileEdit",
  "beforeShellExecution",
  "afterAgentResponse",
  "beforeMCPExecution",
  "beforeReadOnlyToolUse",
  "postToolUse",
  "postToolUseFailure",
  "stop",
]);

const CLAUDE_EVENTS = new Set([
  "PreToolUse",
  "PostToolUse",
  "SessionStart",
  "SessionEnd",
  "Stop",
  "UserPromptSubmit",
  "StopFailure",
  "PostToolUseFailure",
  "PermissionRequest",
]);

// Eventos que o importador nativo de "Claude Code hooks" do Cursor
// (Settings > Rules, Skills, Subagents > Third-party skills) reconhece e
// mapeia para seus próprios eventos internos, conforme
// https://cursor.com/docs/reference/third-party-hooks ("Hook Step Mapping").
// Um evento válido no schema real do Claude Code (CLAUDE_EVENTS acima) pode
// ainda assim quebrar a tela "Hooks" do Cursor com o erro
// "Failed to parse claude-user Claude hooks configuration" se não estiver
// nesta lista — foi exatamente o que causou StopFailure/PostToolUseFailure/
// PermissionRequest a quebrarem ~/.claude/settings.json em 2026-07-06.
const CURSOR_CLAUDE_IMPORT_EVENTS = new Set([
  "PreToolUse",
  "PostToolUse",
  "UserPromptSubmit",
  "Stop",
  "SubagentStop",
  "SessionStart",
  "SessionEnd",
  "PreCompact",
]);

const OFFICIAL_PLUGIN_MARKERS = [
  "claude-plugins-official",
  "anthropics/claude-plugins-official",
  "anthropics\\claude-plugins-official",
];

const RUNTIME_DEPS = ["bash", "python3", "python", "node", "npx", "powershell", "sh", "cmd"];

const args = process.argv.slice(2);
const modeCheck = args.includes("--check") || (!args.includes("--fix") && !args.includes("--audit"));
const modeFix = args.includes("--fix");
const modeDryRun = args.includes("--dry-run");
const modeAudit = args.includes("--audit");

/** @typedef {'cursor'|'claude'|'unknown'} Dialect */

/**
 * @param {string} dir
 * @returns {string[]}
 */
function walkFiles(dir) {
  const results = [];
  if (!fs.existsSync(dir)) return results;

  /** @param {string} current */
  function walk(current) {
    let entries;
    try {
      entries = fs.readdirSync(current, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const full = path.join(current, entry.name);
      const isDir =
        entry.isDirectory() ||
        entry.isSymbolicLink?.() ||
        (!entry.isFile() && fs.existsSync(full) && fs.statSync(full).isDirectory());
      if (isDir) {
        if (entry.name === "node_modules" || entry.name === ".git") continue;
        walk(full);
      } else if (entry.isFile()) {
        const base = entry.name.toLowerCase();
        if (base === "hooks.json" || base === "settings.json") {
          results.push(full);
        }
      }
    }
  }

  walk(dir);
  return results.sort();
}

/**
 * @param {string} filePath
 * @returns {boolean}
 */
function isOfficialPluginPath(filePath) {
  const normalized = filePath.replace(/\\/g, "/").toLowerCase();
  return OFFICIAL_PLUGIN_MARKERS.some((m) => normalized.includes(m.toLowerCase()));
}

/**
 * @param {string} filePath
 * @returns {boolean}
 */
function isUserOwnedHookFile(filePath) {
  const normalized = path.normalize(filePath);
  const userHooks = [
    path.join(CURSOR_ROOT, "hooks.json"),
    path.join(CURSOR_ROOT, "hooks", "hooks.json"),
    path.join(CLAUDE_ROOT, "hooks", "hooks.json"),
    path.join(CLAUDE_ROOT, "settings.json"),
  ];
  return userHooks.some((p) => path.normalize(p) === normalized);
}

/**
 * @param {object} data
 * @returns {Dialect}
 */
function classifyDialect(data) {
  const hooks = data.hooks;
  if (!hooks || typeof hooks !== "object" || Array.isArray(hooks)) {
    return "unknown";
  }

  const events = Object.keys(hooks);
  const hasCursor = events.some((e) => CURSOR_EVENTS.has(e));
  const hasClaude = events.some((e) => CLAUDE_EVENTS.has(e));

  if (hasCursor && !hasClaude) return "cursor";
  if (hasClaude && !hasCursor) return "claude";
  if (hasCursor && hasClaude) return "cursor";
  if (data.version === 1 && events.length > 0) return "cursor";
  if (data.description && hasClaude) return "claude";
  return "unknown";
}

/**
 * @param {string} jsonText
 * @returns {{ ok: true, data: object } | { ok: false, error: string }}
 */
function parseJson(jsonText) {
  try {
    return { ok: true, data: JSON.parse(jsonText) };
  } catch (err) {
    return { ok: false, error: err instanceof Error ? err.message : String(err) };
  }
}

/**
 * @param {object} data
 * @returns {string[]}
 */
function collectHookCommands(data) {
  const commands = [];

  /** @param {unknown} node */
  function visit(node) {
    if (!node || typeof node !== "object") return;
    if (Array.isArray(node)) {
      node.forEach(visit);
      return;
    }
    if (typeof node.command === "string") {
      commands.push(node.command);
    }
    for (const value of Object.values(node)) {
      if (value && typeof value === "object") visit(value);
    }
  }

  visit(data.hooks || data);
  return commands;
}

/**
 * @param {string} command
 * @param {string} filePath
 * @returns {string[]}
 */
function commandWarnings(command, filePath) {
  const warnings = [];
  const baseDir = path.dirname(filePath);

  for (const dep of RUNTIME_DEPS) {
    const re = new RegExp(`(^|[\\s"'])${dep}\\b`, "i");
    if (re.test(command)) {
      warnings.push(`Comando depende de runtime '${dep}': ${truncate(command, 120)}`);
    }
  }

  const scriptPatterns = [
    /\.\/[^\s"']+/g,
    /"([^"]+\.(js|mjs|cjs|sh|ps1|cmd|py))"/gi,
    /'([^']+\.(js|mjs|cjs|sh|ps1|cmd|py))'/gi,
  ];

  for (const pattern of scriptPatterns) {
    let match;
    while ((match = pattern.exec(command)) !== null) {
      const candidate = match[1] || match[0];
      if (candidate.includes("${") || candidate.includes("%")) continue;
      const resolved = path.isAbsolute(candidate)
        ? candidate
        : path.resolve(baseDir, candidate.replace(/^["']|["']$/g, ""));
      if (
        (candidate.startsWith("./") || candidate.startsWith(".\\") || path.isAbsolute(candidate)) &&
        !fs.existsSync(resolved) &&
        !candidate.includes("CLAUDE_PLUGIN_ROOT")
      ) {
        warnings.push(`Script possivelmente ausente: ${candidate} (resolvido: ${resolved})`);
      }
    }
  }

  return warnings;
}

/**
 * @param {string} text
 * @param {number} max
 */
function truncate(text, max) {
  return text.length <= max ? text : `${text.slice(0, max - 3)}...`;
}

/**
 * @param {object} data
 * @param {Dialect} dialect
 * @returns {{ errors: string[], warnings: string[] }}
 */
function validateStructure(data, dialect) {
  const errors = [];
  const warnings = [];

  if (!data.hooks || typeof data.hooks !== "object" || Array.isArray(data.hooks)) {
    errors.push("Campo 'hooks' ausente ou não é objeto");
    return { errors, warnings };
  }

  if (dialect === "cursor") {
    if (data.version !== 1) {
      errors.push("Dialeto Cursor exige 'version: 1' no topo");
    }
    for (const [event, handlers] of Object.entries(data.hooks)) {
      if (!Array.isArray(handlers)) {
        errors.push(`Evento Cursor '${event}': handlers devem ser array`);
        continue;
      }
      for (const [i, handler] of handlers.entries()) {
        if (!handler || typeof handler !== "object") {
          errors.push(`Evento '${event}' handler[${i}]: deve ser objeto`);
          continue;
        }
        if (typeof handler.command !== "string" || !handler.command.trim()) {
          errors.push(`Evento '${event}' handler[${i}]: 'command' ausente ou inválido`);
        }
      }
    }
  }

  if (dialect === "claude") {
    // BUG REAL confirmado em 2026-07-06 no importador de hooks do Cursor
    // (workbench.glass.main.js, função aWk chamada por cWk): para os eventos
    // "PreToolUse" e "PostToolUse", o Cursor SEMPRE chama `n.matcher.split("|")`
    // sem checar undefined. Um grupo desses dois eventos SEM a chave "matcher"
    // (nem "*") lança TypeError, é capturado, e o Cursor exibe
    // "Failed to parse <source> Claude hooks configuration" para o arquivo
    // inteiro — mesmo que o restante do arquivo esteja perfeito. Isso é
    // diferente da validação real do Claude Code, que aceita "matcher" ausente
    // normalmente (equivale a "*"). Por isso tratamos isso como ERRO
    // bloqueante aqui, específico para esses dois eventos.
    const EVENTS_REQUIRING_MATCHER_FOR_CURSOR_IMPORT = new Set(["PreToolUse", "PostToolUse"]);

    for (const [event, groups] of Object.entries(data.hooks)) {
      if (!Array.isArray(groups)) {
        errors.push(`Evento Claude '${event}': deve ser array de grupos`);
        continue;
      }
      for (const [gi, group] of groups.entries()) {
        if (!group || typeof group !== "object") {
          errors.push(`Evento '${event}' grupo[${gi}]: deve ser objeto`);
          continue;
        }
        if (!Array.isArray(group.hooks)) {
          errors.push(`Evento '${event}' grupo[${gi}]: 'hooks' deve ser array`);
          continue;
        }
        if (EVENTS_REQUIRING_MATCHER_FOR_CURSOR_IMPORT.has(event) && typeof group.matcher !== "string") {
          errors.push(
            `Evento '${event}' grupo[${gi}]: falta a chave 'matcher' (ex: "matcher": "*"). Sem isso, o importador de hooks do Cursor quebra com "Failed to parse ... Claude hooks configuration" (bug confirmado no parser instalado, não é exigência do Claude Code em si).`
          );
        }
        for (const [hi, hook] of group.hooks.entries()) {
          if (!hook || typeof hook !== "object") {
            errors.push(`Evento '${event}' grupo[${gi}].hooks[${hi}]: inválido`);
            continue;
          }
          if (hook.type === "command" && (typeof hook.command !== "string" || !hook.command.trim())) {
            errors.push(
              `Evento '${event}' grupo[${gi}].hooks[${hi}]: command hook sem 'command'`
            );
          }
        }
      }
    }
  }

  if (dialect === "unknown") {
    warnings.push("Dialeto não identificado; validação estrutural mínima aplicada");
  }

  return { errors, warnings };
}

/**
 * Correção idempotente para dialeto Cursor.
 * @param {object} data
 * @returns {{ data: object, changes: string[] }}
 */
function fixCursorDialect(data) {
  const changes = [];
  const next = { ...data };

  if (next.version !== 1) {
    next.version = 1;
    changes.push("Adicionado version: 1");
  }

  if (!next.hooks || typeof next.hooks !== "object" || Array.isArray(next.hooks)) {
    next.hooks = {};
    changes.push("Normalizado hooks para objeto");
  }

  return { data: next, changes };
}

/**
 * @param {object} data
 * @returns {{ data: object, changes: string[] }}
 */
function fixClaudeDialect(data) {
  const changes = [];
  const next = JSON.parse(JSON.stringify(data));

  if (!next.hooks || typeof next.hooks !== "object" || Array.isArray(next.hooks)) {
    return { data: next, changes };
  }

  // Auto-correção do bug real do importador de hooks do Cursor: grupos de
  // "PreToolUse"/"PostToolUse" sem "matcher" quebram o parser inteiro
  // (ver comentário em validateStructure). Corrigir automaticamente com
  // "matcher": "*" preserva 100% do comportamento (Claude Code já trata
  // matcher ausente como "todas as ferramentas") e destrava o Cursor.
  const EVENTS_REQUIRING_MATCHER_FOR_CURSOR_IMPORT = new Set(["PreToolUse", "PostToolUse"]);
  for (const [event, groups] of Object.entries(next.hooks)) {
    if (!EVENTS_REQUIRING_MATCHER_FOR_CURSOR_IMPORT.has(event) || !Array.isArray(groups)) continue;
    groups.forEach((group, gi) => {
      if (group && typeof group === "object" && typeof group.matcher !== "string") {
        group.matcher = "*";
        changes.push(`Adicionado "matcher": "*" em '${event}' grupo[${gi}] (evita crash do importador de hooks do Cursor)`);
      }
    });
  }

  return { data: next, changes };
}

/**
 * @param {string} filePath
 * @param {object} rootData
 * @returns {{ data: object, changes: string[], dialect: Dialect }}
 */
function prepareFix(filePath, rootData) {
  const isSettings = path.basename(filePath).toLowerCase() === "settings.json";
  const hooksPayload = isSettings ? { hooks: rootData.hooks } : rootData;
  const dialect = classifyDialect(hooksPayload);
  const official = isOfficialPluginPath(filePath);

  if (dialect === "cursor") {
    const { data, changes } = fixCursorDialect(hooksPayload);
    if (isSettings) {
      return {
        data: { ...rootData, hooks: data.hooks },
        changes,
        dialect,
      };
    }
    return { data, changes, dialect };
  }

  if (dialect === "claude") {
    const { data, changes } = fixClaudeDialect(hooksPayload);
    if (official && hooksPayload.version !== undefined) {
      changes.push("Preservado: sem version em plugin oficial Claude");
    }
    if (isSettings) {
      return {
        data: { ...rootData, hooks: data.hooks },
        changes,
        dialect,
      };
    }
    return { data, changes, dialect };
  }

  return { data: rootData, changes: [], dialect };
}

/**
 * @param {string} timestamp
 * @param {string} filePath
 * @param {string} content
 */
function backupFile(timestamp, filePath, content) {
  const rel = path.relative(USER_HOME, filePath);
  const dest = path.join(BACKUP_ROOT, timestamp, rel);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, content, "utf8");
}

/**
 * @param {object} data
 */
function serializeJson(data) {
  return `${JSON.stringify(data, null, 2)}\n`;
}

/**
 * @param {unknown} a
 * @param {unknown} b
 */
function deepEqual(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
}

/**
 * @returns {string}
 */
function timestampFolder() {
  const now = new Date();
  const pad = (n) => String(n).padStart(2, "0");
  return [
    now.getFullYear(),
    pad(now.getMonth() + 1),
    pad(now.getDate()),
  ].join("-") + `_${pad(now.getHours())}-${pad(now.getMinutes())}-${pad(now.getSeconds())}`;
}

/**
 * @param {string} filePath
 * @returns {boolean}
 */
function isAuditScope(filePath) {
  if (!modeAudit) return true;
  return isUserOwnedHookFile(filePath);
}

/**
 * @returns {Promise<{ exitCode: number, report: object }>}
 */
async function main() {
  const scanRoots = [CURSOR_ROOT, CLAUDE_ROOT];
  const allFiles = [...new Set(scanRoots.flatMap(walkFiles))].filter(isAuditScope);

  /** @type {object} */
  const report = {
    generatedAt: new Date().toISOString(),
    mode: modeAudit ? "audit" : modeFix ? (modeDryRun ? "fix-dry-run" : "fix") : "check",
    summary: {
      filesChecked: 0,
      filesValid: 0,
      filesWithErrors: 0,
      filesWithWarnings: 0,
      filesChanged: 0,
      filesPlannedChanges: 0,
      blockingErrors: 0,
    },
    inventory: [],
    files: [],
  };

  let backupTimestamp = null;
  const plannedWrites = [];

  for (const filePath of allFiles) {
    const relPath = path.relative(USER_HOME, filePath).replace(/\\/g, "/");
    const entry = {
      path: filePath,
      relativePath: relPath,
      dialect: "unknown",
      valid: false,
      parseError: null,
      errors: [],
      warnings: [],
      changes: [],
      changed: false,
      officialPlugin: isOfficialPluginPath(filePath),
      userOwned: isUserOwnedHookFile(filePath),
    };

    report.summary.filesChecked += 1;
    report.inventory.push(relPath);

    let raw;
    try {
      raw = fs.readFileSync(filePath, "utf8");
    } catch (err) {
      entry.errors.push(`Leitura falhou: ${err instanceof Error ? err.message : String(err)}`);
      report.summary.filesWithErrors += 1;
      report.summary.blockingErrors += 1;
      report.files.push(entry);
      continue;
    }

    const parsed = parseJson(raw);
    if (!parsed.ok) {
      entry.parseError = parsed.error;
      entry.errors.push(`JSON inválido: ${parsed.error}`);
      report.summary.filesWithErrors += 1;
      report.summary.blockingErrors += 1;
      report.files.push(entry);
      continue;
    }

    const rootData = parsed.data;
    const isSettings = path.basename(filePath).toLowerCase() === "settings.json";
    const hooksPayload = isSettings ? { hooks: rootData.hooks } : rootData;

    if (!rootData.hooks) {
      if (isSettings) {
        entry.warnings.push("settings.json sem chave hooks — ignorado para validação de hooks");
        entry.valid = true;
        report.summary.filesValid += 1;
        report.files.push(entry);
        continue;
      }
    }

    entry.dialect = classifyDialect(hooksPayload);
    const validation = validateStructure(hooksPayload, entry.dialect);
    entry.errors.push(...validation.errors);
    entry.warnings.push(...validation.warnings);

    if (
      entry.dialect === "claude" &&
      isSettings &&
      path.normalize(filePath) === path.normalize(path.join(CLAUDE_ROOT, "settings.json"))
    ) {
      for (const event of Object.keys(hooksPayload.hooks || {})) {
        if (!CURSOR_CLAUDE_IMPORT_EVENTS.has(event)) {
          entry.warnings.push(
            `Evento '${event}' é válido no schema do Claude Code, mas NÃO está na lista de eventos que o importador de hooks do Cursor reconhece (${[...CURSOR_CLAUDE_IMPORT_EVENTS].join(", ")}). Isso pode causar "Failed to parse claude-user Claude hooks configuration" na tela Hooks do Cursor. Remova este evento de ~/.claude/settings.json ou aceite que ele só funcionará no Claude Code standalone (fora do Cursor).`
          );
        }
      }
    }

    for (const cmd of collectHookCommands(hooksPayload)) {
      entry.warnings.push(...commandWarnings(cmd, filePath));
    }

    entry.warnings = [...new Set(entry.warnings)];

    if (modeFix && entry.errors.length === 0) {
      const { data: fixedData, changes, dialect } = prepareFix(filePath, rootData);
      entry.dialect = dialect;
      const newRaw = serializeJson(fixedData);

      if (!deepEqual(fixedData, rootData)) {
        entry.changes = changes.length ? changes : ["Normalização estrutural"];
        if (modeDryRun) {
          entry.changed = false;
          report.summary.filesPlannedChanges += 1;
          plannedWrites.push({ filePath, newRaw, oldRaw: raw });
        } else {
          if (!backupTimestamp) backupTimestamp = timestampFolder();
          backupFile(backupTimestamp, filePath, raw);
          fs.writeFileSync(filePath, newRaw, "utf8");
          entry.changed = true;
          report.summary.filesChanged += 1;
        }
      }
    } else if (modeFix && entry.errors.length > 0) {
      const { data: fixedData, changes, dialect } = prepareFix(filePath, rootData);
      const postValidation = validateStructure(
        isSettings ? { hooks: fixedData.hooks } : fixedData,
        dialect
      );
      if (postValidation.errors.length === 0) {
        const newRaw = serializeJson(fixedData);
        if (!deepEqual(fixedData, rootData)) {
          entry.changes = [...changes, "Correção automática aplicada"];
          entry.errors = [];
          if (modeDryRun) {
            report.summary.filesPlannedChanges += 1;
            plannedWrites.push({ filePath, newRaw, oldRaw: raw });
          } else {
            if (!backupTimestamp) backupTimestamp = timestampFolder();
            backupFile(backupTimestamp, filePath, raw);
            fs.writeFileSync(filePath, newRaw, "utf8");
            entry.changed = true;
            report.summary.filesChanged += 1;
          }
        }
      }
    }

    entry.valid = entry.errors.length === 0;
    if (entry.valid) report.summary.filesValid += 1;
    else {
      report.summary.filesWithErrors += 1;
      report.summary.blockingErrors += entry.errors.length;
    }
    if (entry.warnings.length > 0) report.summary.filesWithWarnings += 1;

    report.files.push(entry);
  }

  if (backupTimestamp) {
    report.backupDir = path.join(BACKUP_ROOT, backupTimestamp);
  }

  if (modeDryRun && plannedWrites.length > 0) {
    report.plannedWrites = plannedWrites.map((w) => ({
      path: w.filePath,
      relativePath: path.relative(USER_HOME, w.filePath).replace(/\\/g, "/"),
    }));
  }

  report.summary.status =
    report.summary.blockingErrors === 0
      ? report.summary.filesWithWarnings > 0
        ? "ok_with_warnings"
        : "ok"
      : "error";

  fs.mkdirSync(path.dirname(REPORT_PATH), { recursive: true });
  fs.writeFileSync(REPORT_PATH, serializeJson(report), "utf8");

  if (!modeAudit) {
    console.log(`Relatório: ${REPORT_PATH}`);
    console.log(
      `Status: ${report.summary.status} | verificados=${report.summary.filesChecked} válidos=${report.summary.filesValid} erros=${report.summary.filesWithErrors} avisos=${report.summary.filesWithWarnings}`
    );
    if (modeFix) {
      console.log(
        modeDryRun
          ? `Alterações planejadas: ${report.summary.filesPlannedChanges}`
          : `Arquivos alterados: ${report.summary.filesChanged}`
      );
      if (report.backupDir) console.log(`Backup: ${report.backupDir}`);
    }
    for (const f of report.files.filter((x) => x.errors.length > 0)) {
      console.error(`\n[ERRO] ${f.relativePath}`);
      f.errors.forEach((e) => console.error(`  - ${e}`));
    }
  } else if (report.summary.blockingErrors > 0) {
    console.error(
      `[hook-healthcheck audit] ${report.summary.blockingErrors} erro(s) de hooks detectado(s). Ver ${REPORT_PATH}`
    );
  }

  const exitCode = modeAudit ? 0 : report.summary.blockingErrors > 0 ? 1 : 0;
  return { exitCode, report };
}

main()
  .then(({ exitCode }) => process.exit(exitCode))
  .catch((err) => {
    console.error("hook-healthcheck falhou:", err);
    process.exit(1);
  });
