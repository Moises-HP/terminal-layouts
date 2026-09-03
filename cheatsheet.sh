#!/usr/bin/env bash
# cheatsheet.sh — referencia rápida de comandos (IAs + layouts). Imprime y deja
# una terminal lista para usarlos.  Uso: sh cheatsheet.sh  (o doble clic cheatsheet.cmd)
B=$'\e[1m'; D=$'\e[2m'; C=$'\e[36m'; Y=$'\e[33m'; G=$'\e[32m'; M=$'\e[35m'; R=$'\e[0m'

cat <<EOF

${B}${C}╔══════════════════════════════════════════════════════════════════╗${R}
${B}${C}║   CHEATSHEET — IAs + Terminal Layouts                             ║${R}
${B}${C}╚══════════════════════════════════════════════════════════════════╝${R}

${B}${Y}▶ Claude Code${R}   ${D}(instalado)${R}
   ${G}claude${R}                                    abrir nuevo
   ${G}claude --resume${R}  ${D}( -r )${R}                    elegir sesión previa
   ${G}claude --continue${R} ${D}( -c )${R}                   seguir la última sesión
   ${G}claude --dangerously-skip-permissions${R}     sin pedir permisos
   ${G}claude -r --dangerously-skip-permissions${R}   ${D}← el de los layouts 'claude-*'${R}
   ${G}claude --model opus${R} / ${G}--model sonnet${R}       elegir modelo
   ${D}dentro: /help  /clear  /resume  /model  /agents  /skills${R}

${B}${Y}▶ Otras IAs${R}   ${D}(instaladas)${R}
   ${G}codex${R}                                     OpenAI Codex CLI
   ${G}gemini${R}                                    Google Gemini CLI
   ${G}qwen${R}                                      Qwen Code CLI
   ${D}antigravity = IDE de Google, no CLI de terminal (no instalado aquí)${R}

${B}${Y}▶ Terminal Layouts — comando ${G}lay${R}   ${D}(desde cualquier carpeta)${R}
   ${G}lay${R}                       menú (elige cuáles abrir; incluye combos)
   ${G}lay dev tunnels${R}           abrir esos (tabs)   ${D}·${R}  ${G}lay all${R}  todos
   ${G}lay add <x>${R}               a la ventana actual ${D}·${R}  ${G}lay last${R}  lo último
   ${G}lay term${R}                  una terminal normal (sin layout)
   ${G}lay new|wiz|grid <x>${R}      crear (plantilla / asistente / 1 línea)
   ${G}lay preview <x>${R}           ver la rejilla en ASCII
   ${G}lay edit|dup|rename|rm <x>${R}  editar / duplicar / renombrar / borrar
   ${G}lay combo <n> a b…${R}        guardar combo  ${D}·${R}  ${G}lay rm combo-<n>${R}
   ${G}lay pin [all|<x>]${R}         accesos Escritorio/Inicio (anclar a la barra)
   ${G}lay ls${R} ${D}[-l]${R}  ${D}·${R}  ${G}lay doctor${R}  ${D}·${R}  ${G}lay blocks off|compact|full${R}  ${D}·${R}  ${G}lay -h${R}

${B}${Y}▶ Atajos de teclado (Windows Terminal)${R}
   ${G}Ctrl+Shift+T${R}   tab nuevo en el MISMO directorio
   ${G}Ctrl+Shift+D/E${R} dividir panel a la derecha / abajo (misma carpeta)
   ${G}Alt+flechas${R}    mover foco  ${D}·${R}  ${G}Ctrl+Alt+flechas${R}  reacomodar panel
   ${G}Ctrl+Shift+↑/↓${R} saltar entre comandos  ${D}·${R}  ${G}Ctrl+Shift+W${R}  cerrar panel

${B}${Y}▶ Atajos útiles${R}
   ${G}bun i${R} · ${G}bun dev${R} · ${G}bun start:dev${R}          node/bun
   ${G}docker compose up -d --build${R}              levantar stack
   ${G}tunnels sync && tunnels up${R}                túneles
   ${D}aliases IA: ${R}${G}cr${R}${D} = claude resume, ${R}${G}csp cc cx gm qw${R}
   ${D}pegar imagen en Claude: ${R}${G}Alt+V${R}${D} (Win+Shift+S para capturar). Respaldo: ${R}${G}img${R}

EOF

exec bash -l
