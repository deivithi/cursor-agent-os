// Painel da manutenção contínua para o início de sessão (Claude Code e Cursor).
// Lê ~/.claude/manutencao/painel.json, que o porteiro (skills/manutencao-continua/scripts/ciclo.mjs)
// grava a cada ciclo agendado. Nunca lança erro: painel ausente ou quebrado = texto vazio.

const fs = require("fs");
const os = require("os");
const path = require("path");

const CAMINHO_PADRAO = path.join(os.homedir(), ".claude", "manutencao", "painel.json");
const DIAS_PARADO = 2;

function textoManutencao({ caminho = CAMINHO_PADRAO, agora = new Date() } = {}) {
  let painel;
  try {
    painel = JSON.parse(fs.readFileSync(caminho, "utf8"));
  } catch {
    return "";
  }
  const partes = [];
  if (painel && typeof painel.texto === "string" && painel.texto.trim()) partes.push(painel.texto.trim());
  const atualizado = Date.parse(painel && painel.atualizado);
  const dia = 24 * 60 * 60 * 1000;
  // Data no futuro (relógio errado ou arquivo editado) também conta como agenda parada.
  if (Number.isNaN(atualizado) || agora - atualizado > DIAS_PARADO * dia || atualizado - agora > dia) {
    const quando = Number.isNaN(atualizado) ? "data desconhecida" : new Date(atualizado).toISOString().slice(0, 10);
    partes.push(
      `⚠️ A agenda da manutenção contínua está parada (último ciclo: ${quando}). ` +
        "Confira a tarefa Febracis-Manutencao-Continua; reinstale com skills/manutencao-continua/scripts/instalar-agenda.ps1.",
    );
  }
  return partes.join("\n\n");
}

module.exports = { textoManutencao, CAMINHO_PADRAO, DIAS_PARADO };
