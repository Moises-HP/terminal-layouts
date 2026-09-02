#!/usr/bin/env bash
# grid.sh <nombre> <CxR> <celda...> — crea un layout de rejilla SIN asistente
# (versión de una línea del wizard). Celdas en orden COLUMNA-major (col1 de arriba
# a abajo, luego col2, ...). Cada celda: "carpeta"  o  "carpeta|comando".
#
#   sh grid.sh api 2x2 backend "frontend|npm run dev" db "worker|bun dev"
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="$HERE/configs"
name="${1:-}"; grid="${2:-}"
[ -n "$name" ] && [ -n "$grid" ] || { echo "uso: sh grid.sh <nombre> <CxR> <celda...>  (celda = carpeta | carpeta|comando)"; exit 1; }
[ -e "$CFG/$name.toml" ] && { echo "⛔ ya existe: $name"; exit 1; }
cols="${grid%%x*}"; rows="${grid##*x}"
case "$cols" in ''|*[!0-9]*) echo "CxR inválido (ej: 2x2)"; exit 1;; esac
case "$rows" in ''|*[!0-9]*) echo "CxR inválido (ej: 2x2)"; exit 1;; esac
shift 2
[ "$#" -eq "$(( cols * rows ))" ] || { echo "⛔ ${grid} necesita $(( cols*rows )) celdas, diste $#"; exit 1; }
expand(){ case "$1" in ''|'~') printf '~/Documents/GitHub';; ~*|/*|[A-Za-z]:*) printf '%s' "$1";; *) printf '~/Documents/GitHub/%s' "$1";; esac; }
cells=("$@")

{
  echo "# Layout '$name' — rejilla ${cols}x${rows} (grid.sh)."
  echo "name = \"$name\""; echo "title = \"$name\""; echo 'color = "green"'; echo
  echo "[[panes]]"; echo 'id = "root"'; echo 'split = "horizontal"'
  printf 'children = ['; for c in $(seq 1 "$cols"); do printf '"col%s"' "$c"; [ "$c" -lt "$cols" ] && printf ', '; done; echo ']'; echo
  for c in $(seq 1 "$cols"); do
    echo "[[panes]]"; echo "id = \"col$c\""; echo 'split = "vertical"'
    printf 'children = ['; for r in $(seq 1 "$rows"); do printf '"c%s_%s"' "$c" "$r"; [ "$r" -lt "$rows" ] && printf ', '; done; echo ']'; echo
  done
  i=0
  for c in $(seq 1 "$cols"); do
    for r in $(seq 1 "$rows"); do
      cell="${cells[$i]}"; dir="${cell%%|*}"; cmd=""; [ "$cell" != "$dir" ] && cmd="${cell#*|}"
      echo "[[panes]]"; echo "id = \"c${c}_${r}\""; echo 'type = "terminal"'
      echo "directory = \"$(expand "$dir")\""
      [ -n "$cmd" ] && echo "commands = [\"$cmd\"]"
      echo 'shell = "bash"'; echo
      i=$((i+1))
    done
  done
} > "$CFG/$name.toml"

sh "$HERE/new.sh" "$name" >/dev/null
echo "✅ configs/$name.toml (${cols}x${rows}) + atajos.   Ver: lay preview $name"
