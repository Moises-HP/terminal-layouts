#!/usr/bin/env bash
# clip-img.sh — guarda la imagen del PORTAPAPELES en un archivo y te da la referencia
# "@ruta" lista para pegar en una IA de terminal (Claude Code, etc.).
#
# Flujo: captura con Alt+Shift (o Win+Shift+S) → corre 'img' → pega el @ruta que sale
# (queda también en el portapapeles como texto). Sirve cuando la terminal no deja
# pegar la imagen directo (Windows Terminal), a diferencia de Warp.
set -uo pipefail
export MSYS_NO_PATHCONV=1
out="$(powershell.exe -NoProfile -Command "
  Add-Type -AssemblyName System.Windows.Forms
  \$img = [System.Windows.Forms.Clipboard]::GetImage()
  if (\$img) {
    \$dir = Join-Path \$env:USERPROFILE 'Pictures\clip'
    New-Item -ItemType Directory -Force -Path \$dir | Out-Null
    \$p = Join-Path \$dir ('clip-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.png')
    \$img.Save(\$p, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output \$p
  } else { Write-Output 'NOIMG' }
" 2>/dev/null | tr -d '\r')"

if [ "$out" = "NOIMG" ] || [ -z "$out" ]; then
  echo "⛔ No hay imagen en el portapapeles."
  echo "   Captura con Alt+Shift (o Win+Shift+S), o copia una imagen, y reintenta."
  exit 1
fi

ref="@$(printf '%s' "$out" | sed 's/\\/\//g')"   # backslashes → forward slashes
printf '%s\n' "$ref"
printf '%s' "$ref" | clip 2>/dev/null && echo "(copiado al portapapeles como texto — pégalo en la IA)" || true
