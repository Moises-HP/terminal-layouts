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
HERE="$(cd "$(dirname "$0")" && pwd -W)"          # ruta Windows (para node)
HERE_POSIX="$(cd "$(dirname "$0")" && pwd)"        # ruta bash (para el source)

echo "▶ 0/3 Revisando requisitos…"
command -v node >/dev/null 2>&1 || { echo "⛔ Falta Node.js. Instálalo: https://nodejs.org  y vuelve a correr."; exit 1; }
command -v wt.exe >/dev/null 2>&1 || echo "⚠️  No encontré Windows Terminal (wt). Instálalo desde Microsoft Store si aún no lo tienes."
echo "✓ Git Bash: OK (estás en él) · Node: $(node -v)"

echo "▶ 1/3 Configurando Windows Terminal…"
node "$HERE/wt-setup.mjs"

echo "▶ 2/3 Activando el comando 'lay' en ~/.bashrc…"
LINE="source \"$HERE_POSIX/ai-aliases.sh\""        # usa ESTA ubicación (auto-localizada)
BRC="$HOME/.bashrc"; touch "$BRC"
if grep -q 'ai-aliases.sh' "$BRC" 2>/dev/null; then
  echo "✓ ya estaba activado"
else
  printf '\n# Terminal Layouts + IAs (lay, cr, csp, cx/gm/qw)\n%s\n' "$LINE" >> "$BRC"
  echo "✓ añadido a ~/.bashrc"
fi

echo "▶ 3/3 Regenerando atajos de layouts…"
sh "$HERE/doctor.sh" --fix >/dev/null && echo "✓ atajos listos"

echo
echo "🎉 Listo. Abre una terminal NUEVA (o corre: source ~/.bashrc) y prueba:  lay -h"
