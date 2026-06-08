#!/usr/bin/env node
// caverna — resolver de configuração compartilhado (fork PT-BR do caveman)
//
// Ordem de resolução p/ modo padrão:
//   1. Variável de ambiente CAVERNA_DEFAULT_MODE
//   2. Arquivo config defaultMode:
//      - $XDG_CONFIG_HOME/caverna/config.json (qualquer plataforma, se setado)
//      - ~/.config/caverna/config.json (macOS / Linux fallback)
//      - %APPDATA%\caverna\config.json (Windows fallback)
//   3. 'ultra' (TRAVADO — fork PT-BR, diferente do caveman original que usa 'full')

const fs = require('fs');
const path = require('path');
const os = require('os');

// Modos válidos PT-BR. Dropei os modos wenyan do original (não fazem sentido p/ PT-BR).
const VALID_MODES = [
  'off', 'leve', 'completo', 'ultra',
  'commit', 'review', 'compress'
];

function getConfigDir() {
  if (process.env.XDG_CONFIG_HOME) {
    return path.join(process.env.XDG_CONFIG_HOME, 'caverna');
  }
  if (process.platform === 'win32') {
    return path.join(
      process.env.APPDATA || path.join(os.homedir(), 'AppData', 'Roaming'),
      'caverna'
    );
  }
  return path.join(os.homedir(), '.config', 'caverna');
}

function getConfigPath() {
  return path.join(getConfigDir(), 'config.json');
}

function getDefaultMode() {
  // 1. Variável de ambiente (maior prioridade)
  const envMode = process.env.CAVERNA_DEFAULT_MODE;
  if (envMode && VALID_MODES.includes(envMode.toLowerCase())) {
    return envMode.toLowerCase();
  }

  // 2. Arquivo config
  try {
    const configPath = getConfigPath();
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (config.defaultMode && VALID_MODES.includes(config.defaultMode.toLowerCase())) {
      return config.defaultMode.toLowerCase();
    }
  } catch (e) {
    // Config file não existe ou inválido — cai no default
  }

  // 3. Default TRAVADO em 'ultra' (atende pedido do usuário Deivithi)
  return 'ultra';
}

// Write de flag file symlink-safe.
// Recusa symlinks no arquivo alvo e no diretório pai imediato,
// usa O_NOFOLLOW onde disponível, escreve atômico via temp + rename c/ 0600.
// Protege contra attacker local substituindo path previsível da flag por symlink.
function safeWriteFlag(flagPath, content) {
  try {
    const flagDir = path.dirname(flagPath);
    fs.mkdirSync(flagDir, { recursive: true });

    try {
      if (fs.lstatSync(flagDir).isSymbolicLink()) return;
    } catch (e) {
      return;
    }

    try {
      if (fs.lstatSync(flagPath).isSymbolicLink()) return;
    } catch (e) {
      if (e.code !== 'ENOENT') return;
    }

    const tempPath = path.join(flagDir, `.caverna-active.${process.pid}.${Date.now()}`);
    const O_NOFOLLOW = typeof fs.constants.O_NOFOLLOW === 'number' ? fs.constants.O_NOFOLLOW : 0;
    const flags = fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | O_NOFOLLOW;
    let fd;
    try {
      fd = fs.openSync(tempPath, flags, 0o600);
      fs.writeSync(fd, String(content));
      try { fs.fchmodSync(fd, 0o600); } catch (e) { /* best-effort Windows */ }
    } finally {
      if (fd !== undefined) fs.closeSync(fd);
    }
    fs.renameSync(tempPath, flagPath);
  } catch (e) {
    // Silent fail — flag é best-effort
  }
}

// Read de flag file symlink-safe, cap de tamanho, validação whitelist.
// "leve" (4 bytes) mais longo que "ultra" (5). "completo" (8). 64 deixa folga sem exfil.
const MAX_FLAG_BYTES = 64;

function readFlag(flagPath) {
  try {
    let st;
    try {
      st = fs.lstatSync(flagPath);
    } catch (e) {
      return null;
    }
    if (st.isSymbolicLink() || !st.isFile()) return null;
    if (st.size > MAX_FLAG_BYTES) return null;

    const O_NOFOLLOW = typeof fs.constants.O_NOFOLLOW === 'number' ? fs.constants.O_NOFOLLOW : 0;
    const flags = fs.constants.O_RDONLY | O_NOFOLLOW;
    let fd;
    let out;
    try {
      fd = fs.openSync(flagPath, flags);
      const buf = Buffer.alloc(MAX_FLAG_BYTES);
      const n = fs.readSync(fd, buf, 0, MAX_FLAG_BYTES, 0);
      out = buf.slice(0, n).toString('utf8');
    } finally {
      if (fd !== undefined) fs.closeSync(fd);
    }

    const raw = out.trim().toLowerCase();
    if (!VALID_MODES.includes(raw)) return null;
    return raw;
  } catch (e) {
    return null;
  }
}

module.exports = { getDefaultMode, getConfigDir, getConfigPath, VALID_MODES, safeWriteFlag, readFlag };
