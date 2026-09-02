#!/usr/bin/env bash
# savecombo.sh <nombre> <layout1> <layout2> ... — guarda un CONJUNTO de layouts como
# un atajo: combo-<nombre>.sh + combo-<nombre>.cmd que los abren juntos (tabs, 1 ventana).
#
#   sh savecombo.sh deploys pos-deploys surveys-deploys tunnels
#   → doble clic combo-deploys.cmd  abre esos 3 en una ventana con tabs.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="$HERE/configs"
name="${1:-}"; [ "$#" -ge 2 ] || { echo "uso: sh savecombo.sh <nombre> <layout1> <layout2> ..."; exit 1; }
shift
for l in "$@"; do
  [ -f "$CFG/$l.toml" ] || { echo "⛔ no existe el layout: $l   (revisa configs/)"; exit 1; }
done
printf '#!/usr/bin/env bash\nexec sh "$(dirname "$0")/open.sh" %s\n' "$*" > "$HERE/combo-$name.sh"
printf '@echo off\r\n"C:\\Program Files\\Git\\bin\\bash.exe" -l "%%~dp0open.sh" %s\r\n' "$*" > "$HERE/combo-$name.cmd"
echo "✅ combo '$name' = $*"
echo "   combo-$name.sh  /  combo-$name.cmd (doble clic) → los abre en 1 ventana con tabs."
echo "   Para agregarlos a la ventana ACTUAL en vez de una nueva:  sh add.sh $*"
