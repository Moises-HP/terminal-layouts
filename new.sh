#!/usr/bin/env bash
# new.sh <nombre> — prepara un layout llamado <nombre>:
#   • si NO existe configs/<nombre>.toml  -> crea una plantilla para editar
#   • si YA existe (lo escribiste tú)     -> lo respeta, NO lo toca
#   • en ambos casos (re)genera los atajos <nombre>.sh y <nombre>.cmd
#
# <nombre> es un NOMBRE, no una ruta. Siempre apunta a configs/<nombre>.toml.
#
#   sh new.sh mi-layout
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
name="${1:-}"
[ -n "$name" ] || { echo "uso: sh new.sh <nombre>"; exit 1; }
toml="$HERE/configs/$name.toml"

if [ -e "$toml" ]; then
  echo "ℹ️  configs/$name.toml ya existe → lo respeto, solo (re)genero atajos."
else
  cat > "$toml" <<'TPL'
# Layout nuevo. Formato tab-config estilo Warp.
#   split="horizontal" => columnas (izq | der)
#   split="vertical"   => filas (arriba / abajo)
# La raíz es el pane que NADIE referencia en 'children'.
name = "NOMBRE"
title = "TITULO"
color = "green"          # green|magenta|blue|red|yellow|cyan|orange|purple o #hex

# ── Panel único (borra el bloque de abajo si usas rejilla) ───────────────────
[[panes]]
id = "main"
type = "terminal"
directory = "~"
# commands = ["bun i", "bun run dev"]   # se unen con &&; el panel queda abierto
shell = "bash"

# ── Ejemplo rejilla 2 columnas (descomenta y borra el 'main' de arriba) ──────
# [[panes]]
# id = "root"
# split = "horizontal"
# children = ["left", "right"]
#
# [[panes]]
# id = "left"
# split = "vertical"
# children = ["a", "b"]
#
# [[panes]]
# id = "right"
# children = ["c"]
#
# [[panes]]
# id = "a"
# directory = "~/proyectos/proyecto-a"
# commands = ["npm run dev"]
#
# [[panes]]
# id = "b"
# directory = "~/proyectos/proyecto-b"
#
# [[panes]]
# id = "c"
# directory = "~/proyectos/proyecto-c"
TPL
  echo "✅ Creado configs/$name.toml (plantilla — edítalo)."
fi

# Atajos (opcionales; open.sh funciona sin ellos):
printf '#!/usr/bin/env bash\nexec sh "$(dirname "$0")/open.sh" %s\n' "$name" > "$HERE/$name.sh"
printf '@echo off\r\n"C:\\Program Files\\Git\\bin\\bash.exe" -l "%%~dp0open.sh" %s\r\n' "$name" > "$HERE/$name.cmd"
echo "✅ Atajos listos: $name.sh  y  $name.cmd (doble clic)."
echo
echo "Siguiente:"
echo "   1) edita  configs/$name.toml"
echo "   2) pruébalo:  sh open.sh $name   (o doble clic $name.cmd)"
echo "   (ya queda incluido automáticamente en 'sh open.sh' / all.cmd)"
