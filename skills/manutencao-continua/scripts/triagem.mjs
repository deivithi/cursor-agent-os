#!/usr/bin/env node
// Triagem do ciclo de manutenção: junta os sinais do projeto (issues, falhas de CI em main,
// erros de runtime, vulnerabilidades), tira duplicados, classifica e decide o destino de cada
// um dentro do orçamento do ciclo. O estado (tentativas, PRs e itens já tratados) fica num JSON
// fora do repo; os PRs abertos pelo agente são conferidos a cada ciclo para não abrir PR duplicado.
// Sem dependências: roda com `node` puro (>= 20).
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, realpathSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const SEVERIDADES = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];
export const MAX_TENTATIVAS = 2;
export const ORCAMENTO_PADRAO = 3;
export const LIMIAR_RUNTIME_HIGH = 20;
export const MARCA_PR = 'manutencao-id:';

// Assuntos de issue que param no gate humano (human-architectural-gate.md e sandbox-dangerous.md).
// Só vale para texto de issue: erro de runtime e nome de pacote não passam por aqui (falso positivo).
// Fronteira de palavra com acento: `\b` do JS só entende ASCII.
const GATE_RE = new RegExp(
  `(?<![\\p{L}\\d_])(?:${[
    'lgpd', 'gdpr', 'cpf', 'pii', 'dpo', 'consentimento', 'dados\\s+pessoais', 'titular(es)?\\s+(d[oa]s?\\s+)?dados', 'direitos?\\s+d[oa]\\s+titular',
    'anonimiza\\p{L}*', 'pseudonimiza\\p{L}*', 'pol[ií]tica\\s+de\\s+reten[çc][ãa]o', 'reten[çc][ãa]o\\s+de\\s+dados',
    '(e-?mail|telefone|endere[çc]o)s?\\s+d[oa]s?\\s+(leads?|clientes?|embaixador(es)?|titular(es)?)',
    'senhas?', 'passwords?', 'cripto\\p{L}*', 'crypto', 'encript\\p{L}*', 'jwt', 'hmac',
    'bcrypt', 'argon2', 'secrets?', 'segredos?', 'tokens?\\s+d[oa]\\s+\\p{L}+',
    'truncate', 'drop\\s+(table|column)', 'delete\\s+(from|leads|registros|dados|em\\s+massa)', 'purge', 'expurgo',
    'backfill', 'dedup\\p{L}*', 'deduplica\\p{L}*', '(mesclar|unificar)\\s+(leads|registros|cadastros)',
    '(apagar|excluir|deletar|remover)\\s+(os\\s+|as\\s+|minha\\s+|sua\\s+|a\\s+)?(dados|conta|todos|todas|leads|cadastros|registros|a\\s+base|em\\s+massa)',
    'migra[çc][ãa]o\\s+destrutiva',
    '(deploy|publicar|subir\\s+(a\\s+)?(corre[çc][ãa]o|vers[ãa]o|release|build|c[óo]digo))\\s+(\\S+\\s+){0,3}(em\\s+)?(prd|produ[çc][ãa]o)',
  ].join('|')})(?![\\p{L}\\d_])`,
  'iu',
);
const ROTULOS_GATE = new Set(['lgpd', 'seguranca:cripto', 'dados:destrutivo', 'gate-humano']);
export const ROTULO_LIBERADO = 'gate:liberado'; // o PO deu a spec: a issue sai do gate
const ROTULOS_IGNORAR = new Set(['wontfix', 'duplicate', 'duplicado', 'question', 'duvida', 'dúvida', 'invalid', 'blocked', 'bloqueado']);
const AUTORES_CONFIAVEIS = new Set(['OWNER', 'MEMBER', 'COLLABORATOR']);
const FALHAS_CI = new Set(['failure', 'timed_out', 'startup_failure']);
const SEM_DECISAO_CI = new Set(['cancelled', 'skipped', 'stale', 'neutral']);

/** Dígitos verificadores do CPF: separa CPF de um número qualquer de 11 dígitos. */
export function cpfValido(digitos) {
  if (!/^\d{11}$/.test(digitos) || /^(\d)\1{10}$/.test(digitos)) return false;
  const dv = (n) => {
    let soma = 0;
    for (let i = 0; i < n; i += 1) soma += Number(digitos[i]) * (n + 1 - i);
    const r = (soma * 10) % 11;
    return r === 10 ? 0 : r;
  };
  return dv(9) === Number(digitos[9]) && dv(10) === Number(digitos[10]);
}

/** Mascara e-mail, CPF e telefone. Defesa em profundidade: a coleta já deve chegar sem PII. */
export function mascararPII(texto) {
  return String(texto ?? '')
    .replace(/[\w.+-]+@[\w-]+(\.[\w-]+)+/g, '<email>')
    .replace(/\b\d{3}\.\d{3}\.\d{3}-\d{2}\b/g, '<cpf>')
    .replace(/\b(cpf\W{0,3})\d{11}\b/gi, '$1<cpf>')
    .replace(/\+55\d{10,11}\b/g, '<telefone>')
    .replace(/(\+?55\s?)?(\(\d{2}\)\s?|\b\d{2}\s)9?\d{4}[-\s]?\d{4}\b/g, '<telefone>')
    .replace(/\b9?\d{4}-\d{4}\b/g, '<telefone>')
    // 11 dígitos crus: CPF se o dígito verificador bate; celular se é DDD + 9 + 8 dígitos.
    .replace(/\b\d{11}\b/g, (n) => (cpfValido(n) ? '<cpf>' : /^[1-9]{2}9\d{8}$/.test(n) ? '<telefone>' : n));
}

/** Normaliza a mensagem de erro para agrupar ocorrências iguais (tira PII, ids, números). */
export function impressaoDigital(texto) {
  return mascararPII(texto)
    .toLowerCase()
    .replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, '<uuid>')
    .replace(/\b[0-9a-f]{12,}\b/g, '<hash>')
    .replace(/\d+/g, '<n>')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 160);
}

const curto = (texto) => createHash('sha1').update(texto).digest('hex').slice(0, 10);

function data(iso) {
  const t = Date.parse(iso ?? '');
  return Number.isNaN(t) ? null : t;
}

function rotulos(issue) {
  return (issue.labels ?? []).map((l) => String(typeof l === 'string' ? l : l?.name ?? '').toLowerCase());
}

function severidadeDosRotulos(lista) {
  if (lista.some((l) => /^(p0|critical|cr[ií]tico|sev:critical)$/.test(l))) return 'CRITICAL';
  if (lista.some((l) => /^(p1|high|alto|sev:high)$/.test(l))) return 'HIGH';
  if (lista.some((l) => /^(p3|low|baixo|sev:low)$/.test(l))) return 'LOW';
  return null;
}

/**
 * Issues da API REST: `gh api "repos/$REPO/issues?state=open&per_page=100" --paginate --slurp`.
 * O `gh issue list --json` não tem `authorAssociation`; a REST tem, mas mistura PRs (campo `pull_request`).
 * Aceita a lista de páginas (`--slurp`) e os nomes em camelCase do `gh issue list`.
 */
export function deIssues(issues) {
  return (issues ?? []).flat().filter((i) => i && !i.pull_request).map((i) => {
    const lista = rotulos(i);
    let tipo = 'bug';
    if (lista.some((l) => /^(enhancement|feature|funcionalidade|melhoria)$/.test(l))) tipo = 'funcionalidade';
    else if (lista.some((l) => /^(security|seguran[çc]a)/.test(l))) tipo = 'seguranca';
    else if (!lista.some((l) => /^(bug|defeito)$/.test(l)) && /^(feat(\(|:|\s)|melhoria\b|quero\b|seria bom\b)/i.test(String(i.title ?? ''))) {
      tipo = 'funcionalidade';
    }
    const padrao = tipo === 'funcionalidade' ? 'LOW' : tipo === 'seguranca' ? 'HIGH' : 'MEDIUM';
    const aprovada = lista.includes('aprovado');
    return {
      id: `issue#${i.number}`,
      tipo,
      titulo: mascararPII(i.title),
      texto: `${i.title ?? ''}\n${i.body ?? ''}`,
      rotulos: lista,
      severidade: severidadeDosRotulos(lista) ?? padrao,
      desde: i.createdAt ?? i.created_at ?? null,
      url: i.html_url ?? i.url ?? null,
      aprovada,
      // Texto de issue é dado não confiável: só autor da casa ou issue aprovada vai para correção autônoma.
      confiavel: aprovada || AUTORES_CONFIAVEIS.has(String(i.author_association ?? i.authorAssociation ?? '').toUpperCase()),
      ignorar: lista.some((l) => ROTULOS_IGNORAR.has(l)),
      comHumano: (i.assignees ?? []).some((a) => !/\[bot\]$|^app\//.test(String(a?.login ?? a))),
    };
  });
}

/**
 * Execuções do `gh run list --branch main --json databaseId,workflowName,conclusion,status,createdAt,url,headSha`.
 * Por workflow, conta só a última execução concluída. O id leva o SHA da primeira falha da sequência
 * atual, para que uma quebra nova no mesmo workflow não herde as tentativas da anterior.
 * `ancoras` (do estado) guarda esse SHA: se a sequência passa da janela do `--limit`, o id não muda.
 * Cada sinal leva `ancora: { workflow, marco }` para o chamador gravar no estado.
 */
export function deRunsCI(runs, ancoras = {}) {
  const porWorkflow = new Map();
  for (const r of runs ?? []) {
    // Em andamento, cancelado, pulado ou sem data: não diz se main está verde ou vermelho.
    if (!r.conclusion || SEM_DECISAO_CI.has(r.conclusion) || data(r.createdAt) === null) continue;
    const nome = String(r.workflowName ?? r.name ?? 'ci');
    if (!porWorkflow.has(nome)) porWorkflow.set(nome, []);
    porWorkflow.get(nome).push(r);
  }
  const sinais = [];
  for (const [nome, lista] of porWorkflow) {
    lista.sort((a, b) => data(b.createdAt) - data(a.createdAt));
    if (!FALHAS_CI.has(lista[0].conclusion)) continue;
    let primeira = lista[0];
    let houveVerde = false;
    for (const r of lista) {
      if (!FALHAS_CI.has(r.conclusion)) {
        houveVerde = true;
        break;
      }
      primeira = r;
    }
    const calculado = String(primeira.headSha ?? primeira.databaseId ?? primeira.createdAt).slice(0, 7);
    // Sem verde na janela, a sequência pode ter começado antes dela: vale a âncora gravada.
    const marco = !houveVerde && ancoras[nome] ? ancoras[nome] : calculado;
    sinais.push({
      ancora: { workflow: nome, marco },
      id: `ci:${nome}@${marco}`,
      tipo: 'falha-ci',
      titulo: `CI de main falhando: ${nome}`,
      texto: nome,
      rotulos: [],
      severidade: 'HIGH',
      desde: primeira.createdAt,
      url: lista[0].url ?? null,
      aprovada: true,
      confiavel: true,
    });
  }
  return sinais;
}

/** Erros de runtime: [{ mensagem, quando, rota? }] (logs do Vercel, DigitalOcean ou Supabase). */
export function deErrosRuntime(erros, limiarHigh = LIMIAR_RUNTIME_HIGH) {
  if (!Number.isFinite(limiarHigh) || limiarHigh < 1) throw new Error(`limiar inválido: ${limiarHigh}`);
  const grupos = new Map();
  for (const e of erros ?? []) {
    const chave = impressaoDigital(e.mensagem);
    if (!chave) continue;
    const g = grupos.get(chave) ?? { amostra: e, total: 0, desde: null };
    g.total += 1;
    const q = data(e.quando);
    if (q !== null && (g.desde === null || q < data(g.desde))) g.desde = e.quando;
    grupos.set(chave, g);
  }
  return [...grupos.entries()].map(([chave, g]) => ({
    id: `runtime:${curto(chave)}`,
    tipo: 'erro-runtime',
    titulo: `Erro em runtime (${g.total}x): ${mascararPII(g.amostra.mensagem).slice(0, 80)}`,
    texto: `${mascararPII(g.amostra.mensagem)}\n${g.amostra.rota ?? ''}`,
    rotulos: [],
    severidade: g.total >= limiarHigh ? 'HIGH' : 'MEDIUM',
    desde: g.desde,
    url: null,
    aprovada: true,
    confiavel: true,
    ocorrencias: g.total,
  }));
}

/** Vulnerabilidades: [{ pacote, severidade, id }] (npm audit, govulncheck, pip-audit). Uma por pacote. */
export function deVulnerabilidades(vulns) {
  const mapa = { critical: 'CRITICAL', high: 'HIGH', moderate: 'MEDIUM', medium: 'MEDIUM', low: 'LOW' };
  const porPacote = new Map();
  for (const v of vulns ?? []) {
    const pacote = String(v.pacote ?? '').trim();
    if (!pacote) continue;
    const sev = mapa[String(v.severidade ?? '').toLowerCase()] ?? 'MEDIUM';
    const g = porPacote.get(pacote) ?? { severidade: 'LOW', ids: [] };
    if (SEVERIDADES.indexOf(sev) < SEVERIDADES.indexOf(g.severidade)) g.severidade = sev;
    if (v.id) g.ids.push(String(v.id));
    porPacote.set(pacote, g);
  }
  return [...porPacote.entries()].map(([pacote, g]) => ({
    id: `vuln:${pacote}`,
    tipo: 'vulnerabilidade',
    titulo: `Dependência vulnerável: ${pacote} (${g.ids.length ? g.ids.join(', ') : 'sem id'})`,
    texto: pacote,
    rotulos: [],
    severidade: g.severidade,
    desde: null,
    url: null,
    aprovada: true,
    confiavel: true,
  }));
}

function idDoPr(pr) {
  for (const linha of String(pr.body ?? '').split(/\r?\n/)) {
    const i = linha.indexOf(MARCA_PR);
    if (i >= 0) return linha.slice(i + MARCA_PR.length).trim();
  }
  return null;
}

/** PRs do agente (`gh pr list --label agente:manutencao --state all --json number,body,state`) ainda abertos. */
export function idsComPrAberto(prs) {
  const mapa = new Map();
  for (const pr of prs ?? []) {
    const id = idDoPr(pr);
    if (id && (pr.state ?? 'OPEN') === 'OPEN') mapa.set(id, pr.number);
  }
  return mapa;
}

/** Fecha no estado os PRs que o PO já decidiu: MERGED → resolvido; CLOSED → pr-recusado. */
export function conciliar(estado, prs, agora = new Date()) {
  let novo = estado;
  for (const pr of prs ?? []) {
    const id = idDoPr(pr);
    if (!id || novo[id]?.pr !== pr.number || novo[id]?.resolvido) continue;
    if (pr.state === 'MERGED') novo = registrar(novo, id, 'resolvido', { agora });
    else if (pr.state === 'CLOSED') novo = registrar(novo, id, 'pr-recusado', { agora });
  }
  return novo;
}

export function precisaGateHumano(sinal) {
  if (sinal.rotulos.includes(ROTULO_LIBERADO)) return false;
  if (sinal.rotulos.some((l) => ROTULOS_GATE.has(l))) return true;
  return sinal.id.startsWith('issue#') && GATE_RE.test(sinal.texto);
}

/** Destino de um sinal, antes do orçamento. */
export function destino(sinal, estado = {}, prsAbertos = new Map()) {
  const hist = estado[sinal.id] ?? {};
  if (sinal.ignorar) return 'ignorar';
  if (prsAbertos.has(sinal.id) || (hist.pr && !hist.resolvido)) return 'aguardando-revisao';
  if (sinal.comHumano) return 'com-humano';
  if ((hist.tentativas ?? 0) >= MAX_TENTATIVAS) return 'escalar';
  if (precisaGateHumano(sinal)) return 'gate-humano';
  if (sinal.tipo === 'seguranca') return 'seguranca';
  if (!sinal.confiavel) return 'aguardando-triagem';
  if (sinal.tipo === 'funcionalidade') return sinal.aprovada ? 'corrigir' : 'propor-spec';
  if (sinal.severidade === 'LOW') return 'backlog';
  return 'corrigir';
}

// Destinos que geram comentário ou registro: depois de tratados, não se repetem a cada ciclo.
export const UMA_VEZ = new Set(['gate-humano', 'propor-spec', 'escalar', 'backlog', 'seguranca', 'aguardando-triagem']);

function ordem(a, b) {
  const s = SEVERIDADES.indexOf(a.severidade) - SEVERIDADES.indexOf(b.severidade);
  if (s !== 0) return s;
  const da = data(a.desde) ?? Infinity;
  const db = data(b.desde) ?? Infinity;
  return da - db || a.id.localeCompare(b.id);
}

/**
 * Monta a fila do ciclo. Só `orcamento` itens ficam com `corrigir`; o resto vai para `proximo-ciclo`.
 * CI de main quebrado corrige primeiro e sozinho: em main vermelho, o gauntlet dos outros falharia.
 */
export function triar(sinais, { estado = {}, orcamento = ORCAMENTO_PADRAO, prsAbertos = new Map() } = {}) {
  if (!Number.isInteger(orcamento) || orcamento < 0) throw new Error(`orçamento inválido: ${orcamento}`);
  const vistos = new Map();
  for (const s of sinais) if (!vistos.has(s.id)) vistos.set(s.id, s);
  const fila = [...vistos.values()].sort(ordem).map((s) => {
    let acao = destino(s, estado, prsAbertos);
    if (UMA_VEZ.has(acao) && estado[s.id]?.tratado === acao) acao = 'ja-tratado';
    return { ...s, acao };
  });
  // CI quebrado que está sendo corrigido (agora ou em PR) segura o resto: main vermelho derruba o gauntlet.
  // CI escalado não trava: o ciclo não pode parar por um workflow que só o PO destrava.
  const ciQuebrado = fila.some((i) => i.tipo === 'falha-ci' && (i.acao === 'corrigir' || i.acao === 'aguardando-revisao'));
  let usados = 0;
  for (const item of fila) {
    if (item.acao !== 'corrigir') continue;
    if (ciQuebrado && item.tipo !== 'falha-ci') item.acao = 'proximo-ciclo';
    else if (usados < orcamento) usados += 1;
    else item.acao = 'proximo-ciclo';
  }
  const resumo = {};
  for (const item of fila) resumo[item.acao] = (resumo[item.acao] ?? 0) + 1;
  // `ramo`: nome seguro para worktree e branch (o id tem `#`, `:` e `@`).
  const ramo = (id) => `manut/${id.replace(/[^a-z0-9]+/gi, '-').replace(/^-|-$/g, '').toLowerCase().slice(0, 50)}`;
  return { fila: fila.map(({ texto, ancora, ...resto }) => ({ ...resto, ramo: ramo(resto.id) })), resumo };
}

export const RESULTADOS = ['falhou', 'pr', 'pr-recusado', 'resolvido', 'tratado', 'reset'];

/** Registra o resultado de uma tentativa. `tratado` exige a ação (ex.: gate-humano). */
export function registrar(estado, id, resultado, { pr = null, acao = null, agora = new Date() } = {}) {
  if (!id) throw new Error('falta o id do item');
  const novo = structuredClone(estado ?? {});
  const hist = novo[id] ?? { tentativas: 0 };
  switch (resultado) {
    case 'falhou':
      hist.tentativas = (hist.tentativas ?? 0) + 1;
      break;
    case 'pr':
      if (!Number.isInteger(pr) || pr < 1) throw new Error('resultado "pr" exige o número do PR');
      hist.pr = pr;
      hist.resolvido = false;
      break;
    case 'pr-recusado':
      hist.tentativas = (hist.tentativas ?? 0) + 1;
      delete hist.pr;
      break;
    case 'resolvido':
      hist.resolvido = true;
      hist.tentativas = 0;
      delete hist.tratado;
      break;
    case 'tratado':
      if (!UMA_VEZ.has(acao)) throw new Error(`resultado "tratado" exige a ação (--acao): ${[...UMA_VEZ].join(', ')}`);
      hist.tratado = acao;
      break;
    case 'reset':
      delete novo[id];
      return novo;
    default:
      throw new Error(`resultado inválido: "${resultado}" (use ${RESULTADOS.join(', ')})`);
  }
  hist.atualizado = agora.toISOString();
  novo[id] = hist;
  return novo;
}

const ROTULO_ACAO = {
  corrigir: '🔧 Corrigir neste ciclo',
  seguranca: '🔐 Segurança (vai para security-audit)',
  'gate-humano': '🛡️ Gate humano (precisa de spec do PO)',
  escalar: '🚨 Escalar (2 tentativas sem sucesso)',
  'aguardando-triagem': '👀 Autor de fora: PO confirma antes (rótulo aprovado)',
  'propor-spec': '📝 Propor spec (funcionalidade sem aprovação)',
  'aguardando-revisao': '⏳ PR aberto, aguardando revisão',
  'com-humano': '👤 Já atribuída a uma pessoa',
  'proximo-ciclo': '⏭️ Próximo ciclo',
  backlog: '🗂️ Backlog',
  'ja-tratado': '✔️ Já tratado em ciclo anterior',
  ignorar: '🚫 Ignorada pelo rótulo',
};

export function renderResumo({ fila, resumo }, projeto = 'projeto') {
  const linhas = [`# Manutenção — ${projeto}`, ''];
  if (fila.length === 0) return `${linhas.join('\n')}Nenhum sinal novo. Projeto estável.\n`;
  for (const acao of Object.keys(ROTULO_ACAO)) {
    const itens = fila.filter((i) => i.acao === acao);
    if (itens.length === 0) continue;
    linhas.push(`## ${ROTULO_ACAO[acao]} (${resumo[acao]})`, '');
    for (const i of itens) linhas.push(`- [${i.severidade}] ${i.titulo}${i.url ? ` — ${i.url}` : ''} \`${i.id}\``);
    linhas.push('');
  }
  return linhas.join('\n');
}

function lerJson(caminho, padrao) {
  if (!existsSync(caminho)) {
    if (padrao !== undefined) return padrao;
    throw new Error(`arquivo não encontrado: ${caminho}`);
  }
  const bruto = readFileSync(caminho);
  // PowerShell 5.1 grava `>` em UTF-16LE com BOM.
  const texto = bruto[0] === 0xff && bruto[1] === 0xfe ? bruto.toString('utf16le') : bruto.toString('utf8');
  return JSON.parse(texto.replace(/^﻿/, ''));
}

function argumentos(argv) {
  const a = {};
  for (let i = 0; i < argv.length; i += 1) {
    const k = argv[i];
    if (!k.startsWith('--')) throw new Error(`argumento inesperado: ${k}`);
    const v = argv[i + 1];
    if (v === undefined || v.startsWith('--')) throw new Error(`falta valor para ${k}`);
    a[k.slice(2)] = v;
    i += 1;
  }
  return a;
}

function numero(valor, nome) {
  if (valor === undefined) return undefined;
  const n = Number(valor);
  if (!Number.isFinite(n)) throw new Error(`${nome} inválido: "${valor}"`);
  return n;
}

/** `~/` no início vira a pasta do usuário: entre aspas, nem bash nem pwsh expandem o `~`. */
export function expandirHome(caminho) {
  return caminho && /^~[\\/]/.test(caminho) ? join(homedir(), caminho.slice(2)) : caminho;
}

function gravarJson(caminho, valor) {
  mkdirSync(dirname(caminho), { recursive: true });
  writeFileSync(caminho, `${JSON.stringify(valor, null, 2)}\n`);
}

const CHAVE_ANCORAS = '_ancoras_ci';

export function main(argv, saida = process.stdout) {
  const a = argumentos(argv);
  const caminhoEstado = expandirHome(a.estado);
  if (a.resultado) {
    if (!caminhoEstado) throw new Error('--resultado exige --estado');
    const novo = registrar(lerJson(caminhoEstado, {}), a.id, a.resultado, { pr: numero(a.pr, '--pr') ?? null, acao: a.acao ?? null });
    gravarJson(caminhoEstado, novo);
    saida.write(`${a.id}: ${a.resultado}\n`);
    return 0;
  }
  // Arquivo de sinais citado e ausente é coletor que falhou: erro, nunca "zero sinais".
  const sinal = (caminho) => (caminho ? lerJson(caminho) : []);
  const prs = sinal(a.prs);
  const runs = sinal(a.ci);
  const anterior = caminhoEstado ? lerJson(caminhoEstado, {}) : {};
  let estado = conciliar(anterior, prs);
  const sinaisCI = deRunsCI(runs, estado[CHAVE_ANCORAS] ?? {});
  const sinais = [
    ...deIssues(sinal(a.issues)),
    ...sinaisCI,
    ...deErrosRuntime(sinal(a.erros), numero(a.limiar, '--limiar') ?? LIMIAR_RUNTIME_HIGH),
    ...deVulnerabilidades(sinal(a.vulns)),
  ];
  const resultado = triar(sinais, {
    estado,
    orcamento: numero(a.orcamento, '--orcamento') ?? ORCAMENTO_PADRAO,
    prsAbertos: idsComPrAberto(prs),
  });
  if (caminhoEstado) {
    // Âncora de CI: grava a de cada workflow vermelho; apaga a de workflow que voltou ao verde.
    if (a.ci) {
      const ancoras = {};
      for (const s of sinaisCI) ancoras[s.ancora.workflow] = s.ancora.marco;
      estado = { ...estado, [CHAVE_ANCORAS]: ancoras };
      if (Object.keys(ancoras).length === 0) delete estado[CHAVE_ANCORAS];
    }
    if (JSON.stringify(estado) !== JSON.stringify(anterior)) gravarJson(caminhoEstado, estado);
  }
  saida.write(a.formato === 'md' ? renderResumo(resultado, a.projeto) : `${JSON.stringify(resultado, null, 2)}\n`);
  return 0;
}

// realpath dos dois lados: pela junction de ~/.claude/skills, argv[1] e import.meta.url diferem.
function chamadoDireto() {
  try {
    return Boolean(process.argv[1]) && realpathSync(process.argv[1]) === realpathSync(fileURLToPath(import.meta.url));
  } catch {
    return false;
  }
}

if (chamadoDireto()) {
  try {
    process.exitCode = main(process.argv.slice(2));
  } catch (e) {
    process.stderr.write(`erro: ${e.message}\n`);
    process.exitCode = 1;
  }
}
