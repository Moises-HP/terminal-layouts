#!/usr/bin/env bash
# open.sh — abre uno o varios layouts en UNA ventana de Windows Terminal
# (un tab por layout). Cada layout = un .toml en ./configs/.
#
#   sh open.sh                     -> TODOS (orden definido) = vista MEGA
#   sh open.sh example-columns     -> solo ese
#   sh open.sh example-columns example-shells   -> esos dos como tabs de una ventana
#
# Requiere: node, wt.exe, Git Bash. Los .toml se convierten con toml2wt.mjs.
set -euo pipefail
export MSYS_NO_PATHCONV=1
# pwd -W => ruta Windows nativa (C:/...), que node y wt.exe entienden.
# (pwd normal da /c/... y node lo resuelve mal como C:\c\...)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -W)"
CFG="$HERE/configs"
# default global de shell para los paneles (LAY_SHELL), configurable con 'lay shell'.
[ -f "$HERE/.layconfig" ] && . "$HERE/.layconfig" || true
export LAY_SHELL="${LAY_SHELL:-bash}"

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

# ── Lanzamiento: UNA invocación atómica construye TODO el layout ──────────────
# CLAVE: dentro de UNA sola llamada a wt.exe, Windows Terminal ejecuta las acciones
# (new-tab / split-pane / move-focus) en ORDEN y de forma atómica contra la ventana
# → el layout sale exacto. El problema NUNCA fue una sola llamada; fue disparar
# VARIAS llamadas 'wt.exe -w <win> …' (son asíncronas y corren en paralelo): sus
# comandos se entrelazan y comparten el foco GLOBAL de la ventana, así que un
# split-pane de una llamada cae en la pestaña que dejó enfocada OTRA llamada →
# paneles fugados a otra pestaña, desorden, pestañas densas fusionadas.
#
# Por eso NO fragmentamos la construcción. El único motivo para no meter todo en
# un disparo era el error 0x80070057 (WT parte los paneles antes de maximizar, y
# alguno queda por debajo del tamaño mínimo). Se resuelve PRE-MAXIMIZANDO:
#   1) una llamada mínima abre la ventana MAXIMIZADA con el 1er panel (sin splits).
#   2) settle: esperar UNA vez a que la ventana ya esté maximizada y estable.
#   3) UNA invocación atómica con TODO el resto (splits del 1er tab + los demás
#      tabs completos). Al ser un solo proceso, no hay carrera de foco posible y,
#      como la ventana ya está a tamaño completo, los splits siempre caben.
#
#   LAY_STAGE=none → todo en un único disparo maximizado (sin pre-maximizar; escape).
#   LAY_SETTLE (0.7) = espera tras abrir/maximizar la ventana (súbelo en PC lenta).
#   LAY_DRYRUN=1     = imprime las llamadas a wt.exe en vez de ejecutarlas.
WT() { if [ "${LAY_DRYRUN:-}" = "1" ]; then printf 'wt.exe'; printf ' %q' "$@"; printf '\n'; else wt.exe "$@"; fi; }

if [ ${#WIN[@]} -gt 0 ]; then WINREF=("${WIN[@]}"); MAXFLAG=(); INTO=1
else WINREF=(-w "lay_$$"); MAXFLAG=("${MAX[@]}"); INTO=0; fi
STAGE="${LAY_STAGE:-auto}"          # auto | none
SETTLE="${LAY_SETTLE:-0.7}"         # espera tras abrir+maximizar la ventana

# Ventana EXISTENTE (lay add / -w), o escape 'none': TODO en una sola invocación
# atómica (determinista, sin fugas). Sin maximizar en el caso -w (ya existe).
if [ "$INTO" = "1" ] || [ "$STAGE" = "none" ]; then
  WT "${WINREF[@]}" "${MAXFLAG[@]}" "${A[@]}"
  exit 0
fi

# ── Ventana NUEVA: pre-maximizar + una invocación atómica ─────────────────────
total=${#A[@]}
# índices donde empieza cada pestaña ('new-tab') + centinela final
tabs=(); for ((i=0;i<total;i++)); do [ "${A[$i]}" = "new-tab" ] && tabs+=("$i"); done; tabs+=("$total")
ntabs=$(( ${#tabs[@]} - 1 ))

# fin real de la 1ª pestaña y punto de su primer split-pane
e0=${tabs[1]}
[ "$e0" -gt "${tabs[0]}" ] && [ "${A[$((e0-1))]}" = ";" ] && e0=$((e0-1))
sp0=-1
for ((i=${tabs[0]};i<e0-1;i++)); do
  [ "${A[$i]}" = ";" ] && [ "${A[$((i+1))]}" = "split-pane" ] && { sp0=$i; break; }
done

# 1) abrir ventana MAXIMIZADA con SOLO el primer panel del primer tab (sin splits).
head0End=$e0; [ "$sp0" -ge 0 ] && head0End=$sp0
call1=(); for ((i=${tabs[0]};i<head0End;i++)); do call1+=("${A[$i]}"); done
WT "${WINREF[@]}" "${MAXFLAG[@]}" "${call1[@]}"

# 2) esperar a que la ventana esté abierta y maximizada.
sleep "$SETTLE"

# 3) UNA invocación atómica con el resto: splits del 1er tab (la ventana ya lo tiene
#    enfocado) + TODO el resto de A (';' new-tab … por cada pestaña siguiente).
call2=()
if [ "$sp0" -ge 0 ]; then                      # splits del primer tab (sin el ';' inicial)
  for ((i=sp0+1;i<e0;i++)); do call2+=("${A[$i]}"); done
fi
for ((i=e0;i<total;i++)); do call2+=("${A[$i]}"); done   # el resto de tabs, tal cual (empieza con ';')
# quitar un ';' inicial sobrante (si el 1er tab no tenía splits, A[e0] es el ';' pre-new-tab)
[ "${#call2[@]}" -gt 0 ] && [ "${call2[0]}" = ";" ] && call2=("${call2[@]:1}")

[ "${#call2[@]}" -gt 0 ] && WT "${WINREF[@]}" "${call2[@]}"
