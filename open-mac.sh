#!/usr/bin/env bash
# open-mac.sh — abre layouts en macOS (iTerm2 o Terminal.app).
# Recibe nombres de layout ya resueltos (los resuelve open.sh antes de llamar aquí).
#
#   bash open-mac.sh layout1 layout2 ...
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HERE/configs"

# Detectar terminal: iTerm2 (preferido) o Terminal.app
if [ -d "/Applications/iTerm.app" ]; then
  TARGET="iterm"
else
  TARGET="terminal"
fi

names=("$@")
[ ${#names[@]} -gt 0 ] || { echo "uso: open-mac.sh <layout1> [layout2 ...]"; exit 1; }

first=1
for n in "${names[@]}"; do
  toml="$CFG/$n.toml"
  [ -f "$toml" ] || { echo "⛔ No existe configs/$n.toml"; exit 1; }

  flags=(--applescript "$TARGET")
  [ $first -eq 0 ] && flags+=(--tab)

  script="$(node "$HERE/toml2wt.mjs" "$toml" "${flags[@]}")"
  osascript -e "$script"

  first=0
  # Breve pausa entre layouts para que iTerm2 procese cada tab
  [ ${#names[@]} -gt 1 ] && sleep 0.5
done
