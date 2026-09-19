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

# ── Lanzamiento en DOS FASES (determinista: sin carreras y sin 0x80070057) ────
# Cada 'wt.exe -w <win> …' es ASÍNCRONO: entrega el comando a la ventana y regresa
# sin esperar. Disparar varios 'split-pane' SUELTOS (sin decir a qué pestaña van)
# hace que Windows Terminal los aplique al panel ACTIVO en ese instante → paneles
# en la pestaña equivocada, en desorden, o error 0x80070057. Por eso:
#   FASE 1  UNA llamada crea TODAS las pestañas con su PRIMER panel (new-tab; …).
#           Sin splits ⇒ nunca 0x80070057; el orden de pestañas queda fijo (atómico).
#   settle  esperar UNA vez a que la ventana (maximizada) y las pestañas existan.
#   FASE 2  Por cada pestaña con subdivisiones, UNA llamada que hace 'focus-tab -t
#           <i>' (fija la pestaña por índice) y luego sus split-pane/move-focus. Al
#           fijar la pestaña, ya no importa el orden en que WT procese las llamadas:
#           cada split cae SIEMPRE en su pestaña, sobre una ventana ya estable.
#   LAY_STAGE=none → todo en un solo disparo (comportamiento viejo; escape).
#   LAY_SETTLE (0.5) espera tras crear las pestañas · LAY_DELAY (0.08) micro-stagger.
#   LAY_DRYRUN=1 imprime las llamadas a wt.exe en vez de ejecutarlas (diagnóstico).
WT() { if [ "${LAY_DRYRUN:-}" = "1" ]; then printf 'wt.exe'; printf ' %q' "$@"; printf '\n'; else wt.exe "$@"; fi; }

if [ ${#WIN[@]} -gt 0 ]; then WINREF=("${WIN[@]}"); MAXFLAG=(); INTO=1
else WINREF=(-w "lay_$$"); MAXFLAG=("${MAX[@]}"); INTO=0; fi
STAGE="${LAY_STAGE:-auto}"          # auto | none
SETTLE="${LAY_SETTLE:-0.5}"         # espera única tras crear las pestañas (FASE 1)
DELAY="${LAY_DELAY:-0.08}"          # micro-stagger entre llamadas de FASE 2

if [ "$STAGE" = "none" ]; then
  WT "${WINREF[@]}" "${MAXFLAG[@]}" "${A[@]}"
  exit 0
fi

# límites de cada pestaña (índices con 'new-tab') + centinela final
total=${#A[@]}
tabs=(); for ((i=0;i<total;i++)); do [ "${A[$i]}" = "new-tab" ] && tabs+=("$i"); done; tabs+=("$total")
ntabs=$(( ${#tabs[@]} - 1 ))

# para cada pestaña: inicio, fin (sin ';' final) y punto del primer split-pane
starts=(); ends=(); splitat=()
for ((t=0;t<ntabs;t++)); do
  s=${tabs[$t]}; e=${tabs[$((t+1))]}
  [ "$e" -gt "$s" ] && [ "${A[$((e-1))]}" = ";" ] && e=$((e-1))     # soltar ';' que precede al sig. new-tab
  sp=-1
  for ((i=s;i<e-1;i++)); do
    [ "${A[$i]}" = ";" ] && [ "${A[$((i+1))]}" = "split-pane" ] && { sp=$i; break; }
  done
  starts+=("$s"); ends+=("$e"); splitat+=("$sp")
done

if [ "$INTO" = "1" ]; then
  # Ventana EXISTENTE: no sabemos el índice base ⇒ no usamos 'focus-tab -t'. Cada
  # pestaña se manda COMPLETA en su propia llamada atómica: 'new-tab' enfoca la
  # nueva pestaña y sus splits se aplican en la MISMA llamada ⇒ nunca se fugan.
  for ((t=0;t<ntabs;t++)); do
    s=${starts[$t]}; e=${ends[$t]}; seg=()
    for ((i=s;i<e;i++)); do seg+=("${A[$i]}"); done
    [ "$t" -gt 0 ] && sleep "$SETTLE"
    WT "${WINREF[@]}" "${seg[@]}"
  done
else
  # FASE 1: todas las pestañas con su primer panel, en UNA llamada atómica.
  pass1=()
  for ((t=0;t<ntabs;t++)); do
    s=${starts[$t]}; e=${ends[$t]}; sp=${splitat[$t]}
    headEnd=$e; [ "$sp" -ge 0 ] && headEnd=$sp
    [ "$t" -gt 0 ] && pass1+=(";")
    for ((i=s;i<headEnd;i++)); do pass1+=("${A[$i]}"); done
  done
  WT "${WINREF[@]}" "${MAXFLAG[@]}" "${pass1[@]}"

  # settle: esperar UNA vez a que la ventana + pestañas existan.
  sleep "$SETTLE"

  # FASE 2: subdividir cada pestaña fijándola por índice (orden-independiente).
  for ((t=0;t<ntabs;t++)); do
    sp=${splitat[$t]}; e=${ends[$t]}
    [ "$sp" -ge 0 ] || continue
    seg=(focus-tab -t "$t")
    for ((i=sp;i<e;i++)); do seg+=("${A[$i]}"); done
    sleep "$DELAY"
    WT "${WINREF[@]}" "${seg[@]}"
  done
fi
