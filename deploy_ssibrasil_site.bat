@echo off
setlocal EnableDelayedExpansion

echo ==================================================
echo   SSIBRASIL - Deploy do Site (GitHub + Vercel)
echo ==================================================

REM 1) Ir para a pasta do script
cd /d %~dp0
set CURRDIR=%cd%
echo Pasta atual: %CURRDIR%

REM 2) Protecao: nao rodar em System32
echo %CURRDIR% | findstr /i "System32" > nul
if %errorlevel%==0 (
  echo.
  echo ERRO: Nao execute este script dentro de C:\Windows\System32.
  echo Mova o arquivo .bat para a pasta do seu projeto (onde fica o index.html) e execute novamente.
  goto :FIM
)

REM 3) Checar arquivos essenciais
if not exist index.html (
  echo.
  echo ERRO: index.html nao encontrado na pasta atual.
  echo Coloque o index.html (e pastas do site) nesta pasta e rode novamente.
  goto :FIM
)

REM 4) Criar ignores (opcional) para Vercel/Git
if not exist .vercelignore (
  (
    echo node_modules/
    echo .vercel/
    echo .DS_Store
    echo Thumbs.db
  ) > .vercelignore
)
if not exist .gitignore (
  (
    echo node_modules/
    echo .vercel/
    echo .env
    echo .DS_Store
    echo Thumbs.db
  ) > .gitignore
)

REM 5) Checar GIT
where git >nul 2>nul
if errorlevel 1 (
  echo.
  echo ERRO: Git nao encontrado. Instale o Git e tente novamente: https://git-scm.com/download/win
  goto :DEPLOY_VERCEL
)

REM 6) Inicializar repositorio se preciso
git rev-parse --is-inside-work-tree >nul 2>nul
if errorlevel 1 (
  echo.
  echo === Inicializando repositorio Git ===
  git init
)

REM 7) Definir remote (pode passar a URL como primeiro argumento do .bat)
set "GIT_REMOTE=%~1"
if "%GIT_REMOTE%"=="" set "GIT_REMOTE=git@github.com:SEU_USUARIO/ssibrasil-site.git"

git remote -v | findstr /i "origin" >nul
if errorlevel 1 (
  git remote add origin "%GIT_REMOTE%"
) else (
  git remote set-url origin "%GIT_REMOTE%"
)

REM 8) Commit e push
echo.
echo === Commit e Push (main) ===
git add -A
git commit -m "deploy: ssibrasil site" 2>nul
git branch -M main
git push -u origin main --force
if errorlevel 1 (
  echo AVISO: Nao foi possivel enviar ao GitHub. Verifique a URL remota e suas credenciais SSH/HTTPS.
)

:DEPLOY_VERCEL
REM 9) Vercel CLI
echo.
echo === Deploy com Vercel ===
where vercel >nul 2>nul
if errorlevel 1 (
  echo Vercel CLI nao encontrado. Tentando instalar via NPM...
  where npm >nul 2>nul
  if errorlevel 1 (
    echo ERRO: NPM nao encontrado. Instale Node.js (https://nodejs.org/) ou instale o Vercel CLI manualmente.
    goto :FIM
  )
  npm install -g vercel
)

vercel --version >nul 2>nul
if errorlevel 1 (
  echo ERRO: Vercel CLI nao disponivel. Tente abrir um novo terminal ou rodar ^"vercel login^" manualmente.
  goto :FIM
)

echo.
echo Caso seja seu primeiro deploy, execute no cmd (uma unica vez):  vercel login
echo Opcionalmente defina variaveis:  set VERCEL_ORG_ID=...  e  set VERCEL_PROJECT_ID=...
echo.

REM Deploy nao interativo (usa projeto atual); remova --yes se desejar confirmar
vercel --prod --yes

echo.
echo === Concluido ===
echo Se apareceu a URL final no console, seu site ja esta no ar.
echo Para repetir: basta re-rodar este .bat apos atualizar o index.html
echo.
pause

:FIM
endlocal
