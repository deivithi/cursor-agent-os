@echo off
setlocal
cd /d "%~dp0"

echo ========================================
echo  Reparo de Hooks - Febracis / Deivithi
echo ========================================
echo.

where node >nul 2>&1
if errorlevel 1 (
  echo [ERRO] Node.js nao encontrado no PATH.
  exit /b 1
)

echo [1/4] Verificacao inicial...
node "%~dp0hook-healthcheck.js" --check
if errorlevel 1 (
  echo.
  echo Problemas detectados. Continuando com dry-run...
)

echo.
echo [2/4] Dry-run (simulacao)...
node "%~dp0hook-healthcheck.js" --fix --dry-run

echo.
echo [3/4] Aplicando correcoes idempotentes...
node "%~dp0hook-healthcheck.js" --fix
set FIX_EXIT=%ERRORLEVEL%

echo.
echo [4/4] Verificacao pos-reparo...
node "%~dp0hook-healthcheck.js" --check
set CHECK_EXIT=%ERRORLEVEL%

echo.
echo Relatorio: %USERPROFILE%\.cursor\hook-health-report.json
echo.
if %FIX_EXIT% neq 0 (
  echo [AVISO] Reparo retornou codigo %FIX_EXIT%.
)
if %CHECK_EXIT% neq 0 (
  echo [ERRO] Verificacao final falhou. Revise o relatorio e recarregue o Cursor.
  exit /b 1
)

echo [OK] Hooks saudaveis. Recarregue o Cursor para aplicar.
exit /b 0
