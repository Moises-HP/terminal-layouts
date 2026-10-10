@echo off
REM _run.cmd — encuentra Git Bash automaticamente y ejecuta open.sh con los layouts dados.
REM Uso interno: los .cmd de cada layout delegan aqui.  "%~dp0_run.cmd" nombre1 nombre2 ...
setlocal EnableDelayedExpansion
set "B="

REM 1) Ubicaciones estandar (via variables de entorno, no rutas fijas)
for %%D in ("%ProgramFiles%\Git" "%ProgramFiles(x86)%\Git" "%LocalAppData%\Programs\Git") do (
  if exist "%%~D\bin\bash.exe" (set "B=%%~D\bin\bash.exe" & goto :run)
)

REM 2) Derivar desde git.exe en PATH (cubre instalaciones no estandar)
for /f "delims=" %%G in ('where git.exe 2^>nul') do (
  set "D=%%~dpG"
  if exist "!D!..\bin\bash.exe"   (set "B=!D!..\bin\bash.exe"   & goto :run)
  if exist "!D!..\..\bin\bash.exe" (set "B=!D!..\..\bin\bash.exe" & goto :run)
  if exist "!D!..\..\..\bin\bash.exe" (set "B=!D!..\..\..\bin\bash.exe" & goto :run)
)

echo [X] Git Bash no encontrado. Instala Git: https://git-scm.com/download/win
exit /b 1

:run
"%B%" -l "%~dp0open.sh" %*
