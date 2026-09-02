#!/usr/bin/env bash
# lay.sh — comando único para todo el sistema de layouts, usable desde CUALQUIER
# carpeta (vía la función 'lay' de ai-aliases.sh, o con ruta completa).
HERE="$(cd "$(dirname "$0")" && pwd -W)"   # ruta Windows (C:/...) para que node la lea bien
CFG="$HERE/configs"

help() {
  B=$'\e[1m'; C=$'\e[36m'; G=$'\e[32m'; D=$'\e[2m'; R=$'\e[0m'
  cat <<EOF
${B}${C}lay${R} — abre y administra tus layouts de terminal.

${B}Uso:${R} lay [comando] [argumentos]

${B}Abrir${R}
  ${G}lay${R}                      menú interactivo (elegir cuáles abrir)
  ${G}lay <a> <b> ...${R}          abrir esos layouts (1 ventana con tabs, maximizada)
  ${G}lay add <a> ...${R}          agregarlos como tab a la VENTANA ACTUAL
  ${G}lay all${R}                  abrir TODOS (vista MEGA)
  ${G}lay last${R}                 reabrir lo último que abriste
  ${G}lay term${R}                 abrir una terminal normal (Git Bash), sin layout

${B}Crear / administrar${R}
  ${G}lay new <nombre>${R}         crear layout (plantilla) + atajos
  ${G}lay wiz${R}                  asistente de rejilla (columnas x filas + carpeta/comando)
  ${G}lay grid <n> CxR <celda...>${R}  crear rejilla en 1 línea (celda = carpeta o carpeta|comando)
  ${G}lay preview <nombre>${R}     ver la rejilla en ASCII (sin abrir nada)
  ${G}lay edit <nombre>${R}        abrir el .toml en el editor (VS Code o Notepad)
  ${G}lay dup <origen> <nuevo>${R} duplicar un layout
  ${G}lay rename <viejo> <nuevo>${R}  renombrar un layout (+ sus atajos)
  ${G}lay rm <nombre>${R}          borrar un layout O un combo (combo-<n>) + sus atajos
  ${G}lay combo <n> <a> <b>${R}    guardar un conjunto como combo-<n>
  ${G}lay ls${R} ${D}[-l]${R}              listar layouts (${D}-l${R} = tabla con color, #paneles y carpeta)

${B}Respaldo / integración / instalación${R}
  ${G}lay export [archivo]${R}     empaquetar tus layouts (.tgz) para respaldo/otra PC
  ${G}lay import <archivo>${R}     restaurar layouts desde un respaldo
  ${G}lay bundle [archivo]${R}     empaquetar TODO (para dárselo a un compañero)
  ${G}lay pin${R} ${D}[all | <a>… | combo-x]${R}  accesos en Escritorio/Inicio para anclar a la barra
                           ${D}(sin args = menú; elige cuáles y dónde. También combos.)${R}
  ${G}lay setup${R}                (re)configurar Windows Terminal (perfiles + atajos + tema)

${B}Ayuda / diagnóstico${R}
  ${G}lay doctor${R} ${D}[--fix]${R}         revisar salud (carpetas, conversión, atajos); --fix regenera atajos
  ${G}lay blocks${R} ${D}off|compact|full${R}  indicador visual por comando (✓/✗); por defecto compact
  ${G}lay cheat${R}                cheatsheet (comandos de IAs + layouts)
  ${G}lay -h${R} / ${G}lay help${R}          esta ayuda

${D}Tip: otra terminal en la MISMA carpeta donde estás → Ctrl+Shift+D (al lado)
     o Ctrl+Shift+T (tab nuevo en el mismo directorio).${R}
EOF
}

need_name() { [ -n "${1:-}" ] || { echo "⛔ falta el nombre. Ver: lay -h"; exit 1; }; }
exists()    { [ -f "$CFG/$1.toml" ] || { echo "⛔ no existe el layout: $1  (lay ls)"; exit 1; }; }

sub="${1:-}"
case "$sub" in
  -h|--help|help) help ;;
  ''|menu|pick)   exec sh "$HERE/pick.sh" ;;
  add)            shift; exec sh "$HERE/add.sh" "$@" ;;
  new)            shift; exec sh "$HERE/new.sh" "$@" ;;
  wiz|wizard)     exec sh "$HERE/wizard.sh" ;;
  combo|save)     shift; exec sh "$HERE/savecombo.sh" "$@" ;;
  export)         shift; exec sh "$HERE/backup.sh" export "$@" ;;
  import)         shift; exec sh "$HERE/backup.sh" import "$@" ;;
  bundle)         shift; exec sh "$HERE/backup.sh" bundle "$@" ;;   # empaquetar para compañeros
  pin)            shift; exec sh "$HERE/pin.sh" "$@" ;;   # acceso en Inicio (para anclar)
  setup)          exec node "$HERE/wt-setup.mjs" ;;   # (re)configurar Windows Terminal
  cheat)          exec sh "$HERE/cheatsheet.sh" ;;
  doctor|check)   shift; exec sh "$HERE/doctor.sh" "$@" ;;   # acepta --fix
  grid)           shift; exec sh "$HERE/grid.sh" "$@" ;;
  blocks|ui)
    shift; cfg="$HERE/.layconfig"
    case "${1:-show}" in
      off|compact|full) printf 'LAY_BLOCKS=%s\n' "$1" > "$cfg"
        echo "✓ Indicador por comando: $1  (efectivo en terminales NUEVAS; en esta ahora: source ~/.bashrc)" ;;
      show) cur=compact; [ -f "$cfg" ] && cur="$(sed -n 's/^LAY_BLOCKS=//p' "$cfg")"
        echo "Indicador por comando: ${cur:-compact}"
        echo "  off     = nada (solo marcas en la barra de scroll)"
        echo "  compact = una línea chica: ── ✓ 15:36   (por defecto)"
        echo "  full    = divisor + ✓/✗ + último comando + hora"
        echo "Cambiar:  lay blocks off | compact | full" ;;
      *) echo "uso: lay blocks off | compact | full" ;;
    esac ;;
  term|terminal)  export MSYS_NO_PATHCONV=1; exec wt.exe -p "Git Bash" ;;
  all)            exec sh "$HERE/open.sh" ;;
  last)           [ -f "$HERE/.last" ] || { echo "Aún no hay 'último'. Abre algo primero."; exit 1; }
                  exec sh "$HERE/open.sh" $(cat "$HERE/.last") ;;
  ls|list)
    if [ "${2:-}" = "-l" ] || [ "${2:-}" = "--long" ]; then
      printf "%-27s %-8s %-7s %s\n" "LAYOUT" "COLOR" "PANELES" "1ª CARPETA"
      for f in "$CFG"/*.toml; do
        [ -e "$f" ] || continue; n="$(basename "$f" .toml)"
        color="$(grep -m1 '^color' "$f" | sed 's/.*=[ ]*"//; s/".*//')"
        panes="$(node "$HERE/toml2wt.mjs" "$f" 2>/dev/null | grep -c 'new-tab\|split-pane')"
        dir="$(grep -m1 '^directory' "$f" | sed 's/.*=[ ]*"//; s/".*//; s#/*$##; s#.*/##')"
        printf "%-27s %-8s %-7s %s\n" "$n" "${color:-—}" "$panes" "${dir:-—}"
      done
      for f in "$HERE"/combo-*.sh; do
        [ -e "$f" ] || continue; c="$(basename "$f" .sh | sed 's/^combo-//')"
        lays="$(sed -n 's#.*/open.sh" ##p' "$f")"
        printf "%-27s %-8s %-7s %s\n" "combo-$c" "combo" "—" "= $lays"
      done
    else
      ls -1 "$CFG"/*.toml 2>/dev/null | sed 's#.*/##; s#\.toml$##'
      for f in "$HERE"/combo-*.sh; do [ -e "$f" ] && echo "combo-$(basename "$f" .sh | sed 's/^combo-//')"; done
    fi ;;

  preview|show)
    shift; need_name "${1:-}"; exists "$1"
    export MSYS_NO_PATHCONV=1; node "$HERE/toml2wt.mjs" "$CFG/$1.toml" --preview ;;

  dup|copy)
    shift; need_name "${1:-}"; [ -n "${2:-}" ] || { echo "uso: lay dup <origen> <nuevo>"; exit 1; }
    exists "$1"; [ -e "$CFG/$2.toml" ] && { echo "⛔ ya existe: $2"; exit 1; }
    sed -e "s/^name *=.*/name = \"$2\"/" -e "s/^title *=.*/title = \"$2\"/" "$CFG/$1.toml" > "$CFG/$2.toml"
    sh "$HERE/new.sh" "$2" >/dev/null
    echo "📄 '$1' → '$2' (copiado + atajos). Ajusta el título con: lay edit $2" ;;

  edit)
    shift; need_name "${1:-}"; exists "$1"
    toml="$CFG/$1.toml"
    if command -v code >/dev/null 2>&1; then code "$toml"
    else notepad "$(cygpath -w "$toml" 2>/dev/null || echo "$toml")" & fi
    echo "✏️  abriendo configs/$1.toml…" ;;

  rename|mv)
    shift; need_name "${1:-}"; [ -n "${2:-}" ] || { echo "uso: lay rename <viejo> <nuevo>"; exit 1; }
    exists "$1"; [ -e "$CFG/$2.toml" ] && { echo "⛔ ya existe: $2"; exit 1; }
    mv "$CFG/$1.toml" "$CFG/$2.toml"
    sed -i -e "s/^name *=.*/name = \"$2\"/" "$CFG/$2.toml"
    rm -f "$HERE/$1.sh" "$HERE/$1.cmd"
    sh "$HERE/new.sh" "$2" >/dev/null
    echo "🔁 '$1' → '$2' (renombrado + atajos). Ajusta el 'title' con: lay edit $2" ;;

  rm|remove|del)
    shift; need_name "${1:-}"; c="${1#combo-}"
    if [ -f "$CFG/$1.toml" ]; then
      printf "Borrar layout '%s' (.toml + atajos) [y/N]: " "$1"; read -r ans
      case "$ans" in y|Y|s|S) rm -f "$CFG/$1.toml" "$HERE/$1.sh" "$HERE/$1.cmd"; echo "🗑️  layout '$1' eliminado." ;; *) echo "Cancelado." ;; esac
    elif [ -f "$HERE/combo-$c.sh" ]; then
      printf "Borrar combo '%s' [y/N]: " "$c"; read -r ans
      case "$ans" in y|Y|s|S) rm -f "$HERE/combo-$c.sh" "$HERE/combo-$c.cmd"; echo "🗑️  combo '$c' eliminado." ;; *) echo "Cancelado." ;; esac
    else echo "⛔ no existe layout ni combo: $1  (lay ls)"; exit 1; fi ;;

  *)  exec sh "$HERE/open.sh" "$@" ;;   # uno o varios nombres → abrir
esac
