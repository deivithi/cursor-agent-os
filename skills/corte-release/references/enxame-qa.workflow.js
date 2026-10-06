export const meta = {
  name: 'enxame-qa-corte',
  description: 'Enxame de QA do corte: agentes dirigidos por área + caos em hml, reprodução dos achados graves e consolidação por severidade',
  whenToUse: 'Depois do corte (skill corte-release), com o build do corte publicado em hml',
  phases: [
    { title: 'Explorar', detail: 'um agente por área do mapa + agentes de caos' },
    { title: 'Reproduzir', detail: 'achado CRITICAL/HIGH: reproduz em hml e compara com prd (só leitura)' },
    { title: 'Consolidar', detail: 'deduplica e ordena por severidade' },
  ],
}

// args (JSON de verdade, não string):
// {
//   versao: 'sprint-10', anterior: 'sprint-09',
//   alvo: 'URL de hml', referencia: 'URL de prd (versão anterior)',
//   acesso: 'como abrir sessão de QA em hml (sessão temporária; nunca digitar senha em site publicado)',
//   acessoReferencia: '(opcional) sessão SÓ LEITURA e revogável em prd; sem ela, a comparação com prd é anônima',
//   ferramenta: 'como dirigir o navegador (ex.: Playwright python3 no Zo em /root/qa-indicacoes/)',
//   areas: [{ nome: 'Leads', roteiro: 'o que fazer e o que deve acontecer' }],
//   caos: 2
// }
const A = args || {}
if (!A.alvo || !Array.isArray(A.areas) || A.areas.length === 0) {
  throw new Error('args precisa de alvo e de areas (lista do mapa de funcionalidades)')
}

const SEVERIDADES = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
const ORDEM_SEV = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 }

const ACHADOS = {
  type: 'object',
  properties: {
    achados: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          titulo: { type: 'string' },
          severidade: { type: 'string', enum: SEVERIDADES },
          area: { type: 'string' },
          passos: { type: 'array', items: { type: 'string' } },
          esperado: { type: 'string' },
          obtido: { type: 'string' },
          evidencia: { type: 'string', description: 'caminho do print, trecho de log ou resposta HTTP' },
        },
        required: ['titulo', 'severidade', 'area', 'passos', 'esperado', 'obtido', 'evidencia'],
      },
    },
    cobertura: { type: 'string', description: 'o que foi exercitado e o que ficou de fora, e por quê' },
  },
  required: ['achados', 'cobertura'],
}

const VEREDITO = {
  type: 'object',
  properties: {
    reproduz: { type: 'boolean' },
    origem: { type: 'string', enum: ['regressao', 'pre-existente', 'indeterminada'] },
    severidade: { type: 'string', enum: SEVERIDADES },
    nota: { type: 'string', description: 'o que foi visto em hml e em prd' },
    telaEmPrd: { type: 'boolean', description: 'chegou à MESMA tela/estado em prd antes de comparar' },
  },
  required: ['reproduz', 'origem', 'severidade', 'nota', 'telaEmPrd'],
}

const ORIGENS = ['regressao', 'pre-existente', 'indeterminada', 'nao-verificada']
const CONSOLIDADO = {
  type: 'object',
  properties: {
    itens: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          titulo: { type: 'string' },
          severidade: { type: 'string', enum: SEVERIDADES },
          origem: { type: 'string', enum: ORIGENS },
          areas: { type: 'array', items: { type: 'string' } },
          passos: { type: 'array', items: { type: 'string' } },
          evidencias: { type: 'array', items: { type: 'string' } },
        },
        required: ['titulo', 'severidade', 'origem', 'areas', 'passos', 'evidencias'],
      },
    },
  },
  required: ['itens'],
}

const CONTEXTO =
  `Corte ${A.versao} (anterior: ${A.anterior}). Alvo de teste: ${A.alvo}.\n` +
  `Acesso: ${A.acesso}\nFerramenta: ${A.ferramenta}\n` +
  'Regras: teste e escrita só em hml; em prd, só leitura (anônima ou com a sessão de referência declarada); ' +
  'nunca digitar senha; nenhuma PII real (use massa fictícia); não altere código nem abra PR. ' +
  'Cada achado precisa de evidência real (print, log ou resposta HTTP). Sem evidência, não é achado. ' +
  'Severidade pela data/severity-config.json: CRITICAL bloqueia a operação, HIGH quebra um fluxo do usuário, ' +
  'MEDIUM incomoda com contorno, LOW é cosmético.'

const ACESSO_PRD = A.acessoReferencia
  ? `Sessão de referência em prd (só leitura): ${A.acessoReferencia}`
  : 'Não há sessão em prd: compare só o que abre sem login. Tela de login, captura fechada ou permissão negada em prd NÃO é prova de que o defeito não existe lá.'

const dirigidos = A.areas.map((a) => ({
  label: `area:${a.nome}`,
  prompt:
    `${CONTEXTO}\n\nVocê é um usuário real testando a área "${a.nome}".\nRoteiro:\n${a.roteiro}\n\n` +
    'Siga o roteiro, depois varie: campos vazios, valores no limite, voltar e repetir, duas abas, recarregar no meio. ' +
    'Devolva os achados e a cobertura.',
}))

const nomes = A.areas.map((a) => a.nome).join(', ')
const caos = Array.from({ length: Math.max(0, A.caos ?? 2) }, (_, i) => ({
  label: `caos:${i + 1}`,
  prompt:
    `${CONTEXTO}\n\nVocê é o macaco do caos nº ${i + 1}. Áreas existentes: ${nomes}. ` +
    (i % 2 === 0
      ? 'Clique em ordem aleatória, clique duplo em botão de envio, use voltar/avançar do navegador, abra links em nova aba e cole texto longo e caracteres especiais (acentos, emoji, aspas, <script>).'
      : 'Use tela de celular (390x844), conexão lenta, recarregue durante envio, deixe a sessão ociosa e volte, troque de marca no meio de um fluxo.') +
    ' Devolva só o que quebrou de verdade, com evidência.',
}))

const exploradores = [...dirigidos, ...caos]
log(`${dirigidos.length} agente(s) dirigido(s) + ${caos.length} de caos`)

const promptReproducao = (f) =>
  `${CONTEXTO}\n${ACESSO_PRD}\n\n` +
  `Reproduza este achado em hml (${A.alvo}). Depois repita os mesmos passos em prd (${A.referencia}, versão ${A.anterior}) só com leitura.\n` +
  'Origem: regressao só se você chegou à MESMA tela em prd (telaEmPrd=true) e lá o defeito não acontece; ' +
  'pre-existente se acontece nos dois; indeterminada se não chegou à mesma tela em prd ou se comparar exigiria escrever em prd. ' +
  'Escreva na nota o que viu em cada ambiente.\n' +
  'Seja cético com o achado, mas reproduz=false só quando os passos rodaram até o fim em hml e o resultado foi o esperado. ' +
  'Se você não conseguiu rodar os passos (login, lentidão, tela diferente), reproduz=true e origem=indeterminada: quem decide é o PO.\n\n' +
  JSON.stringify(f, null, 2)

// regressão sem prova de que chegou à mesma tela em prd vira indeterminada
const ajustarVeredito = (v) => (v && v.origem === 'regressao' && !v.telaEmPrd ? { ...v, origem: 'indeterminada' } : v)

const resultados = await pipeline(
  exploradores,
  (e) => agent(e.prompt, { label: e.label, phase: 'Explorar', schema: ACHADOS }),
  async (r, e) => {
    if (!r) return null
    const graves = r.achados.filter((f) => f.severidade === 'CRITICAL' || f.severidade === 'HIGH')
    const vereditos = await parallel(
      graves.map((f) => () =>
        agent(promptReproducao(f), { label: `reproduz:${f.titulo.slice(0, 40)}`, phase: 'Reproduzir', schema: VEREDITO }),
      ),
    )
    // agente de reprodução que falhou não pode apagar um achado grave
    const gravesJulgados = graves.map((f, i) => ({
      ...f,
      veredito: ajustarVeredito(vereditos[i]) || {
        reproduz: true,
        origem: 'nao-verificada',
        severidade: f.severidade,
        nota: 'agente de reprodução falhou',
        telaEmPrd: false,
      },
    }))
    const leves = r.achados.filter((f) => !graves.includes(f)).map((f) => ({ ...f, veredito: null }))
    return { origem: e.label, cobertura: r.cobertura, achados: [...gravesJulgados, ...leves] }
  },
)

const validos = resultados.filter(Boolean)
const perdidos = exploradores.length - validos.length
if (perdidos > 0) log(`${perdidos} explorador(es) não devolveram resultado — cobertura incompleta`)

const todos = validos.flatMap((r) => r.achados)
const brutos = todos.filter((f) => !f.veredito || f.veredito.reproduz)
const gravesNaoReproduzidos = todos
  .filter((f) => f.veredito && !f.veredito.reproduz)
  .map((f) => ({ titulo: f.titulo, severidade: f.severidade, area: f.area, nota: f.veredito.nota }))
const reproducaoFalhou = todos.filter((f) => f.veredito && f.veredito.origem === 'nao-verificada').length
log(
  `${brutos.length} achado(s) após reprodução; ${gravesNaoReproduzidos.length} grave(s) não reproduzido(s) (listados no retorno); ` +
    `${reproducaoFalhou} sem reprodução por falha do agente`,
)

// mesmo formato do consolidador, para o caso de ele falhar
const normalizar = (f) => ({
  titulo: f.titulo,
  severidade: (f.veredito && f.veredito.severidade) || f.severidade,
  origem: f.veredito ? f.veredito.origem : 'nao-verificada',
  areas: [f.area],
  passos: f.passos,
  evidencias: [f.evidencia, f.veredito ? `reprodução: ${f.veredito.nota}` : null].filter(Boolean),
})

phase('Consolidar')
const consolidado = brutos.length
  ? await agent(
      'Deduplique estes achados de QA (mesma causa provável = um item, juntando evidências). ' +
        'Use a severidade e a origem do veredito quando existir; sem veredito, origem=nao-verificada. ' +
        'Itens com a mesma causa e origens diferentes ficam com a origem na ordem regressao > indeterminada > nao-verificada > pre-existente. ' +
        'Ordene CRITICAL, HIGH, MEDIUM, LOW. Não invente achado novo.\n\n' +
        JSON.stringify(brutos, null, 2),
      { label: 'consolidar', phase: 'Consolidar', schema: CONSOLIDADO },
    )
  : { itens: [] }

const consolidacaoFalhou = !consolidado
if (consolidacaoFalhou) log('consolidação falhou: itens devolvidos sem deduplicação')

return {
  versao: A.versao,
  itens: consolidado
    ? consolidado.itens
    : brutos.map(normalizar).sort((a, b) => ORDEM_SEV[a.severidade] - ORDEM_SEV[b.severidade]),
  consolidacaoFalhou,
  gravesNaoReproduzidos,
  reproducaoFalhou,
  cobertura: validos.map((r) => ({ agente: r.origem, cobertura: r.cobertura })),
  exploradoresSemResultado: perdidos,
}
