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

A=(); firstlayout=1
for n in "${names[@]}"; do
  toml="$CFG/$n.toml"
  [ -f "$toml" ] || { echo "⛔ No existe configs/$n.toml (ni es un combo)"; exit 1; }
  [ $firstlayout -eq 0 ] && A+=(';')
  while IFS= read -r line; do A+=("$line"); done < <(node "$HERE/toml2wt.mjs" "$toml")
  firstlayout=0
done

# ── Lanzamiento por ETAPAS (evita el error 0x80070057 de ConPTY) ─────────────
# El error aparece cuando Windows Terminal crea muchos paneles de golpe. En vez de
# un solo disparo, mandamos varias llamadas a wt.exe apuntando a la MISMA ventana:
#   LAY_STAGE=tab   (por defecto) → una llamada por TAB (layout). Rápido: abrir 1
#                    layout = 1 llamada (como antes); abrir varios = 1 por tab, en
#                    secuencia → no hay carrera entre tabs.
#   LAY_STAGE=pane  → una llamada por PANEL. El más lento pero a prueba de balas
#                    (úsalo si un layout muy denso aún falla): LAY_STAGE=pane sh open.sh …
#   LAY_STAGE=none  → todo en un solo disparo (el comportamiento viejo).
if [ ${#WIN[@]} -gt 0 ]; then WINREF=("${WIN[@]}"); MAXFLAG=(); else WINREF=(-w "lay_$$"); MAXFLAG=("${MAX[@]}"); fi
STAGE="${LAY_STAGE:-auto}"          # auto | tab | pane | none
MAXP="${LAY_STAGE_MAX:-4}"          # en 'auto': tabs con MÁS de este nº de paneles → por-panel
DELAY="${LAY_DELAY:-0.2}"
firstcall=1
emit() {                            # emit <inicio> <fin>  → una llamada a wt con A[inicio..fin)
  local a=$1; local b=$2; local seg=("${A[@]:$a:$((b-a))}")
  [ ${#seg[@]} -gt 0 ] || return 0
  if [ "$firstcall" = 1 ]; then wt.exe "${WINREF[@]}" "${MAXFLAG[@]}" "${seg[@]}"; firstcall=0
  else sleep "$DELAY"; wt.exe "${WINREF[@]}" "${seg[@]}"; fi
}

if [ "$STAGE" = "none" ]; then
  wt.exe "${WINREF[@]}" "${MAXFLAG[@]}" "${A[@]}"
else
  total=${#A[@]}
  # índices donde empieza cada tab (token 'new-tab') + centinela final
  tabs=(); for ((i=0;i<total;i++)); do [ "${A[$i]}" = "new-tab" ] && tabs+=($i); done; tabs+=($total)
  for ((t=0;t<${#tabs[@]}-1;t++)); do
    s=${tabs[$t]}; e=${tabs[$((t+1))]}
    [ "$e" -gt "$s" ] && [ "${A[$((e-1))]}" = ";" ] && e=$((e-1))   # soltar ';' que precede al sig. new-tab
    panes=1; for ((i=s;i<e;i++)); do [ "${A[$i]}" = "split-pane" ] && panes=$((panes+1)); done
    if [ "$STAGE" = "pane" ] || { [ "$STAGE" = "auto" ] && [ "$panes" -gt "$MAXP" ]; }; then
      # tab denso → un panel por llamada (a prueba de balas)
      ps=$s
      for ((i=s;i<e;i++)); do
        if [ "${A[$i]}" = ";" ] && [ "${A[$((i+1))]:-}" = "split-pane" ]; then emit "$ps" "$i"; ps=$((i+1)); fi
      done
      emit "$ps" "$e"
    else
      emit "$s" "$e"                                                # tab ligero → una sola llamada (rápido)
    fi
  done
fi
