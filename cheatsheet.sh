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

${B}${Y}▶ Terminal Layouts${R}   ${D}(esta carpeta)${R}
   ${G}sh open.sh${R}                                MEGA: todos en tabs
   ${G}sh open.sh dev pos-deploys tunnels${R}        abrir SOLO esos (tabs, 1 ventana)
   ${G}sh pick.sh${R}                                menú para elegir cuáles
   ${G}sh new.sh <nombre>${R}                        crear layout nuevo (+ .sh/.cmd)
   ${G}sh <nombre>.sh${R}   /   doble clic ${G}<nombre>.cmd${R}   abrir uno
   ${D}layouts claude: ${R}${G}sh claude-pos-manager-repo.sh${R}${D}, ${R}${G}sh claude-github.sh${R}

${B}${Y}▶ Atajos útiles${R}
   ${G}bun i${R} · ${G}bun dev${R} · ${G}bun start:dev${R}          node/bun
   ${G}docker compose up -d --build${R}              levantar stack
   ${G}tunnels sync && tunnels up${R}                túneles
   ${D}¿aliases cortos (cr, csp, lay…)? → ver ai-aliases.sh${R}

EOF

exec bash -l
