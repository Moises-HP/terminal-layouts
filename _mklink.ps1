# _mklink.ps1 — crea el acceso directo "Layout <name>" en el menú Inicio Y en el
# Escritorio. Recibe los datos por variables de entorno (las pone pin.sh).
$ErrorActionPreference = 'Stop'
$W = New-Object -ComObject WScript.Shell
$targets = @($env:LAY_START, [Environment]::GetFolderPath('Desktop'))
foreach ($dir in $targets) {
  if (-not $dir) { continue }
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $s = $W.CreateShortcut((Join-Path $dir ("Layout " + $env:LAY_NAME + ".lnk")))
  $s.TargetPath       = $env:LAY_CMD
  $s.WorkingDirectory = $env:LAY_DIR
  $s.IconLocation     = $env:LAY_ICON
  $s.WindowStyle      = 7
  $s.Description       = "Abrir layout " + $env:LAY_NAME
  $s.Save()
}
