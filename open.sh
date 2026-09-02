#!/usr/bin/env bash
# open.sh — abre uno o varios layouts en UNA ventana de Windows Terminal
# (un tab por layout). Cada layout = un .toml en ./configs/.
#
#   sh open.sh                     -> TODOS (orden definido) = vista MEGA
#   sh open.sh pos-deploys         -> solo ese
#   sh open.sh dev surveys-dev     -> esos dos como tabs de una ventana
#
# Requiere: node, wt.exe, Git Bash. Los .toml se convierten con toml2wt.mjs.
set -euo pipefail
export MSYS_NO_PATHCONV=1
# pwd -W => ruta Windows nativa (C:/...), que node y wt.exe entienden.
# (pwd normal da /c/... y node lo resuelve mal como C:\c\...)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -W)"
CFG="$HERE/configs"

# Orden preferido para la vista MEGA; los .toml nuevos no listados se agregan al final.
# Orden preferido para la vista MEGA (lay all). Pon aquí los nombres que quieras
# primero; los demás .toml se agregan después, alfabéticamente. Vacío = alfabético.
ORDER=()

# -w <win> / --into <win>: agrega los tabs a una VENTANA existente en vez de una
# nueva. <win> puede ser: last (la última usada), 0 (la actual), o un nombre.
# Ventana NUEVA => --maximized: así siempre hay espacio para todos los paneles
# (evita el error 0x80070057 / "not enough space to split" al abrir muchos).
WIN=(); MAX=(--maximized)
if [ "${1:-}" = "-w" ] || [ "${1:-}" = "--into" ]; then
  [ -n "${2:-}" ] || { echo "⛔ falta id de ventana tras $1 (ej: last, 0, un-nombre)"; exit 1; }
  WIN=(-w "$2"); MAX=(); shift 2   # agregando a ventana existente: no maximizar
fi

names=("$@")
if [ ${#names[@]} -eq 0 ] || { [ ${#names[@]} -eq 1 ] && [ "${names[0]}" = "all" ]; }; then
  names=()
  for n in "${ORDER[@]}"; do [ -f "$CFG/$n.toml" ] && names+=("$n"); done
  for f in "$CFG"/*.toml; do
    b="$(basename "$f" .toml)"
    case " ${ORDER[*]} " in *" $b "*) : ;; *) names+=("$b") ;; esac
  done
fi

# expandir combos: si un nombre es un combo (combo-<n>.sh), se reemplaza por sus layouts
exp=()
for n in "${names[@]}"; do
  b="${n#combo-}"
  if [ -f "$CFG/$n.toml" ]; then exp+=("$n")
  elif [ -f "$HERE/combo-$b.sh" ]; then
    while IFS= read -r l; do [ -n "$l" ] && exp+=("$l"); done \
      < <(sed -n 's#.*/open.sh" ##p' "$HERE/combo-$b.sh" | tr ' ' '\n')
  else exp+=("$n"); fi
done
names=("${exp[@]}")

# recordar lo último abierto (para 'lay last')
[ ${#names[@]} -gt 0 ] && printf '%s\n' "${names[*]}" > "$HERE/.last" 2>/dev/null || true

A=(); first=1
for n in "${names[@]}"; do
  toml="$CFG/$n.toml"
  [ -f "$toml" ] || { echo "⛔ No existe configs/$n.toml"; exit 1; }
  [ $first -eq 0 ] && A+=(';')
  while IFS= read -r line; do A+=("$line"); done < <(node "$HERE/toml2wt.mjs" "$toml")
  first=0
done

exec wt.exe "${WIN[@]}" "${MAX[@]}" "${A[@]}"
