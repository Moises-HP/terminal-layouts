# run-keep-rc.sh — rcfile de la bash interactiva que abren los paneles con comando.
# Carga tu config normal (~/.bashrc → aliases, marcas, etc.) y, en el PRIMER prompt,
# corre el comando UNA vez dentro de la shell interactiva (con job control, para que
# Ctrl+C solo detenga el comando y la terminal siga funcionando normal).
[ -f ~/.bashrc ] && . ~/.bashrc

if [ -n "${LAY_RUN:-}" ]; then
  __lay_prev_pc="${PROMPT_COMMAND:-}"
  __lay_run_once() {
    PROMPT_COMMAND="$__lay_prev_pc"        # restaurar el prompt normal (marcas, etc.)
    unset -f __lay_run_once 2>/dev/null
    local c="$LAY_RUN"; unset LAY_RUN
    printf '\e[1;36m▶ %s\e[0m\n' "$c"      # mostrar qué comando corre (como si lo teclearas)
    eval "$c"
  }
  PROMPT_COMMAND="__lay_run_once"
fi
