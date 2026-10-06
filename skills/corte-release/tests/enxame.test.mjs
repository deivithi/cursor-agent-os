// Roda o script do enxame com agent/parallel/pipeline simulados para conferir a lógica
// de reprodução, de descarte e de consolidação sem gastar agentes de verdade.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const FONTE = readFileSync(fileURLToPath(new URL('../references/enxame-qa.workflow.js', import.meta.url)), 'utf8').replace(
  /^export const meta/m,
  'const meta',
);
const AsyncFunction = Object.getPrototypeOf(async () => {}).constructor;
const rodar = new AsyncFunction('args', 'agent', 'parallel', 'pipeline', 'phase', 'log', FONTE);

const parallel = async (thunks) => Promise.all(thunks.map((t) => t().catch(() => null)));
const pipeline = async (itens, ...etapas) =>
  Promise.all(
    itens.map(async (item, i) => {
      let r = item;
      for (const etapa of etapas) {
        try {
          r = await etapa(r, item, i);
        } catch {
          return null;
        }
      }
      return r;
    }),
  );

const ARGS = {
  versao: 'sprint-10',
  anterior: 'sprint-09',
  alvo: 'https://hml',
  referencia: 'https://prd',
  acesso: 'sessão de QA',
  ferramenta: 'playwright',
  areas: [{ nome: 'Leads', roteiro: 'filtrar' }],
  caos: 1,
};

const achado = (titulo, severidade) => ({
  titulo,
  severidade,
  area: 'Leads',
  passos: ['abrir'],
  esperado: 'ok',
  obtido: 'erro',
  evidencia: 'print.png',
});

function montar({ reproducao, consolidar }) {
  const chamadas = [];
  const agent = async (prompt, opts) => {
    chamadas.push(opts.label);
    if (opts.label === 'area:Leads') {
      return {
        achados: [achado('A falha reprodução', 'CRITICAL'), achado('B regressão sem prova', 'HIGH'), achado('C não reproduz', 'HIGH'), achado('D leve', 'LOW')],
        cobertura: 'leads',
      };
    }
    if (opts.label === 'caos:1') return null;
    if (opts.label.startsWith('reproduz:')) return reproducao(opts.label.slice('reproduz:'.length));
    if (opts.label === 'consolidar') return consolidar();
    throw new Error(`label inesperado ${opts.label}`);
  };
  return { agent, chamadas, logs: [] };
}

const REPRODUCAO = (titulo) => {
  if (titulo.startsWith('A')) throw new Error('agente morreu');
  if (titulo.startsWith('B')) return { reproduz: true, origem: 'regressao', severidade: 'HIGH', nota: 'prd pediu login', telaEmPrd: false };
  return { reproduz: false, origem: 'indeterminada', severidade: 'HIGH', nota: 'rodou e deu certo', telaEmPrd: true };
};

test('consolidação falha: grave sem reprodução fica, regressão sem prova vira indeterminada, não reproduzido é listado', async () => {
  const m = montar({ reproducao: REPRODUCAO, consolidar: () => null });
  const r = await rodar(ARGS, m.agent, parallel, pipeline, () => {}, (l) => m.logs.push(l));

  assert.equal(r.consolidacaoFalhou, true);
  assert.equal(r.exploradoresSemResultado, 1);
  assert.equal(r.reproducaoFalhou, 1);
  assert.deepEqual(r.gravesNaoReproduzidos.map((g) => g.titulo), ['C não reproduz']);

  assert.deepEqual(r.itens.map((i) => i.titulo), ['A falha reprodução', 'B regressão sem prova', 'D leve']);
  const [a, b, d] = r.itens;
  assert.equal(a.origem, 'nao-verificada');
  assert.equal(a.severidade, 'CRITICAL');
  assert.equal(b.origem, 'indeterminada');
  assert.equal(d.origem, 'nao-verificada');
  for (const item of r.itens) assert.deepEqual(Object.keys(item).sort(), ['areas', 'evidencias', 'origem', 'passos', 'severidade', 'titulo']);
  assert.ok(m.logs.some((l) => /consolidação falhou/.test(l)));
  assert.ok(m.logs.some((l) => /cobertura incompleta/.test(l)));
});

test('consolidação ok devolve os itens do consolidador', async () => {
  const itens = [{ titulo: 'X', severidade: 'HIGH', origem: 'regressao', areas: ['Leads'], passos: ['a'], evidencias: ['p'] }];
  const m = montar({ reproducao: REPRODUCAO, consolidar: () => ({ itens }) });
  const r = await rodar(ARGS, m.agent, parallel, pipeline, () => {}, () => {});
  assert.equal(r.consolidacaoFalhou, false);
  assert.deepEqual(r.itens, itens);
  assert.equal(m.chamadas.filter((c) => c.startsWith('reproduz:')).length, 3);
});

test('sem achados não chama o consolidador', async () => {
  const chamadas = [];
  const agent = async (_p, opts) => {
    chamadas.push(opts.label);
    return { achados: [], cobertura: 'tudo' };
  };
  const r = await rodar(ARGS, agent, parallel, pipeline, () => {}, () => {});
  assert.deepEqual(r.itens, []);
  assert.equal(r.consolidacaoFalhou, false);
  assert.ok(!chamadas.includes('consolidar'));
});

test('args sem áreas falham cedo', async () => {
  await assert.rejects(() => rodar({ alvo: 'x', areas: [] }, async () => null, parallel, pipeline, () => {}, () => {}), /precisa de alvo e de areas/);
});

test('mapa da Indicações é JSON válido e cabe no limite de 10 exploradores', () => {
  const mapa = JSON.parse(readFileSync(fileURLToPath(new URL('../references/mapa-indicacoes.json', import.meta.url)), 'utf8'));
  assert.ok(mapa.areas.length + mapa.caos <= 10);
  for (const a of mapa.areas) assert.ok(a.nome && a.roteiro.length > 50);
  assert.doesNotMatch(JSON.stringify(mapa), /senha\s*[:=]/i);
});
