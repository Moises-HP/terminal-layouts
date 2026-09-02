#!/usr/bin/env bash
# pick.sh — menú interactivo: elige QUÉ layouts abrir juntos (tabs en 1 ventana).
# Equivale a escribir  sh open.sh <a> <b> <c>  pero sin recordar nombres.
#
#   sh pick.sh            (o doble clic pick.cmd)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HERE/configs"

names=()
for f in "$CFG"/*.toml; do [ -e "$f" ] || continue; names+=("$(basename "$f" .toml)"); done
nlayouts=${#names[@]}
for f in "$HERE"/combo-*.sh; do [ -e "$f" ] || continue; names+=("combo-$(basename "$f" .sh | sed 's/^combo-//')"); done
[ ${#names[@]} -gt 0 ] || { echo "No hay configs en $CFG"; exit 1; }

echo "Layouts y combos disponibles:"
i=0
for n in "${names[@]}"; do
  i=$((i+1))
  [ "$i" -eq "$((nlayouts+1))" ] && echo "  — combos (levantan varios layouts) —"
  printf "  %2d) %s\n" "$i" "$n"
done
echo   "   t) terminal normal (Git Bash, sin layout)"
echo
echo "Escribe cuáles abrir (números o nombres, separados por espacio)."
echo "Ej:  1 3 5   |   dev pos-deploys tunnels   |   all (todos)   |   t (terminal)   |   Enter = cancelar"
printf "> "
read -r line

# limpiar espacios para detectar vacío
[ -n "$(printf '%s' "$line" | tr -d ' ')" ] || { echo "Cancelado."; exit 0; }

# 'all' → todos ; 't'/'term' → terminal normal
for tok in $line; do [ "$tok" = "all" ] && exec sh "$HERE/open.sh"; done
for tok in $line; do case "$tok" in t|term|terminal) export MSYS_NO_PATHCONV=1; exec wt.exe -p "Git Bash";; esac; done

sel=()
for tok in $line; do
  case "$tok" in
    ''|*[!0-9]*)                                   # no numérico → nombre (layout o combo)
      c="${tok#combo-}"
      if [ -f "$CFG/$tok.toml" ] || [ -f "$HERE/combo-$c.sh" ]; then sel+=("$tok")
      else echo "⚠️  no existe: $tok"; fi ;;
    *)                                             # numérico → índice
      idx=$((tok-1))
      if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#names[@]}" ]; then sel+=("${names[$idx]}")
      else echo "⚠️  número fuera de rango: $tok"; fi ;;
  esac
done

[ "${#sel[@]}" -gt 0 ] || { echo "Nada válido seleccionado."; exit 1; }
echo "Abriendo: ${sel[*]}"
exec sh "$HERE/open.sh" "${sel[@]}"
