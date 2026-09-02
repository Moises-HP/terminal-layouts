#!/usr/bin/env bash
# doctor.sh — chequeo de salud de todos los layouts: que conviertan, que sus
# carpetas existan, y que tengan sus atajos .sh/.cmd. (lay doctor)
set -uo pipefail
export MSYS_NO_PATHCONV=1
HERE="$(cd "$(dirname "$0")" && pwd -W)"
CFG="$HERE/configs"
G=$'\e[32m'; Y=$'\e[33m'; Rd=$'\e[31m'; D=$'\e[2m'; R=$'\e[0m'
FIX=0; [ "${1:-}" = "--fix" ] && FIX=1

echo "🩺 Revisando layouts en configs/${FIX:+ }$([ "$FIX" = 1 ] && echo '(--fix: regenerando atajos faltantes)')"
echo
total=0; prob=0
for f in "$CFG"/*.toml; do
  [ -e "$f" ] || continue
  n="$(basename "$f" .toml)"; total=$((total+1))
  if [ "$FIX" = 1 ] && { [ ! -f "$HERE/$n.sh" ] || [ ! -f "$HERE/$n.cmd" ]; }; then
    sh "$HERE/new.sh" "$n" >/dev/null 2>&1
  fi
  errf="$(mktemp)"
  out="$(node "$HERE/toml2wt.mjs" "$f" 2>"$errf")"
  err="$(cat "$errf")"; rm -f "$errf"
  panes=$(printf '%s' "$out" | grep -c 'new-tab\|split-pane')
  sh_ok=$([ -f "$HERE/$n.sh" ]  && echo "sh"  || echo "${Y}sin-sh${R}")
  cmd_ok=$([ -f "$HERE/$n.cmd" ] && echo "cmd" || echo "${Y}sin-cmd${R}")

  if [ -z "$out" ]; then
    printf "${Rd}✗ %-26s NO convierte${R}\n" "$n"; prob=$((prob+1))
  elif [ -n "$err" ]; then
    printf "${Y}! %-26s${R} %s paneles · %s/%s\n" "$n" "$panes" "$sh_ok" "$cmd_ok"
    printf '%s\n' "$err" | sed "s/^/     ${Y}/; s/\$/${R}/"
    prob=$((prob+1))
  else
    printf "${G}✓ %-26s${R} %s paneles · %s/%s\n" "$n" "$panes" "$sh_ok" "$cmd_ok"
  fi
done

echo
echo "${D}combos:${R} $(ls -1 "$HERE"/combo-*.sh 2>/dev/null | sed 's#.*/combo-##; s#\.sh##' | tr '\n' ' ')"
echo
if [ "$prob" -eq 0 ]; then
  echo "${G}Todo sano 🎉  ($total layouts)${R}"
else
  echo "${Y}$total layouts · $prob con avisos.${R}  Arregla carpetas o corre 'lay new <n>' para atajos faltantes."
fi
