# ai-aliases.sh — atajos para IAs y layouts, usables desde CUALQUIER carpeta.
#
# Activar (una sola vez): añade a ~/.bashrc un 'source' a ESTE archivo (donde lo tengas)
# y recarga. install.sh lo hace por ti con la ruta correcta. Ejemplo:
#     source /ruta/a/terminal-layouts/ai-aliases.sh
#     source ~/.bashrc

# ── Claude Code ──────────────────────────────────────────────────────────────
alias cr='claude --resume --dangerously-skip-permissions'     # elegir sesión, sin permisos
alias cc='claude --continue --dangerously-skip-permissions'   # seguir la última
alias csp='claude --dangerously-skip-permissions'             # nuevo, sin permisos
alias cl='claude'

# ── Otras IAs ────────────────────────────────────────────────────────────────
alias cx='codex'
alias gm='gemini'
alias qw='qwen'
# imagen del portapapeles → @ruta para pegar en la IA (Alt+Shift captura, luego 'img')
alias img='sh "$LAYOUTS_DIR/clip-img.sh"'

# ── Terminal Layouts: un solo comando 'lay' con subcomandos ─────────────────
#   lay            menú          lay <a> <b>    abrir esos (nueva ventana)
#   lay add <a>    a la actual   lay all        todos
#   lay new <n>    crear         lay wiz        asistente rejilla
#   lay combo ...  guardar combo lay cheat      cheatsheet     lay ls  listar
# Se auto-localiza: funciona esté donde esté la carpeta (útil para compañeros).
LAYOUTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lay() { sh "$LAYOUTS_DIR/lay.sh" "$@"; }

# Autocompletado con Tab: 'lay <TAB>' → subcomandos + layouts ; 'lay add <TAB>' → layouts
_lay_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local subs="menu add all last term new wiz grid preview edit dup rename rm combo export import bundle pin setup ls doctor blocks shell base img cheat help"
  local layouts; layouts="$(ls -1 "$LAYOUTS_DIR/configs"/*.toml 2>/dev/null | sed 's#.*/##; s#\.toml$##')"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$subs $layouts" -- "$cur") )
  else
    COMPREPLY=( $(compgen -W "$layouts" -- "$cur") )
  fi
}
complete -F _lay_complete lay 2>/dev/null || true

# Integración de shell: marcas de comandos + errores en rojo en la barra de scroll.
[ -f "$LAYOUTS_DIR/shell-integration.sh" ] && . "$LAYOUTS_DIR/shell-integration.sh"
