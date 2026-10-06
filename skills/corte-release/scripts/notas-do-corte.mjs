#!/usr/bin/env node
// Notas do corte: lê os PRs mesclados (saída do `gh pr list --json`), separa os que
// entraram depois do corte anterior e gera as notas da versão e o aviso por autor.
// Filtro preferido: ancestralidade (lista de SHAs de `git log <tag>..origin/main`).
// Filtro por data existe como alternativa, com margem, porque o `mergedAt` do GitHub
// sai ~1 s depois da data do commit de squash.
// Sem dependências: roda com `node` puro (>= 20).
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const TAG_RE = /^(?<base>[a-z][a-z0-9-]*-\d+)(?:\.(?<patch>\d+))?$/i;
const ISO_COM_FUSO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:\d{2})$/;
export const MARGEM_MS = 120_000;

/** Próxima tag de patch: sprint-09 → sprint-09.1; sprint-09.1 → sprint-09.2. */
export function proximoPatch(tag) {
  const m = TAG_RE.exec(String(tag ?? '').trim());
  if (!m) throw new Error(`tag fora do padrão <nome>-<número>[.<patch>]: "${tag}"`);
  const patch = m.groups.patch === undefined ? 1 : Number(m.groups.patch) + 1;
  return `${m.groups.base}.${patch}`;
}

function ordenar(prs) {
  return prs.sort((a, b) => Date.parse(a.mergedAt) - Date.parse(b.mergedAt) || a.number - b.number);
}

/** PRs cujo commit de merge está na lista de SHAs (ex.: `git log sprint-09..origin/main --format=%H`). */
export function filtrarPorCommits(prs, shas) {
  const conjunto = new Set(shas.map((s) => s.trim().toLowerCase()).filter(Boolean));
  if (conjunto.size === 0) return [];
  return ordenar(prs.filter((pr) => pr.mergedAt && conjunto.has(String(pr.mergeCommit?.oid ?? '').toLowerCase())));
}

/** Alternativa por data: só PRs mesclados mais de MARGEM_MS depois de `desde` (ISO com fuso). */
export function filtrarDesde(prs, desde, margemMs = MARGEM_MS) {
  if (!ISO_COM_FUSO.test(String(desde ?? ''))) {
    throw new Error(`data inválida em --desde (use ISO com fuso, ex.: 2026-10-06T10:28:23-03:00): "${desde}"`);
  }
  const base = Date.parse(desde);
  if (Number.isNaN(base)) throw new Error(`data inexistente em --desde: "${desde}"`);
  const limite = base + margemMs;
  return ordenar(prs.filter((pr) => pr.mergedAt && Date.parse(pr.mergedAt) > limite));
}

const TIPOS = [
  ['correcao', /^(fix|corrig|correç|correc|hotfix)/i, 'Correções'],
  ['funcionalidade', /^(feat|t\d+(?![a-z])|sprint(?![a-z]))/i, 'Funcionalidades'],
  ['documentacao', /^(docs?(?![a-z])|documenta)/i, 'Documentação'],
  ['manutencao', /^(refactor|perf|chore|test|build|ci)(?![a-z])/i, 'Manutenção'],
];

export function classificar(titulo) {
  const t = String(titulo ?? '').trim();
  for (const [tipo, re] of TIPOS) if (re.test(t)) return tipo;
  return 'outros';
}

const ROTULO = Object.fromEntries([...TIPOS.map(([t, , r]) => [t, r]), ['outros', 'Outros']]);
const ORDEM = ['funcionalidade', 'correcao', 'documentacao', 'manutencao', 'outros'];

export function ehBot(pr) {
  const login = pr.author?.login ?? '';
  return pr.author?.is_bot === true || login.startsWith('app/') || login.endsWith('[bot]');
}

export function agruparPorAutor(prs) {
  const mapa = new Map();
  for (const pr of prs) {
    const login = pr.author?.login ?? 'desconhecido';
    if (!mapa.has(login)) mapa.set(login, []);
    mapa.get(login).push(pr);
  }
  return mapa;
}

/** Notas da versão em Markdown, agrupadas por tipo. */
export function renderNotas({ prs, versao, anterior }) {
  const linhas = [`# ${versao}`, '', `Corte a partir de \`${anterior}\`. ${prs.length} PR(s).`, ''];
  if (prs.length === 0) {
    linhas.push('Nenhum PR mesclado desde o corte anterior. Não há o que liberar.');
    return linhas.join('\n') + '\n';
  }
  for (const tipo of ORDEM) {
    const doTipo = prs.filter((pr) => classificar(pr.title) === tipo);
    if (doTipo.length === 0) continue;
    linhas.push(`## ${ROTULO[tipo]}`, '');
    for (const pr of doTipo) linhas.push(`- #${pr.number} ${pr.title} (@${pr.author?.login ?? 'desconhecido'})`);
    linhas.push('');
  }
  return linhas.join('\n');
}

/** Um aviso por autor humano: o texto vai como comentário no PR mais recente dele. */
export function renderAvisos({ prs, versao, prazo }) {
  const avisos = [];
  for (const [login, dele] of agruparPorAutor(prs.filter((pr) => !ehBot(pr)))) {
    const lista = dele.map((pr) => `- #${pr.number} ${pr.title} — ${pr.url}`).join('\n');
    avisos.push({
      login,
      pr: dele[dele.length - 1].number,
      texto:
        `@${login}, o corte **${versao}** começou. Estes PRs seus entram nele:\n\n${lista}\n\n` +
        `Tem bloqueio ou objeção? Responda neste PR até ${prazo}. ` +
        'Depois do prazo, o corte lê as respostas: objeção leva a decisão ao PO; sem resposta, o corte segue.',
    });
  }
  return avisos;
}

function lerArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const chave = argv[i];
    if (!chave.startsWith('--')) throw new Error(`argumento inesperado: ${chave}`);
    const valor = argv[i + 1];
    if (valor === undefined || valor.startsWith('--')) throw new Error(`falta valor para ${chave}`);
    args[chave.slice(2)] = valor;
    i += 1;
  }
  for (const obrigatorio of ['prs', 'versao', 'anterior']) {
    if (!args[obrigatorio]) throw new Error(`falta --${obrigatorio}`);
  }
  if (!args.commits && !args.desde) throw new Error('falta --commits (preferido) ou --desde');
  if (args.formato && !['json', 'md'].includes(args.formato)) throw new Error(`--formato inválido: ${args.formato}`);
  return args;
}

export function main(argv) {
  const args = lerArgs(argv);
  const todos = JSON.parse(readFileSync(args.prs, 'utf8'));
  if (!Array.isArray(todos)) throw new Error('--prs precisa ser a lista JSON do `gh pr list --json`');
  let prs;
  if (args.commits) {
    // lista vazia ou PR sem mergeCommit é erro de comando, não "nada a liberar"
    const shas = readFileSync(args.commits, 'utf8').split(/\r?\n/).filter((s) => s.trim());
    if (shas.length === 0) throw new Error('--commits está vazio: confira a tag anterior e o `git log <tag>..origin/main`');
    if (todos.length > 0 && !todos.some((pr) => pr.mergeCommit?.oid)) {
      throw new Error('nenhum PR tem mergeCommit: inclua `mergeCommit` no `gh pr list --json`');
    }
    prs = filtrarPorCommits(todos, shas);
  } else {
    prs = filtrarDesde(todos, args.desde);
  }
  if (prs.length === 0 && todos.length > 0) {
    process.stderr.write(`notas-do-corte: aviso: ${todos.length} PR(s) lidos, nenhum entrou no corte\n`);
  }
  const notas = renderNotas({ prs, versao: args.versao, anterior: args.anterior });
  if (args.formato === 'md') return notas;
  const avisos = renderAvisos({ prs, versao: args.versao, prazo: args.prazo ?? 'o fim do QA' });
  if (args['saida-avisos']) {
    // um arquivo por PR avisado: <dir>/<pr>.md, pronto para `gh pr comment <pr> --body-file`
    mkdirSync(args['saida-avisos'], { recursive: true });
    for (const aviso of avisos) writeFileSync(join(args['saida-avisos'], `${aviso.pr}.md`), `${aviso.texto}\n`);
  }
  const saida = {
    versao: args.versao,
    anterior: args.anterior,
    proximoPatch: proximoPatch(args.versao),
    prs: prs.map(({ number, title, url, author, mergedAt }) => ({ number, title, url, autor: author?.login, mergedAt })),
    notas,
    avisos,
  };
  return JSON.stringify(saida, null, 2) + '\n';
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  try {
    process.stdout.write(main(process.argv.slice(2)));
  } catch (erro) {
    process.stderr.write(`notas-do-corte: ${erro.message}\n`);
    process.exit(2);
  }
}
