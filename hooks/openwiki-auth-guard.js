#!/usr/bin/env node
/**
 * openwiki-auth-guard.js — PreToolUse guard.
 *
 * Dois riscos cobertos:
 *
 * 1) Bash: `openwiki auth x` / `openwiki personal --update` sem OPENWIKI_X_CLIENT_ID
 *    em ~/.openwiki/.env → o CLI monta a URL de authorize com client_id vazio e
 *    abre a tela de login do X.
 *
 * 2) Write|Edit: reintroduzir o MCP `xapi` (npx @xdevplatform/xurl --app febracis-x-mcp)
 *    em qualquer mcp.json sem credencial em ~/.xurl → xurl sobe o callback em
 *    localhost:8080, monta `https://x.com/i/oauth2/authorize?client_id=` vazio e
 *    abre a tela de login do X a cada start do MCP.
 *
 *    ESTE FOI O INCIDENTE REAL de 2026-09-21 (todos os eventos no histórico do
 *    Chrome usavam redirect_uri=http://localhost:8080/callback). Removido do
 *    mcp.json global e do de projeto em 21/09 09:52–09:54; processo xurl
 *    (porta 8080) encerrado às 09:56.
 *
 * Contrato: fail-open. Erro de leitura/parse → exit 0 (nunca bloqueia por bug).
 * Exit 2 = bloqueia a tool call e devolve a razão ao agente.
 */

const fs = require("fs");
const os = require("os");
const path = require("path");

const READ_TIMEOUT_MS = 4000;

function readStdin() {
  return new Promise((resolve) => {
    let data = "";
    let done = false;
    const finish = () => {
      if (!done) {
        done = true;
        resolve(data);
      }
    };
    const t = setTimeout(finish, READ_TIMEOUT_MS);
    try {
      process.stdin.setEncoding("utf8");
      process.stdin.on("data", (c) => (data += c));
      process.stdin.on("end", () => {
        clearTimeout(t);
        finish();
      });
      process.stdin.on("error", () => {
        clearTimeout(t);
        finish();
      });
    } catch {
      clearTimeout(t);
      finish();
    }
  });
}

function fileHasClientId(p) {
  try {
    if (!fs.existsSync(p) || !fs.statSync(p).isFile()) return false;
    return /^\s*client_id\s*=\s*\S+/m.test(fs.readFileSync(p, "utf8"));
  } catch {
    return false;
  }
}

/** OPENWIKI_X_CLIENT_ID presente em ~/.openwiki/.env? */
function openwikiClientIdConfigured() {
  try {
    const envPath = path.join(os.homedir(), ".openwiki", ".env");
    if (!fs.existsSync(envPath)) return false;
    return /^\s*OPENWIKI_X_CLIENT_ID\s*=\s*\S+/m.test(fs.readFileSync(envPath, "utf8"));
  } catch {
    return false;
  }
}

/** ~/.xurl é arquivo com client_id? (xurl espera arquivo, não diretório) */
function xurlAppConfigured() {
  const candidates = [
    path.join(os.homedir(), ".xurl"),
    path.join(os.homedir(), ".xurl", "config"),
  ];
  return candidates.some(fileHasClientId);
}

const OPENWIKI_AUTH = /\bopenwiki\s+auth\b/i;
const OPENWIKI_UPDATE = /\bopenwiki\s+personal\b[^\n;&|]*--update\b/i;
const XURL_MCP = /xdevplatform\/xurl|--app\s+febracis-x-mcp/i;

function deny(lines) {
  process.stderr.write(lines.join("\n") + "\n");
  process.exit(2);
}

(async () => {
  let payload;
  try {
    const raw = await readStdin();
    if (!raw || !raw.trim()) process.exit(0);
    payload = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  try {
    const tool = String(payload.tool_name || payload.toolName || "");
    const input = payload.tool_input || payload.toolInput || {};

    // ---- Caso 1: comando Bash -------------------------------------------
    if (/bash|shell|execute/i.test(tool) || input.command) {
      const cmd = String(input.command || input.cmd || "");
      if (cmd && /\bopenwiki\b/i.test(cmd)) {
        if ((OPENWIKI_AUTH.test(cmd) || OPENWIKI_UPDATE.test(cmd)) && !/OPENWIKI_AUTH_OK/.test(cmd)) {
          if (!openwikiClientIdConfigured()) {
            deny([
              "openwiki-auth-guard: BLOQUEADO.",
              "",
              "`openwiki auth x` / `openwiki personal --update` exige OPENWIKI_X_CLIENT_ID",
              "em ~/.openwiki/.env. Sem esse valor o CLI abre o navegador em",
              "https://x.com/i/oauth2/authorize?client_id=&... — tela de login do X em loop.",
              "",
              "Para ler sinais do X use `x_search` (Zo) ou a skill `agent-reach`.",
              "A wiki ~/.openwiki/wiki segue legível sem auth.",
              "",
              "Override consciente do operador: inclua OPENWIKI_AUTH_OK no comando.",
              "",
            ]);
          }
        }
      }
    }

    // ---- Caso 2: edição de mcp.json reintroduzindo xurl ------------------
    const fp = String(input.file_path || input.filePath || input.path || "");
    if (fp && /mcp\.json$/i.test(fp)) {
      const blob = [input.content, input.new_string, input.newString, input.code_edit]
        .filter(Boolean)
        .join("\n");
      if (XURL_MCP.test(blob) && !/XURL_MCP_OK/.test(blob)) {
        if (!xurlAppConfigured()) {
          deny([
            "openwiki-auth-guard: BLOQUEADO (MCP xapi / xurl sem credencial).",
            "",
            "Reintroduzir `npx @xdevplatform/xurl --app febracis-x-mcp mcp https://api.x.com/mcp`",
            "sem credencial em ~/.xurl faz o xurl subir callback em localhost:8080 e abrir",
            "https://x.com/i/oauth2/authorize?client_id=&... — tela de login do X a cada start.",
            "",
            "Foi a causa do incidente 2026-09-21 (removido em 21/09 09:52–09:54).",
            "",
            "Para usar o MCP do X de verdade: crie um app em developer.x.com e grave",
            "client_id/client_secret em ~/.xurl (hoje é um DIRETÓRIO vazio — o xurl espera",
            "um ARQUIVO). Sem isso, use a conexão nativa do Zo (`use_app_x` / `x_search`),",
            "que já cobre leitura e publicação.",
            "",
            "Override consciente do operador: inclua XURL_MCP_OK no conteúdo editado.",
            "",
          ]);
        }
      }
    }

    process.exit(0);
  } catch {
    process.exit(0);
  }
})();
