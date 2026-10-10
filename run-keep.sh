#!/usr/bin/env bash
# run-keep.sh — lanza una bash INTERACTIVA de verdad (con job control) y corre en ella
# el/los comando(s) del panel. Así el panel es una terminal normal: Ctrl+C detiene SOLO
# el comando y la terminal sigue viva (no se cierra ni pide "reiniciar").
# Uso: bash -l run-keep.sh "cmd1 && cmd2"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$#" -gt 0 ] && [ -n "$1" ] && export LAY_RUN="$*"
exec bash --rcfile "$HERE/run-keep-rc.sh" -i
