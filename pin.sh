#!/usr/bin/env bash
# pin.sh — crea accesos directos ("Layout <n>" / "Combo <n>") en el Escritorio y/o el
# menú Inicio, para abrirlos con un clic o anclarlos a la barra de tareas. Apuntan a
# bash.exe (.exe) para que Windows SÍ permita anclarlos a la barra.
#
#   sh pin.sh                      menú interactivo (elige cuáles y dónde)
#   sh pin.sh all                  TODOS los layouts (por defecto solo en Inicio)
#   sh pin.sh dev pos-deploys      esos layouts
#   sh pin.sh combo-deploys        un combo (su acceso levanta todo el combo)
#   sh pin.sh --start  <n...>      solo en Inicio (para anclar a la barra)
#   sh pin.sh --desktop <n...>     solo en el Escritorio
#   sh pin.sh --both   <n...>      en ambos (por defecto para nombres sueltos)
set -uo pipefail
export MSYS_NO_PATHCONV=1
HERE="$(cd "$(dirname "$0")" && pwd)"
CFG="$HERE/configs"
export LAY_ICON='C:\Program Files\Git\mingw64\share\git\git-for-windows.ico'
export LAY_START="$(cygpath -w "$APPDATA")\\Microsoft\\Windows\\Start Menu\\Programs\\Terminal Layouts"
export LAY_DIR="$(cygpath -w "$HERE")"
export LAY_BASH='C:\Program Files\Git\bin\bash.exe'
PS1FILE="$(cygpath -w "$HERE/_mklink.ps1")"
OPEN_WIN="$(cygpath -m "$HERE/open.sh")"

layouts() { for f in "$CFG"/*.toml; do [ -e "$f" ] && basename "$f" .toml; done; }
combos()  { for f in "$HERE"/combo-*.sh; do [ -e "$f" ] && basename "$f" .sh | sed 's/^combo-//'; done; }

where="both"; where_explicit=0; used_all=0; items=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --start)   where="start";   where_explicit=1 ;;
    --desktop) where="desktop"; where_explicit=1 ;;
    --both)    where="both";    where_explicit=1 ;;
    all)       used_all=1; while IFS= read -r n; do case "$n" in example-*) : ;; *) items+=("$n") ;; esac; done < <(layouts) ;;
    *)         items+=("$1") ;;
  esac
  shift
done
# 'all' sin ubicación explícita → solo Inicio (evita saturar el Escritorio)
[ "$used_all" = 1 ] && [ "$where_explicit" = 0 ] && where="start"

# ── Menú interactivo si no dieron items ──────────────────────────────────────
if [ "${#items[@]}" -eq 0 ]; then
  names=(); while IFS= read -r n; do names+=("$n"); done < <(layouts)
  cmbs=();  while IFS= read -r n; do cmbs+=("$n");  done < <(combos)
  echo "Layouts:"; i=0
  for n in "${names[@]}"; do i=$((i+1)); printf "  %2d) %s\n" "$i" "$n"; done
  if [ "${#cmbs[@]}" -gt 0 ]; then echo "Combos (escribe el nombre):"; for c in "${cmbs[@]}"; do printf "   •  combo-%s\n" "$c"; done; fi
  echo
  printf "¿Cuáles anclar? (números/nombres, 'all', Enter=cancelar): "
  read -r line
  [ -n "$(printf '%s' "$line" | tr -d ' ')" ] || { echo "Cancelado."; exit 0; }
  for tok in $line; do
    case "$tok" in
      all) items=("${names[@]}"); break ;;
      ''|*[!0-9]*) items+=("$tok") ;;
      *) idx=$((tok-1)); [ "$idx" -ge 0 ] && [ "$idx" -lt "${#names[@]}" ] && items+=("${names[$idx]}") ;;
    esac
  done
  echo "¿Dónde crear el acceso?"
  echo "  1) Inicio + Escritorio     2) Solo Inicio (para anclar a la barra)     3) Solo Escritorio"
  printf "> "; read -r w
  case "$w" in 2) where="start" ;; 3) where="desktop" ;; *) where="both" ;; esac
fi

[ "${#items[@]}" -gt 0 ] || { echo "Nada que anclar."; exit 1; }
export LAY_WHERE="$where"

# ── Crear accesos ────────────────────────────────────────────────────────────
made=0
for name in "${items[@]}"; do
  cname="${name#combo-}"
  if [ -f "$CFG/$name.toml" ]; then
    export LAY_LNKNAME="Layout $name"
    export LAY_ARGS="-l \"$OPEN_WIN\" $name"
  elif [ -f "$HERE/combo-$cname.sh" ]; then
    export LAY_LNKNAME="Combo $cname"
    export LAY_ARGS="-l \"$(cygpath -m "$HERE/combo-$cname.sh")\""
  else
    echo "⚠️  no existe layout ni combo: $name (saltado)"; continue
  fi
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS1FILE" || { echo "⚠️  falló $name"; continue; }
  echo "📌 $LAY_LNKNAME"; made=$((made+1))
done

[ "$made" -gt 0 ] || exit 1
echo
case "$where" in
  start)   echo "Creados en el menú Inicio (⊞ Windows → escribe 'Layout' o 'Combo')." ;;
  desktop) echo "Creados en el Escritorio (doble clic para abrir)." ;;
  *)       echo "Creados en el Escritorio y en el menú Inicio." ;;
esac
echo "Para ANCLAR a la barra: clic derecho en el acceso → 'Mostrar más opciones' → 'Anclar a la barra de tareas'."