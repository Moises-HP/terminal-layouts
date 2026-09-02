@echo off
REM install.cmd — instalador de DOBLE CLIC (para Windows). Corre install.sh con Git Bash.
setlocal
set "GITBASH=C:\Program Files\Git\bin\bash.exe"
if not exist "%GITBASH%" set "GITBASH=%ProgramFiles%\Git\bin\bash.exe"

if not exist "%GITBASH%" (
  echo.
  echo  [X] No se encontro Git Bash.
  echo      Instala "Git para Windows":  https://git-scm.com/download/win
  echo      Tambien necesitas Node ^(https://nodejs.org^) y Windows Terminal ^(Microsoft Store^).
  echo.
  pause
  exit /b 1
)

"%GITBASH%" -l "%~dp0install.sh"
echo.
pause
