# shell-integration.sh — ayudas visuales por comando para Windows Terminal:
#   • Marcas OSC 133 en la barra de scroll (ROJO si el comando falló) + saltar con Ctrl+Shift+↑/↓.
#   • Indicador por comando antes del prompt, con 3 modos:
#       compact (por defecto) → una línea chica:  ── ✓ 15:36   (✗ rojo si falló)
#       full                  → divisor de ancho completo + ✓/✗ + el último comando + hora
#       off                   → nada (solo las marcas de la barra de scroll)
#   Cambiar el modo:  lay blocks off | compact | full   (o edita .layconfig).
# Solo se activa dentro de Windows Terminal y en shell interactivo.
if [[ $- == *i* && -n "${WT_SESSION:-}" ]]; then

  # preferencia: env > .layconfig > compact
  if [ -z "${LAY_BLOCKS:-}" ] && [ -f "$LAYOUTS_DIR/.layconfig" ]; then . "$LAYOUTS_DIR/.layconfig"; fi
  : "${LAY_BLOCKS:=compact}"

  __wt_dcode() { local e=$?; printf '\e]133;D;%s\a' "$e"; return $e; }

  __lay_block_compact() {
    local e=$?
    printf '\e[38;5;238m──\e[0m '
    if [ "$e" -eq 0 ]; then printf '\e[32m✓\e[0m'; else printf '\e[1;31m✗ %s\e[0m' "$e"; fi
    printf ' \e[2m%s\e[0m\n' "$(date +%H:%M)"
  }

  __lay_block_full() {
    local e=$? cols line cmd
    cols=$(tput cols 2>/dev/null || echo 80)
    printf -v line '%*s' "$cols" ''; line=${line// /─}
    printf '\e[38;5;238m%s\e[0m\n' "$line"
    cmd=$(history 1 2>/dev/null | sed 's/^[[:space:]]*[0-9]\{1,\}[[:space:]]*//')
    if [ "$e" -eq 0 ]; then printf '\e[1;32m✓\e[0m'; else printf '\e[1;31m✗ %s\e[0m' "$e"; fi
    [ -n "$cmd" ] && printf ' \e[2m%s\e[0m' "$cmd"
    printf ' \e[2m· %s\e[0m\n' "$(date +%H:%M:%S)"
  }

  case "$PS1" in
    *'133;A'*) : ;;
    *) PS1='\[\e]133;A\a\]'"$PS1"'\[\e]133;B\a\]' ;;
  esac

  case "$LAY_BLOCKS" in
    off)  _lay_pc='__wt_dcode' ;;
    full) _lay_pc='__wt_dcode; __lay_block_full' ;;
    *)    _lay_pc='__wt_dcode; __lay_block_compact' ;;
  esac
  case ";${PROMPT_COMMAND:-};" in
    *__wt_dcode*) : ;;
    *) PROMPT_COMMAND="${_lay_pc}${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
  unset _lay_pc
fi
