#!/usr/bin/env bash
# editcombo.sh <nombre-combo> — editor interactivo de un combo: agrega, quita,
# mueve (reordena) y guarda. Lo usa 'lay edit combo-<n>'.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CFG="$HERE/configs"
name="${1#combo-}"
combo="$HERE/combo-$name.sh"
[ -f "$combo" ] || { echo "⛔ no existe el combo: $name"; exit 1; }

B=$'\e[1m'; G=$'\e[32m'; Y=$'\e[33m'; D=$'\e[2m'; Rd=$'\e[31m'; R=$'\e[0m'

# layouts disponibles (índice estable)
avail=(); while IFS= read -r f; do avail+=("$(basename "$f" .toml)"); done < <(ls -1 "$CFG"/*.toml 2>/dev/null)
# lista actual del combo
read -r -a items <<< "$(sed -n 's#.*/open.sh" ##p' "$combo")"

is_layout() { local x; for x in "${avail[@]}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

render() {
  printf '\n%sEditar combo%s %s%s%s\n\n' "$B" "$R" "$G" "$name" "$R"
  echo "  Abre estos layouts (en orden):"
  if [ "${#items[@]}" -eq 0 ]; then printf '    %s(vacío)%s\n' "$D" "$R"
  else local i=1; for l in "${items[@]}"; do printf '    %s%d.%s %s\n' "$B" "$i" "$R" "$l"; i=$((i+1)); done; fi
  echo
  echo "  ${D}Disponibles:${R}"
  local i=1 line="    "
  for l in "${avail[@]}"; do line+="$(printf '%s%d%s)%s  ' "$D" "$i" "$R" "$l")"; i=$((i+1)); done
  echo "$line"
  cat <<EOF

  ${Y}Acciones${R} (una por línea):
    ${G}+N${R} / ${G}+nombre${R}   agregar (N = nº de 'Disponibles')      ${G}-N${R}         quitar la posición N
    ${G}m N M${R}          mover la posición N a la posición M    ${G}ok${R}         guardar y salir
    ${G}r${R}              refrescar la vista                     ${G}q${R}          cancelar
EOF
}

render
while true; do
  printf '> '; read -r line || { echo; break; }
  set -- $line; act="${1:-}"
  case "$act" in
    ok|save|s|guardar)
      [ "${#items[@]}" -ge 1 ] || { echo "${Rd}El combo no puede quedar vacío.${R}"; continue; }
      sh "$HERE/savecombo.sh" "$name" "${items[@]}" >/dev/null
      echo "${G}✅ combo '$name' guardado → ${items[*]}${R}"; exit 0 ;;
    q|cancel|cancelar) echo "Cancelado (sin cambios)."; exit 0 ;;
    r|'') render ;;
    m|mover)
      n="${2:-}"; mm="${3:-}"
      case "$n$mm" in *[!0-9]*|'') echo "uso: m <N> <M>"; continue ;; esac
      [ "$n" -ge 1 ] && [ "$n" -le "${#items[@]}" ] && [ "$mm" -ge 1 ] && [ "$mm" -le "${#items[@]}" ] || { echo "${Rd}posiciones fuera de rango${R}"; continue; }
      val="${items[$((n-1))]}"; new=()
      # quitar n
      local_idx=0; for x in "${items[@]}"; do [ "$local_idx" -ne "$((n-1))" ] && new+=("$x"); local_idx=$((local_idx+1)); done
      items=(); local_idx=0
      for x in "${new[@]}"; do [ "$local_idx" -eq "$((mm-1))" ] && items+=("$val"); items+=("$x"); local_idx=$((local_idx+1)); done
      [ "$((mm-1))" -ge "${#new[@]}" ] && items+=("$val")
      render ;;
    -*)
      n="${act#-}"
      case "$n" in *[!0-9]*|'') echo "uso: -N (posición a quitar)"; continue ;; esac
      [ "$n" -ge 1 ] && [ "$n" -le "${#items[@]}" ] || { echo "${Rd}posición fuera de rango${R}"; continue; }
      new=(); local_idx=0; for x in "${items[@]}"; do [ "$local_idx" -ne "$((n-1))" ] && new+=("$x"); local_idx=$((local_idx+1)); done
      items=("${new[@]}"); render ;;
    +*)
      arg="${act#+}"; [ -z "$arg" ] && arg="${2:-}"
      case "$arg" in
        '') echo "uso: +N o +nombre"; continue ;;
        *[!0-9]*) tgt="$arg" ;;                                  # nombre
        *) idx=$((arg-1)); [ "$idx" -ge 0 ] && [ "$idx" -lt "${#avail[@]}" ] && tgt="${avail[$idx]}" || { echo "${Rd}nº fuera de rango${R}"; continue; } ;;
      esac
      is_layout "$tgt" || { echo "${Rd}no existe el layout: $tgt${R}"; continue; }
      items+=("$tgt"); render ;;
    *) echo "${D}acción no reconocida. Usa: +N  -N  m N M  ok  q${R}" ;;
  esac
done
