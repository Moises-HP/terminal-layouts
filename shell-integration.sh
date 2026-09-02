# shell-integration.sh — integración de shell (secuencias OSC 133) para Windows Terminal.
#
# Para qué sirve: WT "marca" cada comando que corres. Con eso obtienes:
#   • un punto en la barra de scroll por cada comando, ROJO si ese comando FALLÓ
#     (exit code ≠ 0) → feedback visual de que algo tronó, sin leer todo.
#   • saltar entre comandos con Ctrl+Shift+↑ / Ctrl+Shift+↓ (vas al inicio de cada
#     comando anterior/siguiente, aunque haya escupido mucho output).
#
# (Nota: no es el "bloque sticky" de Warp — WT no lo trae — pero es el equivalente
#  nativo para ubicar y saltar a cada comando y ver cuáles fallaron.)
#
# Solo se activa dentro de Windows Terminal y en shell interactivo.
if [[ $- == *i* && -n "${WT_SESSION:-}" ]]; then
  __wt_dcode() { local e=$?; printf '\e]133;D;%s\a' "$e"; return $e; }   # fin de comando + exit code
  case ";${PROMPT_COMMAND:-};" in
    *__wt_dcode*) : ;;
    *) PROMPT_COMMAND="__wt_dcode${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
  case "$PS1" in
    *'133;A'*) : ;;                                   # ya aplicado, no duplicar
    *) PS1='\[\e]133;A\a\]'"$PS1"'\[\e]133;B\a\]' ;;  # A = inicio prompt, B = inicio input
  esac
fi
