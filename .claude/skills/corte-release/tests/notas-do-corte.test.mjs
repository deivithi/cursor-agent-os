import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import {
  proximoPatch,
  filtrarDesde,
  filtrarPorCommits,
  classificar,
  ehBot,
  renderNotas,
  renderAvisos,
  main,
} from '../scripts/notas-do-corte.mjs';

// #14 reproduz o caso real: mergedAt 1 s depois do %cI do squash que virou a tag sprint-09.
const PRS = [
  { number: 14, title: 'Sprint 9: passagem do projeto', url: 'https://x/14', author: { login: 'deivithi' }, mergedAt: '2026-10-06T13:28:24Z', mergeCommit: { oid: 'aaa14' } },
  { number: 15, title: 'fix: login some no Safari', url: 'https://x/15', author: { login: 'lorranymarra-febracis' }, mergedAt: '2026-10-08T09:00:00Z', mergeCommit: { oid: 'bbb15' } },
  { number: 16, title: 'T97 painel de embaixadores', url: 'https://x/16', author: { login: 'lorranymarra-febracis' }, mergedAt: '2026-10-09T09:00:00Z', mergeCommit: { oid: 'ccc16' } },
  { number: 17, title: 'docs: runbook DigitalOcean', url: 'https://x/17', author: { login: 'deivithi' }, mergedAt: '2026-10-09T10:00:00Z', mergeCommit: { oid: 'ddd17' } },
  { number: 18, title: 'aberto, sem merge', url: 'https://x/18', author: { login: 'deivithi' }, mergedAt: null, mergeCommit: null },
  { number: 19, title: 'chore(deps): bump turbo', url: 'https://x/19', author: { login: 'app/dependabot', is_bot: true }, mergedAt: '2026-10-09T11:00:00Z', mergeCommit: { oid: 'eee19' } },
];
const TAG_SPRINT_09 = '2026-10-06T10:28:23-03:00';
const SHAS_DEPOIS = ['bbb15', 'CCC16', 'ddd17', 'eee19', ''];

test('proximoPatch soma 1 no patch ou cria o .1, sem diferenciar caixa', () => {
  assert.equal(proximoPatch('sprint-09'), 'sprint-09.1');
  assert.equal(proximoPatch('sprint-09.1'), 'sprint-09.2');
  assert.equal(proximoPatch('sprint-10.9'), 'sprint-10.10');
  assert.equal(proximoPatch('Sprint-10'), 'Sprint-10.1');
});

test('proximoPatch recusa tag fora do padrão', () => {
  assert.throws(() => proximoPatch('v1.2.3'), /fora do padrão/);
  assert.throws(() => proximoPatch(''), /fora do padrão/);
  assert.throws(() => proximoPatch(undefined), /fora do padrão/);
});

test('filtrarPorCommits usa ancestralidade: tira o PR da tag anterior e o sem merge', () => {
  assert.deepEqual(filtrarPorCommits(PRS, SHAS_DEPOIS).map((p) => p.number), [15, 16, 17, 19]);
  assert.deepEqual(filtrarPorCommits(PRS, ['', '  ']), []);
});

test('filtrarDesde com margem não traz de volta o PR mesclado 1 s depois da tag', () => {
  assert.deepEqual(filtrarDesde(PRS, TAG_SPRINT_09).map((p) => p.number), [15, 16, 17, 19]);
  assert.deepEqual(filtrarDesde(PRS, TAG_SPRINT_09, 0).map((p) => p.number).includes(14), true);
});

test('filtrarDesde exige ISO com fuso', () => {
  assert.throws(() => filtrarDesde(PRS, 'ontem'), /data inválida/);
  assert.throws(() => filtrarDesde(PRS, '9'), /data inválida/);
  assert.throws(() => filtrarDesde(PRS, '2026-10-06'), /data inválida/);
  assert.throws(() => filtrarDesde(PRS, '2026-10-06T10:28:23'), /data inválida/);
  assert.throws(() => filtrarDesde(PRS, '2026-13-45T10:00:00Z'), /data inexistente/);
});

test('classificar cobre correções em português, manutenção e título ausente', () => {
  assert.equal(classificar('fix: login'), 'correcao');
  assert.equal(classificar('fix(auth): x'), 'correcao');
  assert.equal(classificar('hotfix telão'), 'correcao');
  assert.equal(classificar('Correções de login'), 'correcao');
  assert.equal(classificar('Corrigir filtro'), 'correcao');
  assert.equal(classificar('T97 painel'), 'funcionalidade');
  assert.equal(classificar('feat(api): fila'), 'funcionalidade');
  assert.equal(classificar('docs: runbook'), 'documentacao');
  assert.equal(classificar('chore: deps'), 'manutencao');
  assert.equal(classificar('refactor: fila'), 'manutencao');
  assert.equal(classificar('Testar carga'), 'outros');
  assert.equal(classificar(undefined), 'outros');
});

test('ehBot reconhece is_bot, app/ e [bot]', () => {
  assert.equal(ehBot(PRS[5]), true);
  assert.equal(ehBot({ author: { login: 'renovate[bot]' } }), true);
  assert.equal(ehBot(PRS[1]), false);
});

test('renderNotas agrupa por tipo e cita autor', () => {
  const md = renderNotas({ prs: filtrarPorCommits(PRS, SHAS_DEPOIS), versao: 'sprint-10', anterior: 'sprint-09' });
  assert.match(md, /^# sprint-10/);
  assert.match(md, /4 PR\(s\)/);
  assert.match(md, /## Funcionalidades\n\n- #16 T97 painel de embaixadores \(@lorranymarra-febracis\)/);
  assert.match(md, /## Correções\n\n- #15/);
  assert.match(md, /## Documentação\n\n- #17/);
  assert.match(md, /## Manutenção\n\n- #19/);
  assert.doesNotMatch(md, /#14|#18/);
});

test('renderNotas sem PR diz que não há o que liberar', () => {
  assert.match(renderNotas({ prs: [], versao: 'sprint-10', anterior: 'sprint-09' }), /Não há o que liberar/);
});

test('renderAvisos faz um aviso por autor humano no PR mais recente dele', () => {
  const avisos = renderAvisos({ prs: filtrarPorCommits(PRS, SHAS_DEPOIS), versao: 'sprint-10', prazo: '10/10 18:00' });
  assert.deepEqual(avisos.map((a) => a.login).sort(), ['deivithi', 'lorranymarra-febracis']);
  const lorrany = avisos.find((a) => a.login === 'lorranymarra-febracis');
  assert.equal(lorrany.pr, 16);
  assert.match(lorrany.texto, /#15 .*#16/s);
  assert.match(lorrany.texto, /até 10\/10 18:00/);
  assert.match(lorrany.texto, /objeção leva a decisão ao PO/);
  assert.equal(avisos.find((a) => a.login === 'deivithi').pr, 17);
});

function arquivos() {
  const dir = mkdtempSync(join(tmpdir(), 'corte-'));
  const prs = join(dir, 'prs.json');
  const commits = join(dir, 'commits.txt');
  writeFileSync(prs, JSON.stringify(PRS));
  writeFileSync(commits, SHAS_DEPOIS.join('\r\n'));
  return { dir, prs, commits };
}

test('main com --commits gera JSON com próximo patch e avisos', () => {
  const f = arquivos();
  const saida = JSON.parse(main(['--prs', f.prs, '--commits', f.commits, '--versao', 'sprint-10', '--anterior', 'sprint-09']));
  assert.equal(saida.proximoPatch, 'sprint-10.1');
  assert.deepEqual(saida.prs.map((p) => p.number), [15, 16, 17, 19]);
  assert.equal(saida.avisos.length, 2);
});

test('main --saida-avisos grava um arquivo por PR avisado', () => {
  const f = arquivos();
  const dir = join(f.dir, 'avisos');
  main(['--prs', f.prs, '--commits', f.commits, '--versao', 'sprint-10', '--anterior', 'sprint-09', '--saida-avisos', dir]);
  assert.deepEqual(readdirSync(dir).sort(), ['16.md', '17.md']);
  assert.match(readFileSync(join(dir, '16.md'), 'utf8'), /@lorranymarra-febracis, o corte \*\*sprint-10\*\*/);
});

test('main --formato md não exige tag no padrão de patch', () => {
  const f = arquivos();
  assert.match(main(['--prs', f.prs, '--commits', f.commits, '--versao', 'v1.2.3', '--anterior', 'v1.2.2', '--formato', 'md']), /^# v1\.2\.3/);
});

test('main com --desde também funciona e recusa argumento faltando', () => {
  const f = arquivos();
  const saida = JSON.parse(main(['--prs', f.prs, '--desde', TAG_SPRINT_09, '--versao', 'sprint-10', '--anterior', 'sprint-09']));
  assert.equal(saida.prs.length, 4);
  assert.throws(() => main(['--prs', f.prs, '--versao', 'sprint-10', '--anterior', 'sprint-09']), /falta --commits/);
  assert.throws(() => main(['--prs', f.prs]), /falta --versao/);
  assert.throws(() => main(['--prs']), /falta valor/);
  assert.throws(() => main(['--prs', f.prs, '--commits', f.commits, '--versao', 'sprint-10', '--anterior', 'sprint-09', '--formato', 'xml']), /formato inválido/);
});

test('main recusa commits.txt vazio e PRs sem mergeCommit', () => {
  const f = arquivos();
  const base = ['--prs', f.prs, '--commits', f.commits, '--versao', 'sprint-10', '--anterior', 'sprint-09'];
  writeFileSync(f.commits, '\n  \n');
  assert.throws(() => main(base), /--commits está vazio/);
  writeFileSync(f.commits, 'bbb15\n');
  writeFileSync(f.prs, JSON.stringify(PRS.map(({ mergeCommit, ...resto }) => resto)));
  assert.throws(() => main(base), /nenhum PR tem mergeCommit/);
});

test('main recusa JSON que não é lista', () => {
  const f = arquivos();
  writeFileSync(f.prs, '{"a":1}');
  assert.throws(
    () => main(['--prs', f.prs, '--commits', f.commits, '--versao', 'sprint-10', '--anterior', 'sprint-09']),
    /precisa ser a lista/,
  );
});
