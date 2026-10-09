import { test } from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, symlinkSync, writeFileSync, existsSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  conciliar,
  expandirHome,
  ROTULO_LIBERADO,
  mascararPII,
  impressaoDigital,
  deIssues,
  deRunsCI,
  deErrosRuntime,
  deVulnerabilidades,
  idsComPrAberto,
  precisaGateHumano,
  destino,
  triar,
  registrar,
  renderResumo,
  main,
} from '../scripts/triagem.mjs';

const SCRIPT = join(dirname(fileURLToPath(import.meta.url)), '..', 'scripts', 'triagem.mjs');
const casa = { authorAssociation: 'MEMBER' };

const ISSUES = [
  { number: 31, title: 'Login some no Safari', body: 'Tela branca depois do login.', labels: [{ name: 'bug' }, { name: 'P1' }], createdAt: '2026-10-01T10:00:00Z', url: 'https://x/31', ...casa },
  { number: 32, title: 'Exportar CSV de leads do Método CIS', body: '', labels: [{ name: 'enhancement' }], createdAt: '2026-10-02T10:00:00Z', url: 'https://x/32', ...casa },
  { number: 33, title: 'Apagar dados do embaixador a pedido (LGPD)', body: 'Titular pediu exclusão.', labels: [{ name: 'bug' }], createdAt: '2026-10-03T10:00:00Z', url: 'https://x/33', ...casa },
  { number: 34, title: 'Texto cortado no rodapé', body: '', labels: ['bug', 'low'], createdAt: '2026-10-04T10:00:00Z', url: 'https://x/34', ...casa },
  { number: 35, title: 'Painel de comissões com rótulo trocado', body: '', labels: [], createdAt: '2026-09-30T10:00:00Z', url: 'https://x/35', ...casa },
  { number: 36, title: 'Relatório por consultor', body: '', labels: [{ name: 'enhancement' }, { name: 'aprovado' }], createdAt: '2026-10-05T10:00:00Z', url: 'https://x/36', ...casa },
];

const saidaFalsa = () => ({ texto: '', write(t) { this.texto += t; } });

test('mascararPII tira e-mail, CPF e telefone', () => {
  const t = mascararPII('Falha ao enviar para joao.silva@gmail.com tel (11) 98888-7777 cpf 123.456.789-09');
  assert.equal(t, 'Falha ao enviar para <email> tel <telefone> cpf <cpf>');
  assert.equal(mascararPII(undefined), '');
});

test('impressaoDigital agrupa mensagens que só mudam id e número e não guarda PII', () => {
  const a = impressaoDigital('Lead 123 não encontrado (id 0f8fad5b-d9cb-469f-a165-70867728950e)');
  const b = impressaoDigital('Lead 98 não encontrado (id 7c9e6679-7425-40de-944b-e07fc1f90ae7)');
  assert.equal(a, b);
  assert.equal(impressaoDigital(null), '');
  assert.notEqual(impressaoDigital('timeout no Salesforce'), impressaoDigital('timeout no Supabase'));
  assert.doesNotMatch(impressaoDigital('falha para ana@febracis.com.br'), /ana|febracis/);
});

test('deIssues classifica tipo, severidade, confiança e rótulos de exclusão', () => {
  const [bug, feat, lgpd, low, semRotulo, aprovada] = deIssues(ISSUES);
  assert.deepEqual([bug.id, bug.tipo, bug.severidade, bug.confiavel], ['issue#31', 'bug', 'HIGH', true]);
  assert.deepEqual([feat.tipo, feat.severidade, feat.aprovada], ['funcionalidade', 'LOW', false]);
  assert.equal(lgpd.severidade, 'MEDIUM');
  assert.equal(low.severidade, 'LOW');
  assert.deepEqual([semRotulo.tipo, semRotulo.severidade], ['bug', 'MEDIUM']);
  assert.equal(aprovada.aprovada, true);
  assert.deepEqual(deIssues(undefined), []);

  const [fora, foraAprovada, wontfix, atribuida, atribuidaBot] = deIssues([
    { number: 1, title: 'bug', labels: [], authorAssociation: 'NONE' },
    { number: 2, title: 'bug', labels: ['aprovado'], authorAssociation: 'NONE' },
    { number: 3, title: 'bug', labels: ['wontfix'], ...casa },
    { number: 4, title: 'bug', labels: [], assignees: [{ login: 'lorranymarra-febracis' }], ...casa },
    { number: 5, title: 'bug', labels: [], assignees: [{ login: 'dependabot[bot]' }], ...casa },
  ]);
  assert.equal(fora.confiavel, false);
  assert.equal(foraAprovada.confiavel, true);
  assert.equal(wontfix.ignorar, true);
  assert.equal(atribuida.comHumano, true);
  assert.equal(atribuidaBot.comHumano, false);
});

test('deIssues: "feat:" sem rótulo é funcionalidade, "Featured" não; segurança é HIGH; título sem PII', () => {
  const [f, featured, s, pii] = deIssues([
    { number: 1, title: 'feat: filtro por evento', labels: [] },
    { number: 2, title: 'Featured image quebrada', labels: [] },
    { number: 3, title: 'XSS no nome do embaixador', labels: [{ name: 'security' }] },
    { number: 4, title: 'Erro para maria@x.com', labels: [] },
  ]);
  assert.equal(f.tipo, 'funcionalidade');
  assert.equal(featured.tipo, 'bug');
  assert.deepEqual([s.tipo, s.severidade], ['seguranca', 'HIGH']);
  assert.equal(pii.titulo, 'Erro para <email>');
});

test('deRunsCI usa a última execução concluída e marca o id pela primeira falha da sequência', () => {
  const sinais = deRunsCI([
    { workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'aaaaaaa1' },
    { workflowName: 'verify', conclusion: 'success', createdAt: '2026-10-08T11:00:00Z', headSha: 'bbbbbbb2' },
    { workflowName: 'e2e', conclusion: 'success', createdAt: '2026-10-08T09:00:00Z', headSha: 'c0' },
    { workflowName: 'e2e', conclusion: 'failure', createdAt: '2026-10-08T12:00:00Z', headSha: 'ddddddd4', url: 'u4' },
    { workflowName: 'e2e', conclusion: 'timed_out', createdAt: '2026-10-08T13:00:00Z', headSha: 'eeeeeee5', url: 'u5' },
    { workflowName: 'e2e', conclusion: '', status: 'in_progress', createdAt: '2026-10-08T14:00:00Z', headSha: 'f6' },
    { workflowName: 'build', conclusion: 'startup_failure', createdAt: 'data-ruim', headSha: 'g7' },
  ]);
  assert.equal(sinais.length, 1);
  assert.deepEqual([sinais[0].id, sinais[0].severidade, sinais[0].url, sinais[0].desde], ['ci:e2e@ddddddd', 'HIGH', 'u5', '2026-10-08T12:00:00Z']);
});

test('deRunsCI: quebra nova depois de um verde ganha id novo', () => {
  const antes = deRunsCI([{ workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-01T10:00:00Z', headSha: '1111111a' }]);
  const depois = deRunsCI([
    { workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-01T10:00:00Z', headSha: '1111111a' },
    { workflowName: 'verify', conclusion: 'success', createdAt: '2026-10-02T10:00:00Z', headSha: '2222222b' },
    { workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-09T10:00:00Z', headSha: '3333333c' },
  ]);
  assert.notEqual(antes[0].id, depois[0].id);
});

test('deErrosRuntime agrupa, conta, sobe para HIGH no limiar e usa id curto sem PII', () => {
  const erros = [];
  for (let i = 0; i < 20; i += 1) erros.push({ mensagem: `TypeError: lead ${i} sem campanha`, quando: `2026-10-08T10:${String(i).padStart(2, '0')}:00Z` });
  erros.push({ mensagem: 'Timeout ao chamar o Salesforce para ana@x.com', quando: 'sem-data' });
  erros.push({ mensagem: '', quando: '2026-10-08T09:00:00Z' });
  const sinais = deErrosRuntime(erros);
  assert.equal(sinais.length, 2);
  const lead = sinais.find((s) => s.ocorrencias === 20);
  assert.equal(lead.severidade, 'HIGH');
  assert.equal(lead.desde, '2026-10-08T10:00:00Z');
  assert.match(lead.id, /^runtime:[0-9a-f]{10}$/);
  const sf = sinais.find((s) => s.ocorrencias === 1);
  assert.equal(sf.severidade, 'MEDIUM');
  assert.equal(sf.desde, null);
  assert.doesNotMatch(sf.titulo, /ana@x\.com/);
  assert.equal(deErrosRuntime(erros, 1).every((s) => s.severidade === 'HIGH'), true);
  assert.throws(() => deErrosRuntime([], Number.NaN), /limiar inválido/);
});

test('deVulnerabilidades agrupa por pacote com a maior severidade', () => {
  const sinais = deVulnerabilidades([
    { pacote: 'next', severidade: 'moderate', id: 'GHSA-1' },
    { pacote: 'next', severidade: 'critical', id: 'GHSA-2' },
    { pacote: 'lodash', severidade: 'estranha' },
    { pacote: '', severidade: 'high' },
  ]);
  assert.equal(sinais.length, 2);
  const next = sinais.find((s) => s.id === 'vuln:next');
  assert.equal(next.severidade, 'CRITICAL');
  assert.match(next.titulo, /GHSA-1, GHSA-2/);
  assert.equal(sinais.find((s) => s.id === 'vuln:lodash').severidade, 'MEDIUM');
});

test('idsComPrAberto lê a marca no corpo do PR', () => {
  const mapa = idsComPrAberto([
    { number: 41, body: 'Corrige o login.\r\n\nmanutencao-id: issue#31\nCloses #31' },
    { number: 42, body: 'sem marca' },
    { number: 43, body: null },
  ]);
  assert.deepEqual([...mapa], [['issue#31', 41]]);
});

test('precisaGateHumano pega LGPD, cripto, dado em massa e prd em issue; ignora runtime e pacote', () => {
  const issue = (texto, rotulos = []) => ({ id: 'issue#1', texto, rotulos });
  for (const t of [
    'Exclusão a pedido do titular, LGPD',
    'Trocar bcrypt por argon2',
    'rodar TRUNCATE na tabela de leads',
    'CPF aparece no log de erro',
    'Apagar todos os leads duplicados da base',
    'DELETE FROM leads sem WHERE',
    'e-mail do lead aparece no log',
    'subir correção em produção',
    'Encriptar token do Salesforce',
  ]) assert.equal(precisaGateHumano(issue(t)), true, t);
  assert.equal(precisaGateHumano(issue('ajuste visual', ['gate-humano'])), true);
  assert.equal(precisaGateHumano(issue('Botão desalinhado no celular')), false);
  assert.equal(precisaGateHumano({ id: 'runtime:abc', texto: 'JsonWebTokenError: jwt expired', rotulos: [] }), false);
  assert.equal(precisaGateHumano({ id: 'vuln:crypto-js', texto: 'crypto-js', rotulos: [] }), false);
});

test('destino respeita exclusão, PR aberto, pessoa, tentativas, gate, segurança, confiança e tipo', () => {
  const base = { id: 'issue#9', tipo: 'bug', severidade: 'MEDIUM', texto: 'botão', rotulos: [], aprovada: false, confiavel: true };
  assert.equal(destino(base), 'corrigir');
  assert.equal(destino({ ...base, ignorar: true }), 'ignorar');
  assert.equal(destino(base, { 'issue#9': { pr: 40, resolvido: false } }), 'aguardando-revisao');
  assert.equal(destino(base, {}, new Map([['issue#9', 40]])), 'aguardando-revisao');
  assert.equal(destino(base, { 'issue#9': { pr: 40, resolvido: true } }), 'corrigir');
  assert.equal(destino({ ...base, comHumano: true }), 'com-humano');
  assert.equal(destino(base, { 'issue#9': { tentativas: 2 } }), 'escalar');
  assert.equal(destino({ ...base, texto: 'senha em texto puro' }), 'gate-humano');
  assert.equal(destino({ ...base, tipo: 'seguranca' }), 'seguranca');
  assert.equal(destino({ ...base, confiavel: false }), 'aguardando-triagem');
  assert.equal(destino({ ...base, tipo: 'funcionalidade' }), 'propor-spec');
  assert.equal(destino({ ...base, tipo: 'funcionalidade', aprovada: true }), 'corrigir');
  assert.equal(destino({ ...base, severidade: 'LOW' }), 'backlog');
});

test('triar ordena por severidade e idade, deduplica e respeita o orçamento', () => {
  const sinais = [...deIssues(ISSUES), ...deIssues([ISSUES[0]])];
  const { fila, resumo } = triar(sinais, { orcamento: 1 });
  assert.deepEqual(
    fila.map((i) => [i.id, i.acao]),
    [
      ['issue#31', 'corrigir'],
      ['issue#35', 'proximo-ciclo'],
      ['issue#33', 'gate-humano'],
      ['issue#32', 'propor-spec'],
      ['issue#34', 'backlog'],
      ['issue#36', 'proximo-ciclo'],
    ],
  );
  assert.deepEqual(resumo, { corrigir: 1, 'proximo-ciclo': 2, 'gate-humano': 1, 'propor-spec': 1, backlog: 1 });
  assert.equal('texto' in fila[0], false);
});

test('triar: CI de main quebrado corrige sozinho, mesmo com item mais grave', () => {
  const sinais = [
    ...deVulnerabilidades([{ pacote: 'next', severidade: 'critical', id: 'GHSA-1' }]),
    ...deRunsCI([{ workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'abcdef12' }]),
  ];
  const { fila } = triar(sinais, { orcamento: 3 });
  assert.deepEqual(fila.map((i) => [i.id, i.acao]), [['vuln:next', 'proximo-ciclo'], ['ci:verify@abcdef1', 'corrigir']]);
});

test('triar: item já tratado não gera comentário de novo; mudou de destino, volta', () => {
  const sinais = deIssues([ISSUES[2], ISSUES[1]]);
  const estado = { 'issue#33': { tratado: 'gate-humano' }, 'issue#32': { tratado: 'backlog' } };
  const { fila } = triar(sinais, { estado });
  assert.deepEqual(fila.map((i) => [i.id, i.acao]), [['issue#33', 'ja-tratado'], ['issue#32', 'propor-spec']]);
});

test('triar com orçamento zero não corrige nada e recusa orçamento inválido', () => {
  const { resumo } = triar(deIssues([ISSUES[0]]), { orcamento: 0 });
  assert.deepEqual(resumo, { 'proximo-ciclo': 1 });
  assert.throws(() => triar([], { orcamento: -1 }), /orçamento inválido/);
  assert.throws(() => triar([], { orcamento: 1.5 }), /orçamento inválido/);
  assert.throws(() => triar([], { orcamento: Number.NaN }), /orçamento inválido/);
});

test('registrar: tentativas, PR, recusa, resolvido zera tentativas, tratado e reset', () => {
  const agora = new Date('2026-10-09T12:00:00Z');
  const vazio = {};
  const e1 = registrar(vazio, 'ci:verify@abc', 'falhou', { agora });
  assert.deepEqual(vazio, {});
  assert.deepEqual(e1['ci:verify@abc'], { tentativas: 1, atualizado: '2026-10-09T12:00:00.000Z' });
  const e2 = registrar(registrar(e1, 'ci:verify@abc', 'falhou'), 'ci:verify@abc', 'resolvido');
  assert.equal(e2['ci:verify@abc'].tentativas, 0);
  assert.equal(destino({ id: 'ci:verify@abc', tipo: 'falha-ci', severidade: 'HIGH', texto: '', rotulos: [], confiavel: true }, e2), 'corrigir');

  const p = registrar({}, 'issue#31', 'pr', { pr: 41 });
  assert.deepEqual([p['issue#31'].pr, p['issue#31'].resolvido], [41, false]);
  const r = registrar(p, 'issue#31', 'pr-recusado');
  assert.deepEqual([r['issue#31'].tentativas, r['issue#31'].pr], [1, undefined]);
  assert.equal(registrar({}, 'issue#33', 'tratado', { acao: 'gate-humano' })['issue#33'].tratado, 'gate-humano');
  assert.deepEqual(registrar(p, 'issue#31', 'reset'), {});

  assert.throws(() => registrar({}, 'x', 'pr'), /exige o número/);
  assert.throws(() => registrar({}, 'x', 'pr', { pr: Number.NaN }), /exige o número/);
  assert.throws(() => registrar({}, 'x', 'tratado'), /exige a ação/);
  assert.throws(() => registrar({}, 'x', 'talvez'), /resultado inválido/);
  assert.throws(() => registrar({}, '', 'falhou'), /falta o id/);
});

test('renderResumo agrupa por ação, mostra o id e avisa quando não há sinal', () => {
  assert.match(renderResumo({ fila: [], resumo: {} }, 'Indicações'), /Nenhum sinal novo/);
  const md = renderResumo(triar(deIssues(ISSUES)), 'Indicações');
  assert.match(md, /# Manutenção — Indicações/);
  assert.match(md, /## 🔧 Corrigir neste ciclo \(3\)/);
  assert.match(md, /## 🛡️ Gate humano.*\(1\)/);
  assert.match(md, /\[HIGH\] Login some no Safari — https:\/\/x\/31 `issue#31`/);
});

test('main lê arquivos (UTF-8 com BOM e UTF-16LE), cria a pasta do estado e confere PRs abertos', () => {
  const dir = mkdtempSync(join(tmpdir(), 'manut-'));
  const issues = join(dir, 'issues.json');
  const prs = join(dir, 'prs.json');
  const estado = join(dir, 'nova', 'pasta', 'estado.json');
  writeFileSync(issues, `﻿${JSON.stringify(ISSUES)}`);
  writeFileSync(prs, Buffer.concat([Buffer.from([0xff, 0xfe]), Buffer.from(JSON.stringify([{ number: 50, body: 'manutencao-id: issue#35' }]), 'utf16le')]));
  const saida = saidaFalsa();

  assert.equal(main(['--issues', issues, '--prs', prs, '--estado', estado, '--orcamento', '1'], saida), 0);
  const json = JSON.parse(saida.texto);
  assert.deepEqual([json.resumo.corrigir, json.fila.find((i) => i.id === 'issue#35').acao], [1, 'aguardando-revisao']);

  main(['--estado', estado, '--id', 'issue#31', '--resultado', 'pr', '--pr', '41'], saidaFalsa());
  assert.equal(existsSync(estado), true);
  assert.equal(JSON.parse(readFileSync(estado, 'utf8'))['issue#31'].pr, 41);

  saida.texto = '';
  main(['--issues', issues, '--estado', estado, '--formato', 'md', '--projeto', 'Indicações'], saida);
  assert.match(saida.texto, /PR aberto, aguardando revisão \(1\)/);

  assert.throws(() => main(['--issues', join(dir, 'nao-existe.json')], saida), /não encontrado/);
  assert.throws(() => main(['--id', 'x', '--resultado', 'falhou'], saida), /exige --estado/);
  assert.throws(() => main(['--estado', estado, '--id', 'x', '--resultado', 'pr', '--pr', 'abc'], saida), /--pr inválido/);
  assert.throws(() => main(['--limiar', 'abc'], saida), /--limiar inválido/);
  assert.throws(() => main(['solto'], saida), /argumento inesperado/);
  assert.throws(() => main(['--issues'], saida), /falta valor/);
});

test('CLI roda pelo caminho real e por link simbólico, com exit code certo', (t) => {
  const dir = mkdtempSync(join(tmpdir(), 'manut-cli-'));
  const issues = join(dir, 'issues.json');
  writeFileSync(issues, JSON.stringify(ISSUES));
  const real = execFileSync(process.execPath, [SCRIPT, '--issues', issues], { encoding: 'utf8' });
  assert.equal(JSON.parse(real).resumo.corrigir, 3);

  const link = join(dir, 'link');
  try {
    symlinkSync(dirname(SCRIPT), link, 'junction');
  } catch (e) {
    t.diagnostic(`sem permissão para criar link: ${e.code}`);
    return;
  }
  const pelaLink = execFileSync(process.execPath, [join(link, 'triagem.mjs'), '--issues', issues], { encoding: 'utf8' });
  assert.equal(pelaLink, real);

  const erro = spawnSync(process.execPath, [join(link, 'triagem.mjs'), '--issues', join(dir, 'falta.json')], { encoding: 'utf8' });
  assert.equal(erro.status, 1);
  assert.match(erro.stderr, /não encontrado/);
});

// ── Segunda rodada da revisão ──────────────────────────────────────────────

test('deIssues lê o formato REST paginado (--slurp), tira PRs e usa author_association', () => {
  const paginas = [
    [
      { number: 7, title: 'Botão quebrado', body: '', labels: [{ name: 'bug' }], created_at: '2026-10-01T10:00:00Z', html_url: 'https://h/7', author_association: 'COLLABORATOR', assignees: [] },
      { number: 8, title: 'PR qualquer', labels: [], pull_request: { url: 'x' }, author_association: 'OWNER' },
    ],
    [{ number: 9, title: 'Erro estranho', labels: [], created_at: '2026-10-02T10:00:00Z', html_url: 'https://h/9', author_association: 'NONE' }],
  ];
  assert.deepEqual(deIssues(paginas).map((s) => [s.id, s.confiavel, s.url, s.desde]), [
    ['issue#7', true, 'https://h/7', '2026-10-01T10:00:00Z'],
    ['issue#9', false, 'https://h/9', '2026-10-02T10:00:00Z'],
  ]);
});

test('mascararPII não confunde número de pedido com CPF nem com telefone', () => {
  assert.equal(mascararPII('Pedido 20261008123 falhou'), 'Pedido 20261008123 falhou');
  assert.equal(mascararPII('cpf: 12345678909'), 'cpf: <cpf>');
  assert.equal(mascararPII('ligar 11 98888-7777'), 'ligar <telefone>');
});

test('gate: falsos positivos do domínio não travam; exclusões de dado travam; rótulo libera', () => {
  const issue = (texto, rotulos = []) => ({ id: 'issue#1', texto, rotulos });
  for (const t of [
    'Taxa de retenção no dashboard errada',
    'Campo secretaria some no formulário',
    'Lista mostra leads duplicados',
    'Botão subir foto em produção quebrado',
    'Botão remover lead não funciona',
  ]) assert.equal(precisaGateHumano(issue(t)), false, t);
  for (const t of ['apagar dados do embaixador', 'DELETE leads antigos', 'política de retenção de leads', 'deduplicação de cadastros']) {
    assert.equal(precisaGateHumano(issue(t)), true, t);
  }
  assert.equal(precisaGateHumano(issue('apagar dados do embaixador', [ROTULO_LIBERADO])), false);
  assert.equal(precisaGateHumano(issue('ajuste', ['gate-humano', ROTULO_LIBERADO])), false);
});

test('deRunsCI mantém o id pela âncora quando a sequência passa da janela', () => {
  const runs = (de, ate) => Array.from({ length: ate - de }, (_, k) => ({
    workflowName: 'v',
    conclusion: 'failure',
    headSha: `sha${String(de + k).padStart(4, '0')}`,
    createdAt: new Date(Date.UTC(2026, 9, 1) + (de + k) * 60_000).toISOString(),
  }));
  const primeira = deRunsCI(runs(0, 50));
  assert.equal(primeira[0].id, 'ci:v@sha0000');
  assert.equal(deRunsCI(runs(10, 60), { v: primeira[0].ancora.marco })[0].id, 'ci:v@sha0000');
  assert.equal(deRunsCI(runs(10, 60))[0].id, 'ci:v@sha0010');
  const verde = { workflowName: 'v', conclusion: 'success', headSha: 'ok', createdAt: '2026-09-01T00:00:00Z' };
  assert.equal(deRunsCI([...runs(10, 20), verde], { v: 'velho00' })[0].id, 'ci:v@sha0010');
});

// ── Terceira rodada da revisão ─────────────────────────────────────────────

test('mascararPII pega CPF e celular sem formatação, sem pegar número qualquer', () => {
  assert.equal(
    mascararPII('Lead 52998224725 inválido; tel +5511987654321; 11987654321; pedido 20261008123; 11111111111'),
    'Lead <cpf> inválido; tel <telefone>; <telefone>; pedido 20261008123; 11111111111',
  );
});

test('gate: "excluir minha conta" trava; "titular do cartão" não', () => {
  const issue = (texto) => ({ id: 'issue#1', texto, rotulos: [] });
  assert.equal(precisaGateHumano(issue('excluir minha conta')), true);
  assert.equal(precisaGateHumano(issue('Exclusão a pedido do titular dos dados')), true);
  assert.equal(precisaGateHumano(issue('Titular do cartão não aparece')), false);
});

test('triar: CI escalado não trava o ciclo', () => {
  const ci = deRunsCI([{ workflowName: 'deploy-prd', conclusion: 'startup_failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'abcdef12' }]);
  const { resumo } = triar([...ci, ...deIssues([ISSUES[0]])], { estado: { 'ci:deploy-prd@abcdef1': { tentativas: 2, tratado: 'escalar' } } });
  assert.deepEqual(resumo, { 'ja-tratado': 1, corrigir: 1 });
});

test('deRunsCI: run cancelado no meio não quebra a sequência de falhas', () => {
  const sinais = deRunsCI([
    { workflowName: 'v', conclusion: 'failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'aaaaaaa1' },
    { workflowName: 'v', conclusion: 'cancelled', createdAt: '2026-10-08T11:00:00Z', headSha: 'bbbbbbb2' },
    { workflowName: 'v', conclusion: 'failure', createdAt: '2026-10-08T12:00:00Z', headSha: 'ccccccc3' },
  ]);
  assert.deepEqual(sinais.map((s) => s.id), ['ci:v@aaaaaaa']);
  assert.deepEqual(deRunsCI([{ workflowName: 'v', conclusion: 'cancelled', createdAt: '2026-10-08T11:00:00Z' }]), []);
});

test('triar: CI com PR aberto segura o resto; CI escalado não segura', () => {
  const ci = deRunsCI([{ workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'abcdef12' }]);
  const issue = deIssues([ISSUES[0]]);
  const escalado = triar([...ci, ...issue], { estado: { 'ci:verify@abcdef1': { tentativas: 2 } } });
  assert.deepEqual(escalado.resumo, { corrigir: 1, escalar: 1 });
  const comPr = triar([...ci, ...issue], { prsAbertos: new Map([['ci:verify@abcdef1', 70]]) });
  assert.deepEqual(comPr.resumo, { 'aguardando-revisao': 1, 'proximo-ciclo': 1 });
});

test('triar devolve ramo seguro para worktree e branch, sem a âncora interna', () => {
  const { fila } = triar([
    ...deRunsCI([{ workflowName: 'Verify / build', conclusion: 'failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'abcdef12' }]),
    ...deIssues([ISSUES[0]]),
  ]);
  // issue#31 (01/10) é mais antiga que a falha de CI (08/10): mesma severidade, vem antes.
  assert.deepEqual(fila.map((i) => i.ramo), ['manut/issue-31', 'manut/ci-verify-build-abcdef1']);
  assert.equal('ancora' in fila[0], false);
});

test('conciliar: PR mesclado resolve, PR fechado conta tentativa, PR de outro número não mexe', () => {
  const estado = {
    'issue#31': { tentativas: 1, pr: 41, resolvido: false },
    'issue#35': { tentativas: 0, pr: 42, resolvido: false },
    'issue#36': { pr: 43, resolvido: false },
  };
  const prs = [
    { number: 41, state: 'MERGED', body: 'manutencao-id: issue#31' },
    { number: 42, state: 'CLOSED', body: 'manutencao-id: issue#35' },
    { number: 99, state: 'MERGED', body: 'manutencao-id: issue#36' },
    { number: 44, state: 'OPEN', body: 'manutencao-id: issue#40' },
  ];
  const novo = conciliar(estado, prs, new Date('2026-10-09T00:00:00Z'));
  assert.deepEqual([novo['issue#31'].resolvido, novo['issue#31'].tentativas], [true, 0]);
  assert.deepEqual([novo['issue#35'].tentativas, novo['issue#35'].pr], [1, undefined]);
  assert.equal(novo['issue#36'].pr, 43);
  assert.deepEqual([...idsComPrAberto(prs)], [['issue#40', 44]]);
});

test('registrar tratado só aceita ação conhecida', () => {
  assert.throws(() => registrar({}, 'x', 'tratado', { acao: 'gate-humanoo' }), /exige a ação/);
  assert.equal(registrar({}, 'x', 'tratado', { acao: 'escalar' }).x.tratado, 'escalar');
});

test('expandirHome troca ~/ pela pasta do usuário', () => {
  assert.equal(expandirHome('~/.claude/manutencao/x.json'), join(homedir(), '.claude/manutencao/x.json'));
  assert.equal(expandirHome('C:/a/b.json'), 'C:/a/b.json');
  assert.equal(expandirHome(undefined), undefined);
});

test('main concilia PRs, grava a âncora de CI e apaga a âncora quando o CI volta ao verde', () => {
  const dir = mkdtempSync(join(tmpdir(), 'manut-ancora-'));
  const estado = join(dir, 'estado.json');
  const ci = join(dir, 'ci.json');
  const prs = join(dir, 'prs.json');
  writeFileSync(estado, JSON.stringify({ 'issue#31': { tentativas: 0, pr: 41, resolvido: false } }));
  writeFileSync(ci, JSON.stringify([{ workflowName: 'verify', conclusion: 'failure', createdAt: '2026-10-08T10:00:00Z', headSha: 'abcdef12' }]));
  writeFileSync(prs, JSON.stringify([{ number: 41, state: 'MERGED', body: 'manutencao-id: issue#31' }]));
  main(['--ci', ci, '--prs', prs, '--estado', estado], saidaFalsa());
  let gravado = JSON.parse(readFileSync(estado, 'utf8'));
  assert.equal(gravado['issue#31'].resolvido, true);
  assert.deepEqual(gravado._ancoras_ci, { verify: 'abcdef1' });

  writeFileSync(ci, JSON.stringify([{ workflowName: 'verify', conclusion: 'success', createdAt: '2026-10-09T10:00:00Z', headSha: 'fff' }]));
  main(['--ci', ci, '--estado', estado], saidaFalsa());
  gravado = JSON.parse(readFileSync(estado, 'utf8'));
  assert.equal('_ancoras_ci' in gravado, false);
});
