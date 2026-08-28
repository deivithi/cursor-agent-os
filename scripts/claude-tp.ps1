# claude-tp.ps1 — troca de modelos do gateway Bailian Token Plan no Claude Code.
#
# O `claude` ja usa o Token Plan por padrao (ANTHROPIC_BASE_URL definido em
# ~/.claude/settings.json -> https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic).
# Este script facilita escolher um modelo e consultar o que o plano inclui.
#
# Uso:
#   .\claude-tp.ps1 -List                 # lista o catalogo com status
#   .\claude-tp.ps1 -Plan                 # consulta AO VIVO os modelos incluidos no Token Plan
#   .\claude-tp.ps1                       # abre o claude no modelo padrao
#   .\claude-tp.ps1 qwen3.7-max           # abre o claude com um modelo especifico
#
# Para uso nao-interativo, chame o claude direto:
#   claude --model deepseek-v4-pro -p "sua pergunta"

param(
    [Parameter(Position = 0)][string]$Model,
    [switch]$List,
    [switch]$Plan
)

$AnthropicBase = 'https://token-plan.ap-southeast-1.maas.aliyuncs.com'

# Catalogo de interesse. Status verificado em 2026-07-24.
#   "Unpurchased" = fora do Token Plan atual (GET /v1/models nao lista); requer
#                   contratacao/upgrade do plano no console (nao via chave de API).
#   "400 Model not exist" = nao exposto no modo Anthropic (so OpenAI/DashScope).
$Models = @(
    [pscustomobject]@{ Id = 'qwen3.8-max-preview'; Status = 'OK (padrao)' }
    [pscustomobject]@{ Id = 'qwen3.7-max';         Status = 'OK' }
    [pscustomobject]@{ Id = 'qwen3.7-plus';        Status = 'OK' }
    [pscustomobject]@{ Id = 'qwen3.6-flash';       Status = 'OK (small-fast)' }
    [pscustomobject]@{ Id = 'deepseek-v4-pro';     Status = 'OK' }
    [pscustomobject]@{ Id = 'glm-5.2';             Status = 'OK' }
    [pscustomobject]@{ Id = 'deepseek-v4-flash';   Status = 'Unpurchased (fora do Token Plan)' }
    [pscustomobject]@{ Id = 'kimi-k2.7-code';      Status = 'Unpurchased (fora do Token Plan)' }
    [pscustomobject]@{ Id = 'qwen3.5-omni-plus';   Status = '400 nao exposto no modo Anthropic' }
)

if ($List) {
    Write-Output 'Catalogo de modelos (uso: .\claude-tp.ps1 <modelo>):'
    $Models | ForEach-Object { Write-Output ('  {0,-22} {1}' -f $_.Id, $_.Status) }
    Write-Output ''
    Write-Output 'Ver o que o plano inclui de fato: .\claude-tp.ps1 -Plan'
    return
}

if ($Plan) {
    $key = $env:BAILIAN_TOKEN_PLAN_API_KEY
    if (-not $key) { Write-Output 'BAILIAN_TOKEN_PLAN_API_KEY nao definido no ambiente.'; return }
    try {
        $r = Invoke-RestMethod -Uri "$AnthropicBase/compatible-mode/v1/models" -Headers @{ Authorization = "Bearer $key" } -TimeoutSec 60
        $ids = @($r.data | ForEach-Object { $_.id }) | Sort-Object
        Write-Output ('Modelos incluidos no Token Plan (' + $ids.Count + '):')
        $ids | ForEach-Object { Write-Output ('  ' + $_) }
    }
    catch {
        Write-Output ('Erro ao consultar o plano: ' + $_.Exception.Message)
    }
    return
}

if ($Model) {
    $known = $Models | Where-Object { $_.Id -eq $Model }
    if (-not $known) {
        Write-Warning "Modelo '$Model' nao esta no catalogo; tentando mesmo assim."
    }
    claude --model $Model
}
else {
    claude
}
