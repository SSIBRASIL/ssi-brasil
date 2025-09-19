@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM  SSIBRASIL — Sincronizar ZIP/DIR -> Projeto e Fazer Deploy
REM  Uso:
REM    sync_deploy_ssibrasil.bat [FONTE] [DEPLOY] [ALVO] [EXTRA]
REM
REM  Exemplos:
REM    sync_deploy_ssibrasil.bat "C:\Users\Lucas\Downloads\SSIBRASIL_Home_Comercial.zip" docs https://github.com/USER/REPO.git ssibrasil.com.br
REM    sync_deploy_ssibrasil.bat https://minha-url.com/site.zip ghpages https://github.com/USER/REPO.git
REM    sync_deploy_ssibrasil.bat "D:\meu-site\" vercel
REM    sync_deploy_ssibrasil.bat "C:\site.zip" s3 NOME_DO_BUCKET E123ABC456DEF
REM
REM  DEPLOY: docs | ghpages | vercel | s3
REM    docs    -> GitHub Pages via /docs na branch main
REM    ghpages -> GitHub Pages via branch gh-pages
REM    vercel  -> Vercel (produção)
REM    s3      -> AWS S3 (+ CloudFront se EXTRA = DistributionId)
REM ============================================================

set "PROJECT_DIR=C:\Users\Lucas\OneDrive\Área de Trabalho\SITE EMPREGOS SSI\04SSIBRASIL_Home_Comercial"
set "SOURCE=%~1"
set "DEPLOY=%~2"
set "TARGET=%~3"
set "EXTRA=%~4"

if "%DEPLOY%"=="" set "DEPLOY=docs"

echo.
echo === Pasta do projeto ===
echo %PROJECT_DIR%

if not exist "%PROJECT_DIR%" (
  mkdir "%PROJECT_DIR%" || (echo ERRO: Nao foi possivel criar a pasta do projeto. & goto :FIM)
)

echo %cd% | findstr /i "System32" > nul
if %errorlevel%==0 (
  echo ERRO: Nao execute dentro de C:\Windows\System32. Clique duas vezes no arquivo.
  goto :FIM
)

REM ---------- Preparar fonte (URL/ZIP/DIR) ----------
set "WORK=%TEMP%\ssibrasil_sync"
set "SRC=%WORK%\src"
set "ZIPFILE=%WORK%\site.zip"
if exist "%WORK%" rmdir /s /q "%WORK%"
mkdir "%SRC%" >nul 2>nul

if "%SOURCE%"=="" (
  REM Procura um ZIP com nome padrao ao lado do .bat
  set "SOURCE=%~dp0SSIBRASIL_Home_Comercial.zip"
)

echo.
echo === Detectando origem ===
echo Fonte: %SOURCE%

set "LOWER_SRC=%SOURCE:"=%"
set "LOWER_SRC=!LOWER_SRC: =!"
set "LOWER_SRC=!LOWER_SRC:""=!"
set "LOWER_SRC=!LOWER_SRC:.ZIP=.zip!"

REM URL?
echo %SOURCE% | findstr /i "^http.*://" >nul
if not errorlevel 1 (
  echo Baixando via PowerShell...
  powershell -NoLogo -NoProfile -Command "Invoke-WebRequest -Uri '%SOURCE%' -OutFile '%ZIPFILE%'"
  if errorlevel 1 (echo ERRO ao baixar. & goto :FIM)
  powershell -NoLogo -NoProfile -Command "Expand-Archive -LiteralPath '%ZIPFILE%' -DestinationPath '%SRC%' -Force"
  if errorlevel 1 (echo ERRO ao extrair ZIP baixado. & goto :FIM)
  goto :SYNC
)

REM ZIP local?
echo %SOURCE% | findstr /i "\.zip$" >nul
if %errorlevel%==0 (
  echo Extraindo ZIP local...
  powershell -NoLogo -NoProfile -Command "Expand-Archive -LiteralPath '%SOURCE%' -DestinationPath '%SRC%' -Force"
  if errorlevel 1 (echo ERRO ao extrair ZIP local. & goto :FIM)
  goto :SYNC
)

REM Diretorio local?
if exist "%SOURCE%\" (
  echo Copiando de diretorio local...
  robocopy "%SOURCE%" "%SRC%" /MIR >nul
  if errorlevel 8 (echo ERRO no robocopy. & goto :FIM)
  goto :SYNC
)

echo ERRO: Fonte nao encontrada. Informe URL, caminho .zip ou diretorio.
goto :FIM

:SYNC
echo.
echo === Espelhando conteudo no projeto (preservando .git) ===
REM espelha SRC -> PROJECT_DIR preservando .git e pastas sensiveis
robocopy "%SRC%" "%PROJECT_DIR%" /MIR /XD ".git" ".vercel" /XF "*.bat" >nul
if errorlevel 8 (echo ERRO no robocopy. & goto :FIM)

REM ---------- Acoes de deploy ----------
if /I "%DEPLOY%"=="docs" goto :DEPLOY_DOCS
if /I "%DEPLOY%"=="ghpages" goto :DEPLOY_GHPAGES
if /I "%DEPLOY%"=="vercel" goto :DEPLOY_VERCEL
if /I "%DEPLOY%"=="s3" goto :DEPLOY_S3

echo AVISO: Metodo de deploy desconhecido: %DEPLOY%
goto :FIM

:DEPLOY_DOCS
echo.
echo === Deploy GitHub Pages (main/docs) ===
if "%TARGET%"=="" set "TARGET=https://github.com/SEU_USUARIO/ssibrasil-site.git"
cd /d "%PROJECT_DIR%"
if not exist docs mkdir docs
robocopy "%SRC%" "%PROJECT_DIR%\docs" /MIR /XD ".git" ".vercel" >nul
type nul > "%PROJECT_DIR%\docs\.nojekyll"
if not "%EXTRA%"=="" ( > "%PROJECT_DIR%\docs\CNAME" echo %EXTRA% )

where git >nul 2>nul || (echo ERRO: Git nao encontrado. Instale de https://git-scm.com/download/win & goto :FIM)
git rev-parse --is-inside-work-tree >nul 2>nul || git init
git remote -v | findstr /i "origin" >nul
if errorlevel 1 ( git remote add origin "%TARGET%" ) else ( git remote set-url origin "%TARGET%" )
git add -A
git commit -m "deploy: site SSIBRASIL em /docs" 2>nul
git branch -M main
git push -u origin main --force
echo Pronto. Ative Pages: Settings > Pages > Branch: main / docs
goto :FIM

:DEPLOY_GHPAGES
echo.
echo === Deploy GitHub Pages (branch gh-pages) ===
if "%TARGET%"=="" set "TARGET=https://github.com/SEU_USUARIO/ssibrasil-site.git"
cd /d "%PROJECT_DIR%"
type nul > ".nojekyll"
if not "%EXTRA%"=="" ( > "CNAME" echo %EXTRA% )

where git >nul 2>nul || (echo ERRO: Git nao encontrado. Instale de https://git-scm.com/download/win & goto :FIM)
git rev-parse --is-inside-work-tree >nul 2>nul || git init
git remote -v | findstr /i "origin" >nul
if errorlevel 1 ( git remote add origin "%TARGET%" ) else ( git remote set-url origin "%TARGET%" )
git checkout --orphan gh-pages 2>nul || git checkout gh-pages
git add -A
git commit -m "deploy: site SSIBRASIL (gh-pages)" 2>nul
git push -u origin gh-pages --force
echo Pronto. Ative Pages: Settings > Pages > Branch: gh-pages
goto :FIM

:DEPLOY_VERCEL
echo.
echo === Deploy Vercel (prod) ===
cd /d "%PROJECT_DIR%"
where vercel >nul 2>nul || (
  echo Vercel CLI nao encontrado. Tentando instalar via NPM...
  where npm >nul 2>nul || (echo ERRO: NPM nao encontrado. Instale Node.js em https://nodejs.org & goto :FIM)
  npm install -g vercel
)
vercel --prod --yes
goto :FIM

:DEPLOY_S3
echo.
echo === Deploy S3 (opcional CloudFront) ===
if "%TARGET%"=="" (
  echo Uso: %~nx0 ^<FONTE^> s3 ^<BUCKET^> [DISTRIBUTION_ID]
  goto :FIM
)
cd /d "%PROJECT_DIR%"
where aws >nul 2>nul || (echo ERRO: AWS CLI nao encontrado. Instale em https://aws.amazon.com/cli/ e rode 'aws configure'. & goto :FIM)
aws s3 sync "%PROJECT_DIR%" "s3://%TARGET%/" --delete --acl public-read --cache-control "public, max-age=3600"
if not "%EXTRA%"=="" (
  aws cloudfront create-invalidation --distribution-id %EXTRA% --paths "/*"
)
echo Publicado no bucket: %TARGET%
goto :FIM

:FIM
echo.
echo === Fim do processo ===
pause
endlocal
