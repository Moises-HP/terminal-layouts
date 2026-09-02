#!/usr/bin/env bash
# backup.sh — respaldar / mover tus layouts entre PCs.
#
#   sh backup.sh export [archivo.tgz]   empaqueta TODOS los configs (+README) en un .tgz
#   sh backup.sh import <archivo.tgz>   restaura los configs de un respaldo y regenera atajos
#
# Para qué sirve: llevar tus layouts a otra máquina, o guardar una copia de seguridad.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; CFG="$HERE/configs"
mode="${1:-}"
case "$mode" in
  export)
    out="${2:-$HERE/layouts-backup.tgz}"
    tar -czf "$out" -C "$HERE" configs README.md
    echo "📦 respaldo → $out  ($(ls -1 "$CFG"/*.toml 2>/dev/null | wc -l | tr -d ' ') layouts)"
    echo "   En la otra PC (dentro de terminal-layouts):  sh backup.sh import \"$out\"" ;;
  import)
    src="${2:-}"; [ -f "$src" ] || { echo "uso: sh backup.sh import <archivo.tgz>"; exit 1; }
    tar -xzf "$src" -C "$HERE"
    for f in "$CFG"/*.toml; do [ -e "$f" ] && sh "$HERE/new.sh" "$(basename "$f" .toml)" >/dev/null; done
    echo "✅ configs restaurados + atajos regenerados.  Revisa con: sh doctor.sh" ;;
  bundle)
    # Empaqueta TODA la carpeta (scripts + configs) para dárselo a un compañero.
    out="${2:-$(cd "$HERE/.." && pwd)/terminal-layouts-bundle.tgz}"
    (cd "$HERE/.." && tar --exclude='terminal-layouts/*.tgz' --exclude='terminal-layouts/.last' -czf "$out" terminal-layouts)
    echo "📦 bundle → $out   (toda la carpeta, lista para compartir)"
    echo "   Tu compañero: descomprímelo en ~/Documents/GitHub/Proyectos/  y corre:  sh terminal-layouts/install.sh" ;;
  *) echo "uso: sh backup.sh export [arch] | import <arch> | bundle [arch]"; exit 1 ;;
esac
