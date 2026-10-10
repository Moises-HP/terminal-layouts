#!/usr/bin/env bash
# pin-mac.sh — crea accesos .command (doble clic en macOS) y opcionalmente
# los agrega al Dock. Equivalente macOS de pin.sh.
#
#   bash pin-mac.sh                      menú interactivo
#   bash pin-mac.sh all                  todos los layouts
#   bash pin-mac.sh example-columns      ese layout
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CFG="$HERE/configs"
DEST="$HOME/Desktop"

layouts() { for f in "$CFG"/*.toml; do [ -e "$f" ] && basename "$f" .toml; done; }
combos()  { for f in "$HERE"/combo-*.sh; do [ -e "$f" ] && basename "$f" .sh | sed 's/^combo-//'; done; }

items=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    all) while IFS= read -r n; do case "$n" in example-*) : ;; *) items+=("$n") ;; esac; done < <(layouts) ;;
    *)   items+=("$1") ;;
  esac
  shift
done

# Menú interactivo si no dieron items
if [ "${#items[@]}" -eq 0 ]; then
  names=(); while IFS= read -r n; do names+=("$n"); done < <(layouts)
  echo "Layouts:"; i=0
  for n in "${names[@]}"; do i=$((i+1)); printf "  %2d) %s\n" "$i" "$n"; done
  echo
  printf "¿Cuáles crear como .command? (números/nombres, 'all', Enter=cancelar): "
  read -r line
  [ -n "$(printf '%s' "$line" | tr -d ' ')" ] || { echo "Cancelado."; exit 0; }
  for tok in $line; do
    case "$tok" in
      all) items=("${names[@]}"); break ;;
      ''|*[!0-9]*) items+=("$tok") ;;
      *) idx=$((tok-1)); [ "$idx" -ge 0 ] && [ "$idx" -lt "${#names[@]}" ] && items+=("${names[$idx]}") ;;
    esac
  done
  echo "¿Dónde crear?"
  echo "  1) Escritorio (default)     2) Carpeta actual"
  printf "> "; read -r w
  case "$w" in 2) DEST="$(pwd)" ;; esac
fi

[ "${#items[@]}" -gt 0 ] || { echo "Nada que crear."; exit 1; }

made=0
for name in "${items[@]}"; do
  cname="${name#combo-}"
  if [ -f "$CFG/$name.toml" ]; then
    target="$DEST/Layout $name.command"
    cat > "$target" <<SCRIPT
#!/bin/bash
cd "\$(dirname "\$0")" 2>/dev/null
cd "$HERE" && bash open.sh $name
SCRIPT
  elif [ -f "$HERE/combo-$cname.sh" ]; then
    target="$DEST/Combo $cname.command"
    cat > "$target" <<SCRIPT
#!/bin/bash
cd "\$(dirname "\$0")" 2>/dev/null
cd "$HERE" && bash open.sh $(sed -n 's#.*/open.sh" ##p' "$HERE/combo-$cname.sh")
SCRIPT
  else
    echo "⚠️  no existe: $name (saltado)"; continue
  fi
  chmod +x "$target"
  echo "📌 $(basename "$target")"
  made=$((made+1))
done

[ "$made" -gt 0 ] || exit 1
echo
echo "Creados en $DEST. Doble clic para abrir."
echo "Para el Dock: arrastra el .command al Dock."
