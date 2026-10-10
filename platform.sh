# platform.sh — deteccion de OS, sourceable por los demas scripts.
# Uso:  . "$HERE/platform.sh"   (o con SCRIPT_DIR)
#   _lay_os   → "darwin" | "windows"
#   _lay_here → ruta nativa del directorio del script que hizo source

_lay_os() {
  case "$(uname -s)" in
    Darwin*) echo "darwin" ;;
    *)       echo "windows" ;;
  esac
}

# pwd -W en Windows (ruta nativa para node/wt.exe), pwd normal en macOS/Linux.
_lay_here() {
  if [ "$(_lay_os)" = "windows" ]; then
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd -W
  else
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
  fi
}
