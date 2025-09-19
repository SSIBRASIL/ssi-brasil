@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ====== SSIBRASIL — Deploy para GitHub Pages (gh-pages) ======
REM Uso: deploy_ghpages.bat <REMOTE_URL> [CNAME_DOMINIO]
REM Ex.: deploy_ghpages.bat https://github.com/SEU_USUARIO/ssibrasil-site.git ssibrasil.com.br

set "SITE_DIR=C:\Users\Lucas\OneDrive\Área de Trabalho\SITE EMPREGOS SSI\04SSIBRASIL_Home_Comercial"
if not "%~1"=="" set "GIT_REMOTE=%~1"
if "%GIT_REMOTE%"=="" set "GIT_REMOTE=https://github.com/SEU_USUARIO/ssibrasil-site.git"
set "CNAME_DOMAIN=%~2"

echo.
echo === Indo para a pasta do site ===
cd /d "%SITE_DIR%" || (echo ERRO: pasta nao encontrada: "%SITE_DIR%" & goto :FIM)
echo Pasta atual: %cd%

echo %cd% | findstr /i "System32" > nul
if %errorlevel%==0 (
  echo ERRO: Nao execute em C:\Windows\System32. Ajuste a pasta e tente novamente.
  goto :FIM
)

if not exist index.html (
  echo ERRO: index.html nao encontrado em %cd%
  goto :FIM
)

REM Arquivo para evitar processamento Jekyll
if not exist .nojekyll echo.>.nojekyll

REM CNAME opcional
if not "%CNAME_DOMAIN%"=="" (
  > CNAME echo %CNAME_DOMAIN%
)

where git >nul 2>nul || (echo ERRO: Git nao encontrado. Instale em https://git-scm.com/download/win & goto :FIM)

REM Inicializa repo se preciso
git rev-parse --is-inside-work-tree >nul 2>nul || git init

REM Configura remote
git remote -v | findstr /i "origin" >nul
if errorlevel 1 (
  git remote add origin "%GIT_REMOTE%"
) else (
  git remote set-url origin "%GIT_REMOTE%"
)

echo.
echo === Publicando em gh-pages ===
REM Cria branch orphan para ter historico limpo de paginas
git checkout --orphan gh-pages 2>nul || git checkout gh-pages
git add -A
git commit -m "deploy: site SSIBRASIL (GitHub Pages)" 2>nul
git push -u origin gh-pages --force

echo.
echo === Concluido ===
echo Ative o GitHub Pages nas configuracoes do repo para a branch ^'gh-pages^'.
echo URL prevista: https://SEU_USUARIO.github.io/REPO/  (ou dominio do CNAME, se configurado)
echo.
pause
:FIM
endlocal
