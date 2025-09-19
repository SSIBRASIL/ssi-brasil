@echo off
setlocal

echo Verificando pasta atual...
cd /d %~dp0
set CURRDIR=%cd%
echo Local atual: %CURRDIR%

REM Verifica se estamos na pasta System32 (erro comum)
echo %CURRDIR% | findstr /i "System32" > nul
if %errorlevel%==0 (
    echo.
    echo ERRO: Este script nao deve ser executado dentro de C:\Windows\System32.
    echo Por favor, mova o script para a pasta correta do seu projeto e execute novamente.
    pause
    exit /b
)

echo.
echo === Inicializando repositorio Git ===
git init

echo.
echo === Adicionando arquivos ===
git add .

echo.
echo === Commitando alteracoes ===
git commit -m "Deploy automático do projeto SSI BRASIL"

echo.
echo === Adicionando origem remota ===
git remote remove origin 2>nul
git remote add origin https://github.com/SSIBRASIL/SSI-BRASIL.git

echo.
echo === Alterando branch para main ===
git branch -M main

echo.
echo === Enviando para GitHub ===
git push -u origin main --force

echo.
echo === Fazendo deploy com Vercel ===
vercel --prod

echo.
echo === Concluído com sucesso ===
pause
endlocal
