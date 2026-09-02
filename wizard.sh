#!/usr/bin/env bash
# wizard.sh — asistente interactivo: arma un layout de REJILLA (columnas x filas)
# preguntando, por cada celda, la carpeta y el comando. Genera el .toml + atajos.
#
#   sh wizard.sh            (o doble clic wizard.cmd)
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="$HERE/configs"

ask(){ printf '%s' "$1" >&2; IFS= read -r _r || true; printf '%s' "$_r"; }
# carpeta: relativa => se cuelga de ~/Documents/GitHub ; absoluta (~, /, C:) tal cual
expand(){ case "$1" in ''|'~') printf '~/Documents/GitHub';; ~*|/*|[A-Za-z]:*) printf '%s' "$1";; *) printf '~/Documents/GitHub/%s' "$1";; esac; }

name="$(ask 'Nombre del layout (kebab, ej: mi-stack): ')"
[ -n "$name" ] || { echo "Nombre vacío. Cancelado." >&2; exit 1; }
[ -e "$CFG/$name.toml" ] && { echo "⛔ Ya existe configs/$name.toml" >&2; exit 1; }
title="$(ask "Título del tab [$name]: ")"; title="${title:-$name}"
color="$(ask 'Color (green/magenta/blue/red/yellow/cyan/orange/purple o #hex) [green]: ')"; color="${color:-green}"
cols="$(ask 'Cuántas COLUMNAS: ')"
rows="$(ask 'Cuántas FILAS: ')"
case "$cols" in ''|*[!0-9]*) echo "columnas debe ser número" >&2; exit 1;; esac
case "$rows" in ''|*[!0-9]*) echo "filas debe ser número" >&2; exit 1;; esac
[ "$cols" -ge 1 ] && [ "$rows" -ge 1 ] || { echo "mínimo 1x1" >&2; exit 1; }

dirs=(); cmds=()
for c in $(seq 1 "$cols"); do
  for r in $(seq 1 "$rows"); do
    dirs+=("$(ask "  Col $c · Fila $r → carpeta: ")")
    cmds+=("$(ask "  Col $c · Fila $r → comando (Enter = ninguno): ")")
  done
done

{
  echo "# Layout '$name' — generado por wizard.sh (${cols} columnas x ${rows} filas)."
  echo "name = \"$name\""
  echo "title = \"$title\""
  echo "color = \"$color\""
  echo
  echo "[[panes]]"; echo "id = \"root\""; echo 'split = "horizontal"'
  printf 'children = ['; for c in $(seq 1 "$cols"); do printf '"col%s"' "$c"; [ "$c" -lt "$cols" ] && printf ', '; done; echo ']'
  echo
  for c in $(seq 1 "$cols"); do
    echo "[[panes]]"; echo "id = \"col$c\""; echo 'split = "vertical"'
    printf 'children = ['; for r in $(seq 1 "$rows"); do printf '"c%s_%s"' "$c" "$r"; [ "$r" -lt "$rows" ] && printf ', '; done; echo ']'
    echo
  done
  i=0
  for c in $(seq 1 "$cols"); do
    for r in $(seq 1 "$rows"); do
      echo "[[panes]]"; echo "id = \"c${c}_${r}\""; echo 'type = "terminal"'
      echo "directory = \"$(expand "${dirs[$i]}")\""
      [ -n "${cmds[$i]}" ] && echo "commands = [\"${cmds[$i]}\"]"
      echo 'shell = "bash"'; echo
      i=$((i+1))
    done
  done
} > "$CFG/$name.toml"

printf '#!/usr/bin/env bash\nexec sh "$(dirname "$0")/open.sh" %s\n' "$name" > "$HERE/$name.sh"
printf '@echo off\r\n"C:\\Program Files\\Git\\bin\\bash.exe" -l "%%~dp0open.sh" %s\r\n' "$name" > "$HERE/$name.cmd"

echo "" >&2
echo "✅ configs/$name.toml (${cols}x${rows}) + $name.sh / $name.cmd" >&2
echo "   Probar:  sh open.sh $name   (o doble clic $name.cmd)" >&2
