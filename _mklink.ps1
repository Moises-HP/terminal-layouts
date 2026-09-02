# _mklink.ps1 — crea el acceso directo (.lnk) en Inicio y/o Escritorio según LAY_WHERE.
# Apunta a bash.exe (.exe) para que Windows permita anclarlo a la barra de tareas.
# Recibe todo por variables de entorno (las pone pin.sh).
$ErrorActionPreference = 'Stop'
$W = New-Object -ComObject WScript.Shell
$targets = @()
if ($env:LAY_WHERE -ne 'desktop') { $targets += $env:LAY_START }
if ($env:LAY_WHERE -ne 'start')   { $targets += [Environment]::GetFolderPath('Desktop') }
foreach ($dir in $targets) {
  if (-not $dir) { continue }
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $s = $W.CreateShortcut((Join-Path $dir ($env:LAY_LNKNAME + ".lnk")))
  $s.TargetPath       = $env:LAY_BASH
  $s.Arguments        = $env:LAY_ARGS
  $s.WorkingDirectory = $env:LAY_DIR
  $s.IconLocation     = $env:LAY_ICON
  $s.WindowStyle      = 7
  $s.Description       = $env:LAY_LNKNAME
  $s.Save()
}
