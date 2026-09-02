# shell-integration.sh — ayudas visuales por comando para Windows Terminal:
#   1) Marcas OSC 133 en la barra de scroll (ROJO si el comando falló) y saltar entre
#      comandos con Ctrl+Shift+↑ / Ctrl+Shift+↓.
#   2) Un "bloque" tipo Warp ANTES de cada prompt: línea divisoria tenue + ✓/✗ del último
#      comando + su texto + la hora. Así ves de un vistazo qué corriste y si falló, sin
#      subir en la terminal.
#
# Desactivar solo el bloque visual:  export LAY_NO_BLOCKS=1   (antes de abrir la terminal)
# Solo se activa dentro de Windows Terminal y en shell interactivo.
if [[ $- == *i* && -n "${WT_SESSION:-}" ]]; then

  # (1) marca de fin de comando con su exit code → la marca se pinta roja si falló
  __wt_dcode() { local e=$?; printf '\e]133;D;%s\a' "$e"; return $e; }

  # (2) bloque visual: divisor + estado + último comando + hora
  __lay_block() {
    local e=$? cols line cmd
    cols=$(tput cols 2>/dev/null || echo 80)
    printf -v line '%*s' "$cols" ''; line=${line// /─}          # línea del ancho de la terminal
    printf '\e[38;5;238m%s\e[0m\n' "$line"
    cmd=$(history 1 2>/dev/null | sed 's/^[[:space:]]*[0-9]\{1,\}[[:space:]]*//')
    if [ "$e" -eq 0 ]; then printf '\e[1;32m✓\e[0m'; else printf '\e[1;31m✗ %s\e[0m' "$e"; fi
    [ -n "$cmd" ] && printf ' \e[2m%s\e[0m' "$cmd"
    printf ' \e[2m· %s\e[0m\n' "$(date +%H:%M:%S)"
  }

  case "$PS1" in
    *'133;A'*) : ;;                                              # ya aplicado
    *) PS1='\[\e]133;A\a\]'"$PS1"'\[\e]133;B\a\]' ;;             # A = inicio prompt, B = inicio input
  esac

  if [ -z "${LAY_NO_BLOCKS:-}" ]; then _lay_pc='__wt_dcode; __lay_block'; else _lay_pc='__wt_dcode'; fi
  case ";${PROMPT_COMMAND:-};" in
    *__wt_dcode*) : ;;
    *) PROMPT_COMMAND="${_lay_pc}${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
  unset _lay_pc
fi
