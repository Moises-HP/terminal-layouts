@echo off
REM install.cmd — instalador de DOBLE CLIC (Windows). Instala lo que falte (Git,
REM Node, Windows Terminal) con winget y luego corre install.sh con Git Bash.
setlocal EnableDelayedExpansion
echo.
echo  == Instalador de terminal-layouts ==
echo.

REM --- localizar Git Bash ---
set "GITBASH="
for %%D in ("%ProgramFiles%\Git" "%ProgramFiles(x86)%\Git" "%LocalAppData%\Programs\Git") do (
  if exist "%%~D\bin\bash.exe" if not defined GITBASH set "GITBASH=%%~D\bin\bash.exe"
)
REM Derivar desde git.exe en PATH (instalaciones no estandar)
if not defined GITBASH (
  for /f "delims=" %%G in ('where git.exe 2^>nul') do (
    set "_GD=%%~dpG"
    if exist "!_GD!..\bin\bash.exe" if not defined GITBASH set "GITBASH=!_GD!..\bin\bash.exe"
    if exist "!_GD!..\..\bin\bash.exe" if not defined GITBASH set "GITBASH=!_GD!..\..\bin\bash.exe"
    if exist "!_GD!..\..\..\bin\bash.exe" if not defined GITBASH set "GITBASH=!_GD!..\..\..\bin\bash.exe"
  )
)

REM --- ¿faltan cosas? intentar instalarlas con winget ---
where winget >nul 2>&1
if %errorlevel%==0 (
  set "WINGET=1"
) else (
  set "WINGET=0"
)

if not defined GITBASH (
  echo  [*] Git para Windows no esta instalado.
  if "!WINGET!"=="1" (
    echo      Instalando Git con winget...
    winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
    REM re-localizar tras instalar
    for %%D in ("%ProgramFiles%\Git" "%LocalAppData%\Programs\Git") do (
      if exist "%%~D\bin\bash.exe" if not defined GITBASH set "GITBASH=%%~D\bin\bash.exe"
    )
  ) else (
    echo      No tienes winget. Instala Git manualmente: https://git-scm.com/download/win
  )
)

REM --- Node (lo instala winget; si no, avisa. install.sh vuelve a checar) ---
where node >nul 2>&1
if not %errorlevel%==0 (
  echo  [*] Node.js no esta instalado.
  if "!WINGET!"=="1" (
    echo      Instalando Node.js LTS con winget...
    winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-source-agreements --accept-package-agreements
  ) else (
    echo      No tienes winget. Instala Node manualmente: https://nodejs.org
  )
)

REM --- Windows Terminal (recomendado) ---
where wt >nul 2>&1
if not %errorlevel%==0 (
  if "!WINGET!"=="1" (
    echo  [*] Instalando Windows Terminal con winget...
    winget install --id Microsoft.WindowsTerminal -e --source winget --accept-source-agreements --accept-package-agreements
  ) else (
    echo  [!] Falta Windows Terminal ^(instalalo desde Microsoft Store^).
  )
)

echo.
if not defined GITBASH (
  echo  [X] Aun no encuentro Git Bash. Si acabas de instalarlo, CIERRA esta ventana y
  echo      vuelve a hacer doble clic en install.cmd ^(a veces requiere reabrir^).
  echo      Descarga manual: https://git-scm.com/download/win
  echo.
  pause
  exit /b 1
)

echo  [*] Ejecutando la configuracion...
echo.
"%GITBASH%" -l "%~dp0install.sh"
echo.
echo  Listo. Abre una terminal NUEVA de Windows Terminal y prueba:  lay -h
echo.
pause
