#!/usr/bin/env bash
# install.sh — deja ESTA PC lista para usar el sistema de layouts. Idempotente:
# puedes correrlo las veces que quieras. Para qué sirve: instalar todo de un jalón
# en una máquina nueva (o reparar la config).
#
# Hace 3 cosas:
#   1) Configura Windows Terminal (perfiles Git Bash + Layouts + atajos)  → wt-setup.mjs
#   2) Activa los aliases/comando 'lay' en ~/.bashrc
#   3) Regenera los atajos .sh/.cmd de todos los layouts                  → doctor.sh --fix
#
#   sh install.sh
set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/platform.sh"
HERE="$(_lay_here)"
HERE_POSIX="$(cd "$(dirname "$0")" && pwd)"
OS="$(_lay_os)"

echo "▶ 0/3 Revisando requisitos…"
command -v node >/dev/null 2>&1 || {
  if [ "$OS" = "darwin" ]; then
    echo "⛔ Falta Node.js. Instálalo: brew install node  (o https://nodejs.org)"
  else
    echo "⛔ Falta Node.js. Instálalo: https://nodejs.org  y vuelve a correr."
  fi
  exit 1
}
if [ "$OS" = "windows" ]; then
  command -v wt.exe >/dev/null 2>&1 || echo "⚠️  No encontré Windows Terminal (wt). Instálalo desde Microsoft Store."
  echo "✓ Git Bash: OK · Node: $(node -v)"
else
  echo "✓ macOS detectado · Node: $(node -v)"
  if [ -d "/Applications/iTerm.app" ]; then echo "✓ iTerm2: OK (se usará para layouts)"
  else echo "ℹ️  iTerm2 no encontrado — se usará Terminal.app (sin soporte de splits, solo tabs)"; fi
fi

if [ "$OS" = "windows" ]; then
  echo "▶ 1/3 Configurando Windows Terminal…"
  node "$HERE/wt-setup.mjs"
else
  echo "▶ 1/3 macOS: no requiere configuración de terminal."
fi

echo "▶ 2/3 Activando el comando 'lay'…"
LINE="source \"$HERE_POSIX/ai-aliases.sh\""

# bash
BRC="$HOME/.bashrc"; touch "$BRC"
if grep -q 'ai-aliases.sh' "$BRC" 2>/dev/null; then
  echo "✓ ya estaba activado en ~/.bashrc"
else
  printf '\n# Terminal Layouts + IAs (lay, cr, csp, cx/gm/qw)\n%s\n' "$LINE" >> "$BRC"
  echo "✓ añadido a ~/.bashrc"
fi

# zsh (macOS default)
if [ "$OS" = "darwin" ]; then
  ZRC="$HOME/.zshrc"; touch "$ZRC"
  if grep -q 'ai-aliases.sh' "$ZRC" 2>/dev/null; then
    echo "✓ ya estaba activado en ~/.zshrc"
  else
    printf '\n# Terminal Layouts + IAs (lay, cr, csp, cx/gm/qw)\n%s\n' "$LINE" >> "$ZRC"
    echo "✓ añadido a ~/.zshrc"
  fi
fi

echo "▶ 3/3 Regenerando atajos de layouts…"
bash "$HERE/doctor.sh" --fix >/dev/null && echo "✓ atajos listos"

echo
if [ "$OS" = "darwin" ]; then
  echo "🎉 Listo. Abre una terminal NUEVA (o corre: source ~/.zshrc) y prueba:  lay -h"
else
  echo "🎉 Listo. Abre una terminal NUEVA (o corre: source ~/.bashrc) y prueba:  lay -h"
fi
