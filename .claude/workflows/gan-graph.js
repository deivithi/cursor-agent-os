export const meta = {
  name: 'gan-graph',
  description: 'Grafo worker→reviewer→evaluator (GAN Loop) com loop até convergência',
  whenToUse: 'Task de implementação que exige verificação independente: worker implementa, reviewer cego revisa, evaluator julga produto + audita o review. Itera até PASS, estagnação ou maxRounds.',
  phases: [
    { title: 'Plan', detail: 'planner expande task em spec (pulado se args.spec)' },
    { title: 'Generate', detail: 'worker implementa (agents/worker.md)' },
    { title: 'Review', detail: 'reviewer cego adversarial (agents/reviewer.md)' },
    { title: 'Evaluate', detail: 'evaluator julga produto + audita review (agents/evaluator.md)' },
  ],
}

// ── Config (args) ────────────────────────────────────────────────────────────
// args pode chegar como objeto ou como string JSON dependendo do invocador
let A = args
if (typeof A === 'string') {
  try { A = JSON.parse(A) } catch (e) { throw new Error('args chegou como string não-JSON: ' + A.slice(0, 200)) }
}
const cfg = {
  task: A && A.task,
  spec: (A && A.spec) || null,
  maxRounds: (A && A.maxRounds) || 3,
  scoreMin: (A && A.scoreMin) || 7.0,
  blockSeverities: (A && A.blockSeverities) || ['CRITICAL', 'HIGH'],
  reviewerModel: (A && A.reviewerModel) || null,
  evaluatorModel: (A && A.evaluatorModel) || null,
  agentsDir: (A && A.agentsDir) || 'C:/Users/deivithi.lopes/Documents/Cursor/agents',
  workDir: (A && A.workDir) || null,
}
if (!cfg.task) throw new Error('args.task obrigatório — ex: Workflow({name:"gan-graph", args:{task:"implementar X"}})')

const scopeLine = cfg.workDir
  ? `Escopo de arquivos: trabalhe APENAS dentro de ${cfg.workDir}. Não toque em nada fora desse diretório.`
  : ''

// ── Schemas ──────────────────────────────────────────────────────────────────
const SEVERITIES = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO']

const SPEC_SCHEMA = {
  type: 'object',
  properties: {
    features: {
      type: 'array',
      items: {
        type: 'object',
        properties: { name: { type: 'string' }, acceptance: { type: 'string' } },
        required: ['name', 'acceptance'],
      },
    },
    stack: { type: 'string' },
    notes: { type: 'string' },
  },
  required: ['features'],
}

const WORK_SCHEMA = {
  type: 'object',
  properties: {
    summary: { type: 'string', description: 'O que foi feito + como foi verificado (comandos/testes rodados)' },
    files_changed: { type: 'array', items: { type: 'string' } },
    blocked: { type: 'boolean', description: 'true se a task exige decisão arquitetural humana (cripto/LGPD/sanitização BD/destrutivo)' },
    blocked_reason: { type: 'string' },
  },
  required: ['summary', 'files_changed', 'blocked'],
}

const FINDINGS_SCHEMA = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          severity: { type: 'string', enum: SEVERITIES },
          title: { type: 'string' },
          file: { type: 'string' },
          line: { type: 'number' },
          problem: { type: 'string' },
          fix: { type: 'string' },
        },
        required: ['severity', 'title', 'file', 'problem', 'fix'],
      },
    },
  },
  required: ['findings'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    score: { type: 'number', description: 'Weighted total 1-10 conforme rubrica do evaluator.md' },
    verdict: { type: 'string', enum: ['PASS', 'CONDITIONAL', 'FAIL'] },
    review_audit: {
      type: 'object',
      properties: {
        missed_issues: { type: 'array', items: { type: 'string' }, description: 'Issues reais que o reviewer deixou passar' },
        review_quality: { type: 'string', enum: ['good', 'weak'] },
      },
      required: ['missed_issues', 'review_quality'],
    },
    required_fixes: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          severity: { type: 'string', enum: SEVERITIES },
          description: { type: 'string' },
        },
        required: ['severity', 'description'],
      },
    },
  },
  required: ['score', 'verdict', 'review_audit', 'required_fixes'],
}

// ── Fase 1: Plan (opcional) ──────────────────────────────────────────────────
phase('Plan')
let spec = cfg.spec
if (!spec) {
  spec = await agent(
    `Read ${cfg.agentsDir}/planner.md and adopt that role exactly (read-only, exploração).

Expanda a task abaixo em um spec completo: features com critérios de aceitação verificáveis, stack recomendada, notas de design de alto nível (não granular — evite cascading errors).

Task: ${cfg.task}
${scopeLine}`,
    { label: 'planner', phase: 'Plan', schema: SPEC_SCHEMA }
  )
  if (!spec) throw new Error('Planner falhou — sem spec não há grafo')
} else {
  log('Spec fornecido via args — fase Plan pulada')
}

// ── Loop GAN: Generate → Review (cego) → Evaluate ────────────────────────────
const history = []
let pendingFixes = []
let prevOpen = Infinity
let stagnantRounds = 0
let finalStatus = 'MAX_ROUNDS'
let lastVerdict = null
let blockedReason = null

for (let round = 1; round <= cfg.maxRounds; round++) {
  // 1) Generate — worker
  const fixesBlock = pendingFixes.length
    ? `\nFixes obrigatórios do round anterior (corrija TODOS antes de qualquer coisa nova):\n${pendingFixes.map(f => `- [${f.severity}] ${f.description}`).join('\n')}`
    : ''
  const work = await agent(
    `Read ${cfg.agentsDir}/worker.md and adopt that role exactly.

Task: ${cfg.task}
${scopeLine}

Spec (implemente as features abaixo, uma por vez):
${JSON.stringify(spec, null, 2)}
${fixesBlock}

Regras:
- Implemente e VERIFIQUE antes de retornar (rode os testes/comandos relevantes).
- Se a task exigir criptografia, regra LGPD, sanitização de BD ou operação destrutiva (DROP/TRUNCATE/DELETE em massa/rm -rf), NÃO execute essa parte: retorne blocked=true com blocked_reason descrevendo a decisão arquitetural pendente (human-architectural-gate).
- summary deve dizer o que foi feito E como foi verificado.`,
    { label: `generate:r${round}`, phase: 'Generate', schema: WORK_SCHEMA }
  )
  if (!work) { finalStatus = 'AGENT_ERROR'; break }
  if (work.blocked) {
    finalStatus = 'BLOCKED'
    blockedReason = work.blocked_reason || 'worker sinalizou gate humano sem detalhar'
    log(`round ${round}: BLOCKED — ${blockedReason}`)
    break
  }

  // 2) Review — CEGO: recebe só o spec; inspeciona o repo por conta própria
  const reviewOpts = { label: `review:r${round}`, phase: 'Review', schema: FINDINGS_SCHEMA }
  if (cfg.reviewerModel) reviewOpts.model = cfg.reviewerModel
  const review = await agent(
    `Read ${cfg.agentsDir}/reviewer.md and adopt that role exactly.

Você é um revisor CEGO: não recebeu nenhum contexto de como o trabalho foi feito — apenas o spec abaixo. Inspecione o estado atual do repositório por conta própria (git status, git diff, leia os arquivos modificados${cfg.workDir ? ` em ${cfg.workDir}` : ''}).

Spec contra o qual revisar:
${JSON.stringify(spec, null, 2)}

Seja adversarial: procure bugs, falhas de segurança, edge cases, violações do spec, testes enfraquecidos/deletados/skipados (test-integrity). Severidades conforme data/severity-config.json (CRITICAL bloqueia deploy … INFO observação). Cada finding com file/line/problem/fix. Se nada encontrado, retorne findings=[].`,
    reviewOpts
  )
  if (!review) { finalStatus = 'AGENT_ERROR'; break }
  const findings = review.findings || []

  // 3) Evaluate — julga o produto E audita o review
  const evalOpts = { label: `evaluate:r${round}`, phase: 'Evaluate', schema: VERDICT_SCHEMA }
  if (cfg.evaluatorModel) evalOpts.model = cfg.evaluatorModel
  const verdict = await agent(
    `Read ${cfg.agentsDir}/evaluator.md and adopt that role exactly. Você NÃO gerou este código — é um auditor independente. Default: rejeição até provar que funciona.

Spec:
${JSON.stringify(spec, null, 2)}

Resumo do worker (round ${round}/${cfg.maxRounds}): ${work.summary}
Arquivos alterados: ${JSON.stringify(work.files_changed)}

Findings do reviewer:
${JSON.stringify(findings, null, 2)}

Três deveres:
1. VERIFICAR o trabalho: aplique a rubrica ponderada do evaluator.md (tabela "Code Changes" salvo se for app/UI completa). Teste de verdade quando possível — rode os testes/comandos, não apenas leia o código. Score 1-10.
2. AUDITAR o review: faça spot-check do código você mesmo — o reviewer deixou passar issues reais? Liste em review_audit.missed_issues e classifique review_quality (good|weak). Todo issue perdido pelo reviewer DEVE entrar também em required_fixes com severidade própria.
3. VEREDICTO: PASS (score ≥ ${cfg.scoreMin} e zero ${cfg.blockSeverities.join('/')} aberto) | CONDITIONAL | FAIL. required_fixes = lista consolidada (findings válidos do reviewer + os seus) com severity. Descarte findings do reviewer que você verificou serem falsos positivos.`,
    evalOpts
  )
  if (!verdict) { finalStatus = 'AGENT_ERROR'; break }
  lastVerdict = verdict

  const openBlocking = verdict.required_fixes.filter(f => cfg.blockSeverities.includes(f.severity))
  const openTotal = verdict.required_fixes.length
  history.push({
    round,
    findings: findings.length,
    score: verdict.score,
    verdict: verdict.verdict,
    openBlocking: openBlocking.length,
    openTotal,
    reviewQuality: verdict.review_audit.review_quality,
    reviewerMissed: verdict.review_audit.missed_issues.length,
  })
  log(`round ${round}: ${findings.length} findings, score ${verdict.score}, verdict ${verdict.verdict}, ${openBlocking.length} blocking fixes, review ${verdict.review_audit.review_quality}`)

  // Convergência (gan-loop.md: score ≥ min, zero CRITICAL/HIGH, PASS)
  if (verdict.verdict === 'PASS' && verdict.score >= cfg.scoreMin && openBlocking.length === 0) {
    finalStatus = 'PASS'
    break
  }

  // Guarda de estagnação (adaptive-depth): 2 rounds consecutivos sem redução de issues abertos
  if (openTotal >= prevOpen) { stagnantRounds++ } else { stagnantRounds = 0 }
  prevOpen = openTotal
  if (stagnantRounds >= 2) {
    finalStatus = 'STAGNATION'
    log(`Stagnation: 2 rounds sem redução de issues abertos (${openTotal}) — saindo p/ replanejamento humano`)
    break
  }

  pendingFixes = verdict.required_fixes
}

// ── Relatório final ──────────────────────────────────────────────────────────
return {
  status: finalStatus,
  rounds: history.length,
  finalScore: lastVerdict ? lastVerdict.score : null,
  finalVerdict: lastVerdict ? lastVerdict.verdict : null,
  history,
  openFindings: lastVerdict ? lastVerdict.required_fixes : [],
  reviewAudit: lastVerdict ? lastVerdict.review_audit : null,
  blockedReason,
  spec,
}
