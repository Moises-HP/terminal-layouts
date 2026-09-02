#!/usr/bin/env bash
# pin.sh <layout> [layout2 ...] — crea un acceso directo (.lnk) de cada layout en el
# menú Inicio, dentro de la carpeta "Terminal Layouts", listo para anclar a la barra.
#
# Para qué sirve: tener tus layouts en el menú Inicio / barra de tareas y abrirlos con
# un clic. (Windows NO deja anclar a la barra por script; esto deja el acceso listo
# para que hagas clic derecho → "Anclar a la barra de tareas".)
#
#   sh pin.sh pos-deploys claude-github
set -uo pipefail
export MSYS_NO_PATHCONV=1
HERE="$(cd "$(dirname "$0")" && pwd)"
[ "$#" -ge 1 ] || { echo "uso: sh pin.sh <layout> [layout2 ...]"; exit 1; }

export LAY_ICON='C:\Program Files\Git\mingw64\share\git\git-for-windows.ico'
export LAY_START="$(cygpath -w "$APPDATA")\\Microsoft\\Windows\\Start Menu\\Programs\\Terminal Layouts"
export LAY_DIR="$(cygpath -w "$HERE")"
PS1FILE="$(cygpath -w "$HERE/_mklink.ps1")"

for name in "$@"; do
  [ -f "$HERE/configs/$name.toml" ] || { echo "⚠️  no existe el layout: $name (saltado)"; continue; }
  [ -f "$HERE/$name.cmd" ] || sh "$HERE/new.sh" "$name" >/dev/null
  export LAY_CMD="$(cygpath -w "$HERE/$name.cmd")"
  export LAY_NAME="$name"
  # Crea "Layout <name>.lnk" en Inicio Y en el Escritorio (vía _mklink.ps1).
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS1FILE" || { echo "⚠️  no se pudo crear el acceso de $name"; continue; }
  echo "📌 '$name'  →  Escritorio + Inicio, como:  Layout $name"
done
echo
echo "• En el ESCRITORIO ya tienes el acceso 'Layout <nombre>' (doble clic para abrir)."
echo "• Para ANCLAR a la barra de tareas: tecla Windows (⊞) → escribe 'Layout' →"
echo "  clic derecho en el que quieras → 'Anclar a la barra de tareas'."
