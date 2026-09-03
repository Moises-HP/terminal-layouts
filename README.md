# 🪟 terminal-layouts

> **Layouts de terminal estilo Warp para Windows Terminal + Git Bash** — sin el consumo de GPU/RAM de Warp.

![Plataforma](https://img.shields.io/badge/plataforma-Windows-0078D6)
![Shell](https://img.shields.io/badge/shell-Git%20Bash-4EAA25)
![Node](https://img.shields.io/badge/requiere-Node.js-339933)
![Licencia](https://img.shields.io/badge/licencia-MIT-blue)

Define tus disposiciones de terminal (paneles, carpetas y comandos) en archivos **`.toml`**
—el mismo formato que los *tab configs* de Warp— y ábrelas con **un comando o un clic**.
Un convertidor en Node traduce cada `.toml` a comandos de `wt.exe`; agregar un layout =
agregar un `.toml`, sin tocar ningún script.

**¿Por qué?** Warp es cómodo pero su render por GPU consume 50–99% de GPU. Windows Terminal
es mucho más ligero. Esto te da la comodidad de los layouts de Warp —más un comando **`lay`**
para todo— sobre Windows Terminal.

## ✨ Características

- 🧩 **Layouts en `.toml`** — columnas/filas anidadas, con carpeta y comando por panel.
- 🚀 **Comando `lay`** — abrir, combinar en tabs, menú interactivo, crear, previsualizar en ASCII…
- 🎨 **Perfil + tema propios** en Windows Terminal (colores, títulos fijos por layout).
- ⌨️ **Atajos estilo Warp** — Ctrl+Shift+T/D/E, mover/reacomodar paneles, saltar entre comandos.
- 🩺 **Ayudas visuales** — panel activo resaltado, marcas por comando y **errores en rojo**.
- 🧙 **Asistente + `lay grid`** para armar rejillas en segundos.
- 📌 **Anclar a la barra de tareas** y accesos en el Escritorio.
- 💾 **Respaldo, portabilidad e instalador idempotente** (`install.cmd` de doble clic).

## ⚡ Instalación rápida

Requisitos: **Git Bash**, **Node.js** y **Windows Terminal**.

1. Clónalo donde quieras (en Git Bash):
   ```bash
   git clone https://github.com/Moises-HP/terminal-layouts.git
   ```
2. **Doble clic en `install.cmd`** *(o `sh install.sh`)*. El instalador funciona esté
   donde esté la carpeta.
3. Abre una terminal nueva y prueba: `lay -h`.

Guía completa para instalar/compartir: **[`INSTALL.md`](INSTALL.md)**. Licencia **MIT**.

> El repo trae **ejemplos** en `configs/example-*.toml`; crea los tuyos con `lay new` /
> `lay wiz` / `lay grid`. Tus `.toml` personales quedan **fuera de git** (ver `.gitignore`).
> Las tablas de más abajo muestran layouts del autor como referencia de lo que puedes armar.

## Uso

Con una terminal ya abierta (`sh`):

```bash
sh open.sh                       # MEGA: 1 ventana, 1 tab por layout (TODOS)
sh open.sh pos-deploys           # solo ese layout (1 ventana)
sh open.sh dev pos-deploys tunnels   # ESTOS 3 como tabs de UNA sola ventana ⭐
sh pos-deploys.sh                # atajo equivalente a: sh open.sh pos-deploys
```

Con **doble clic** (Explorador): abre el `.cmd` del layout — `all.cmd`,
`pos-deploys.cmd`, etc. (cada `.cmd` individual abre **una** ventana).

### Abrir varios juntos, eligiendo cuáles ⭐

Dos formas:

1. **Directo** — pasa los nombres que quieras a `open.sh`; se abren como **tabs en una
   sola ventana** (en el orden que los escribas):
   ```bash
   sh open.sh dev pos-deploys surveys-dev
   ```
2. **Menú interactivo** — `pick` te lista los layouts y eliges por número o nombre
   (ideal para no recordarlos). Con terminal abierta o **doble clic en `pick.cmd`**:
   ```bash
   sh pick.sh
   #  Layouts disponibles:
   #    1) databases   2) dev   3) layouts   4) pos-deploys ...
   #  > 2 4 8              ← escribes números o nombres (o 'all')
   #  Abriendo: dev pos-deploys tunnels
   ```

> Diferencia clave: los `.cmd`/`.sh` **individuales** = 1 layout = 1 ventana.
> `open.sh a b c` (o `pick`) = **varios layouts = 1 ventana con tabs**.

### ¿Otra terminal donde ya estoy? / ¿desde cualquier carpeta?

- **Otra terminal en la MISMA carpeta donde estás parado** (ej. estás en
  `database_manager_package` y quieres otra ahí): **Ctrl+Shift+D** → divide a la
  derecha, en la misma carpeta, al instante. Sin scripts. (Ctrl+Shift+E = abajo.)
- **Un layout desde cualquier carpeta**: usa el comando **`lay`** (ya activado):
  - `lay add databases` → lo mete como tab a tu **ventana actual**.
  - `lay databases` → ventana nueva.
  - `sh open.sh …` / `sh add.sh …` "pelados" **solo** funcionan si estás parado en
    `terminal-layouts`; por eso existe `lay` (funciona desde donde sea).

> Ojo con la diferencia: `lay add databases` abre el **layout** `databases`
> (2 paneles: sucahersa + database_manager). Para una **terminal suelta en tu carpeta
> actual**, es **Ctrl+Shift+D**.

## Layouts actuales (`configs/*.toml`)

| Config | Título | Rejilla | Corre al abrir |
|---|---|---|---|
| `dev` | DESARROLLO | 1 panel · `~/Documents/GitHub` | — |
| `pos-dev` | POS_MANAGER | app / server (apilados) | `bun` dev |
| `pos-deploys` | POS_MANAGER-DEPLOYS | app/employees/server │ replay/process/pos_sync | — |
| `surveys-dev` | SURVEYS-DEV | smw / surveys-www │ sum | `npm run dev` |
| `surveys-deploys` | SURVEYS-DEPLOYS | emp_manager/emp_auth/sum │ srv_manager/portal/www/manager-www | — |
| `tunnels` | Tunnels | 1 panel · `~` con `tunnels sync && tunnels up` | tunnels |
| `databases` | DATABASES | sucahersa_database ×2 │ database_manager_package ×2 | — |
| `layouts` | TERMINAL-LAYOUTS | 1 panel · carpeta de estos scripts | — |
| `claude-pos-manager-repo` | CLAUDE · POS_REPO | 2 terminales (izq │ der) en `pos_manager_REPO` | `claude --resume` |
| `claude-github` | CLAUDE · GITHUB | 2 terminales (izq │ der) en `~/Documents/GitHub` | `claude --resume` |

Los paneles **quedan abiertos** aunque el comando termine (`run-keep.sh` hace
`exec bash` al final).

## Colores y títulos de los tabs

Cada layout tiene un **color de tab** y un **título fijo** para distinguirlos de un
vistazo (sobre todo en la vista MEGA):

| Layout | Color | | Layout | Color |
|---|---|---|---|---|
| dev | 🟢 verde | | surveys-deploys | 🟠 naranja |
| pos-dev | 🟣 magenta | | tunnels | 🔵 azul |
| pos-deploys | 🔴 rojo | | databases | 🟪 morado |
| surveys-dev | 🟦 cian | | layouts | 🟡 amarillo |
| claude-pos-manager-repo | 🟧 coral | | claude-github | 🟩 teal |

(deploys en tonos cálidos 🔴🟠 = "producción, ojo".)

- **Cambiar color/título:** edita `color` / `title` en el `.toml` y **relanza** — no
  hay que regenerar `.sh`/`.cmd` (el color/título se leen del toml al abrir).
- `color` acepta: `green magenta blue red yellow cyan orange purple` o un `#hex`.
- El título se queda **fijo** (no lo pisa el `cwd` de bash) gracias al perfil de WT
  **"Layouts"** (Git Bash + `suppressApplicationTitle`, oculto del menú). Tu perfil
  Git Bash normal no cambia (sigue mostrando el `cwd`).

## Ayudas: IAs, cheatsheet y aliases

### Layouts de Claude (2 terminales izq │ der, reanudan sesión)
- `claude-pos-manager-repo` — 2 terminales en `pos_manager_REPO`, cada una con
  `claude --resume --dangerously-skip-permissions`.
- `claude-github` — igual pero en `~/Documents/GitHub`.
```bash
sh claude-github.sh          # o doble clic claude-github.cmd
```
Para abrir más, usa **Ctrl+Shift+D** (divide a la derecha, misma carpeta).

### Cheatsheet
Referencia rápida de comandos (Claude/codex/gemini/qwen + sistema de layouts):
```bash
sh cheatsheet.sh             # o doble clic cheatsheet.cmd
```

### Aliases y el comando `lay` (ya activado en `~/.bashrc`)
`ai-aliases.sh` da atajos usables **desde cualquier carpeta**:
- IAs: `cr` = `claude --resume --dangerously-skip-permissions`, `csp`, `cc`, y `cx`/`gm`/`qw` (codex/gemini/qwen).
- Layouts: el comando **`lay`** (un solo comando con subcomandos):

```bash
# Abrir
lay                 # menú (incluye 't' = terminal normal)
lay dev tunnels     # abrir esos (1 ventana con tabs)
lay add databases   # agregar como tab a la VENTANA ACTUAL
lay all             # todos (MEGA)      lay last   # reabrir lo último
lay term            # terminal normal (Git Bash), sin layout
# Crear / administrar
lay new <n>         # plantilla         lay wiz    # asistente de rejilla
lay grid <n> 2x2 <celda...>   # rejilla en 1 línea (celda = carpeta o carpeta|comando)
lay preview <n>     # ver la rejilla en ASCII (sin abrir nada) ⭐
lay edit <n>        # abrir .toml       lay dup <a> <b>   # duplicar
lay rename <a> <b>  # renombrar         lay rm <n>        # borrar
lay combo <n> ...   # guardar combo     lay ls [-l]       # listar (tabla con -l)
# Respaldo / integración / instalación
lay export [arch]   # empaquetar tus layouts (.tgz) para respaldo / otra PC
lay import <arch>   # restaurar layouts desde un respaldo
lay bundle [arch]   # empaquetar TODO (para dárselo a un compañero)
lay pin <a> ...     # crear acceso(s) en el menú Inicio (para anclar a la barra)
lay setup           # (re)configurar Windows Terminal (perfiles + atajos + tema + marcas)
# Ayuda / diagnóstico
lay doctor [--fix]  # salud (+ regenerar atajos)   lay cheat   lay -h
```

Ejemplos:
```bash
lay preview surveys-deploys          # dibuja la rejilla 3│4 en ASCII
lay grid api 2x2 backend "frontend|npm run dev" db "worker|bun dev"
```

- El **menú** (`lay` sin args) también lista **`t) terminal normal`** además de tus layouts.
- **Tab‑completion**: `lay <TAB>` completa subcomandos y nombres de layout; `lay add <TAB>` completa layouts.
- **`lay doctor`** revisa que todos conviertan, que sus **carpetas existan** y que tengan
  atajos. Además, al abrir, si un layout apunta a una **carpeta inexistente** verás un
  aviso `⚠️` (es la causa típica del error `0x80070057`).

Ya está activo (se añadió `source .../ai-aliases.sh` a tu `~/.bashrc`). En terminales
nuevas funciona solo; en una abierta: `source ~/.bashrc`. (Para desactivar, quita esa
línea del `~/.bashrc`.)

> Flag correcto: `--dangerously-skip-permissions` (en plural).
> CLIs disponibles aquí: `claude`, `codex`, `gemini`, `qwen`. (Antigravity es IDE, no CLI.)

## Atajos de teclado (estilo Warp)

Configurados en Windows Terminal (settings.json):

| Atajo | Acción |
|---|---|
| **Ctrl+Shift+T** | **tab nuevo en el MISMO directorio** donde estás (como Warp) |
| **Ctrl+Shift+D** | dividir panel a la **derecha** (misma carpeta) |
| **Ctrl+Shift+E** | dividir panel **abajo** (misma carpeta) |
| **Alt + ←/→/↑/↓** | mover el **foco** entre paneles |
| **Ctrl+Alt + ←/→/↑/↓** | **reposicionar** (swap) el panel en esa dirección |
| **Ctrl+Shift+W** | cerrar el panel |
| Alt+Shift+D | (nativo) duplicar panel automático |

Nota: **Ctrl+Shift+T** duplica el tab actual (hereda su carpeta) → una terminal nueva
justo donde estabas, en vez de abrir en `~`.

## Ayudas visuales: panel activo, bloques de comando y errores

Tres ayudas que quedan configuradas con `lay setup` (o `install.sh`):

**1) Distinguir el panel activo.** Al dividir la terminal, los paneles **inactivos se
atenúan** (fondo más oscuro) y el activo resalta. Así sabes de un vistazo en cuál estás
escribiendo. (Es `unfocusedAppearance` del perfil de WT.)

**2) Marcas de comando en la barra de scroll.** Cada comando que corres deja una
**marca** en la barra de scroll (derecha). Ubica dónde empezó cada comando aunque haya
escupido mucho texto. Saltar al comando anterior/siguiente: **Ctrl+Shift+↑ / Ctrl+Shift+↓**.

**3) Errores en rojo (marcas).** Con la *integración de shell* (`shell-integration.sh`),
la marca de un comando que **falla** (exit ≠ 0) se pinta **roja** en la barra de scroll.

**4) Indicador por comando (✓/✗).** Antes de cada prompt ves si el último comando
funcionó o falló. Configúralo con **`lay blocks off|compact|full`**:
- **compact** (por defecto): una línea chica → `── ✓ 15:36` (`✗` roja si falló).
- **full**: divisor de ancho completo + ✓/✗ + el **texto del último comando** + hora
  (útil para ubicar qué comando produjo qué, estilo bloques de Warp).
- **off**: nada (solo las marcas de la barra de scroll).

> Nota honesta: WT no tiene el "bloque sticky" de Warp (el comando pegado arriba mientras
> haces scroll) — no existe nativo. Esto (marcas + rojo si falló + bloque con ✓/✗ y el
> último comando) es el equivalente para ubicar qué comando produjo qué.

Se activan al abrir una terminal **nueva** (se cargan desde `~/.bashrc`). Si ya tienes una
abierta: `source ~/.bashrc`.

Sobre **arrastrar**: en Windows Terminal se **arrastran los TABS** (reordenar, o
sacarlos a otra ventana). Los **paneles** no se arrastran con el mouse como en Warp;
se reacomodan con **Ctrl+Alt+flechas** (swap). Es la forma equivalente.

## Agregar un tab a una ventana YA abierta

Por defecto cada `open.sh` abre una ventana nueva. Para **agregar** a la que ya tienes:

```bash
sh add.sh databases                  # agrega 'databases' como tab a tu ventana actual
sh add.sh dev tunnels                # agrega varios
# equivalente explícito:
sh open.sh -w last dev               # -w last = la última ventana usada
sh open.sh -w 0 dev                  # -w 0 = la ventana actual ; o -w <nombre>
```

`add.sh` = `open.sh -w last`. También sirve para meter un **combo** a la ventana actual.

## Combos: guardar conjuntos de layouts

Un combo = un atajo que abre **varios layouts juntos** (tabs, 1 ventana).

```bash
sh savecombo.sh deploys pos-deploys surveys-deploys tunnels
#   crea combo-deploys.sh y combo-deploys.cmd
sh combo-deploys.sh                  # o doble clic combo-deploys.cmd
sh add.sh pos-deploys surveys-deploys tunnels   # ...o mételo a la ventana actual
```

- `combo-<nombre>.sh/.cmd` = `open.sh <esos layouts>`.
- Los combos **también salen** en el menú `lay` y en `lay ls`; ábrelos con
  `lay combo-<nombre>` (o directo `sh combo-<nombre>.sh`) y ánclalos con `lay pin combo-<nombre>`.
- **Editar un combo:** `lay edit combo-<nombre>` abre un **editor interactivo** que muestra
  el combo numerado y lo modificas con acciones cortas (re-dibuja tras cada una):
  ```text
  +N / +nombre   agregar (N = nº de "Disponibles")
  -N             quitar la posición N
  m N M          mover la posición N a la posición M (reordenar)
  ok             guardar y salir      ·   q   cancelar
  ```
  Valida que los layouts existan y no deja guardar un combo vacío.
- **Borrar un combo:** `lay rm combo-<nombre>` (o `lay rm <nombre>` si es combo).
- Ejemplo ya creado: **`combo-deploys`** (pos-deploys + surveys-deploys + tunnels).

## Asistente para crear layouts (wizard)

En vez de escribir el `.toml` a mano, el wizard te pregunta **columnas × filas** y, por
cada celda, **carpeta + comando** (que es lo que siempre se termina haciendo):

```bash
sh wizard.sh                         # o doble clic wizard.cmd
#   Nombre, título, color, COLUMNAS, FILAS, y por celda: carpeta + comando
#   → genera configs/<nombre>.toml + <nombre>.sh/.cmd
```

- La **carpeta** relativa se cuelga de una **base** (por defecto tu carpeta de usuario `~`).
  Cámbiala con `lay base ~/ruta/a/tus/repos` para que al escribir `mi-proyecto` se vuelva
  `<base>/mi-proyecto`. Rutas con `~`, `/` o `C:` se usan tal cual.
- El **comando** es opcional (Enter = solo abrir la carpeta).
- El layout nuevo entra solo a `open.sh` / `pick` / `all`.

## Concepto clave: el "nombre" NO es una ruta

Cada layout tiene un **nombre** (ej. `mi-layout`). Ese nombre SIEMPRE significa el
archivo `configs/mi-layout.toml`. Nunca pasas una ruta; pasas el nombre y el sistema
le pega solo `configs/` + `.toml`:

```
sh open.sh mi-layout   →   abre   configs/mi-layout.toml
sh new.sh  mi-layout   →   trabaja sobre configs/mi-layout.toml
```

Regla: **`<nombre>` ⇄ `configs/<nombre>.toml`**. Por eso el nombre no puede llevar
espacios ni `/` (usa guiones: `mi-layout`).

## Crear un layout nuevo — paso a paso

Hay dos caminos. Los dos terminan igual (un `.toml` en `configs/`).

### Camino A — que `new.sh` te arme la plantilla

```bash
sh new.sh mi-layout
```

Eso hace **3 cosas**:
1. Crea `configs/mi-layout.toml` con una **plantilla** comentada (panel único +
   ejemplo de rejilla). Si el toml ya existía, NO lo toca.
2. Crea `mi-layout.sh`  → atajo que ejecuta `open.sh mi-layout`.
3. Crea `mi-layout.cmd` → atajo de **doble clic** (Explorador) que hace lo mismo.

Luego:
```bash
#  edita configs/mi-layout.toml   (pon tus carpetas y comandos)
sh open.sh mi-layout              # pruébalo  (o doble clic mi-layout.cmd)
```

### Camino B — tú escribes el `.toml` a mano

1. Crea el archivo `configs/mi-layout.toml` tú mismo (copia otro y edítalo).
2. (opcional) Genera los atajos `.sh`/`.cmd` para ese toml:
   ```bash
   sh new.sh mi-layout     # ve que el toml ya existe → lo respeta, solo hace los atajos
   ```
3. Pruébalo: `sh open.sh mi-layout`.

> Los atajos `.sh`/`.cmd` son **opcionales**: `sh open.sh mi-layout` funciona con
> solo tener el `.toml`. El `.cmd` sirve únicamente para poder abrirlo con doble clic.

## ¿Cómo se agrega solo a "all" (la vista MEGA)?

**No editas ningún script.** `sh open.sh` (o `all.cmd`) sin argumentos arma la lista así:

1. Primero mete los del **orden preferido** (variable `ORDER` en `open.sh`):
   `dev pos-dev pos-deploys surveys-dev surveys-deploys tunnels`.
2. Después recorre `configs/*.toml` y **agrega cualquier `.toml` que no esté en `ORDER`**,
   al final.

Es decir: en cuanto existe `configs/mi-layout.toml`, aparece **solo** como un tab más
en `sh open.sh` / `all.cmd`. Si quieres que salga en cierta posición (no al final),
agrega su nombre a `ORDER` en `open.sh`.

## Qué pasa por dentro cuando ejecutas `sh open.sh <nombre>`

```
sh open.sh mi-layout
   │
   ├─ resuelve  <nombre> → configs/mi-layout.toml
   │
   ├─ node toml2wt.mjs configs/mi-layout.toml
   │     └─ parsea el toml → arma el árbol de paneles →
   │        imprime los argumentos de wt.exe (new-tab / split-pane / move-focus …)
   │
   ├─ (si diste varios nombres, repite y une los tabs con ';')
   │
   └─ wt.exe <esos argumentos>   →   abre la ventana con la rejilla
```

Y `mi-layout.cmd` (doble clic) es solo: `bash -l open.sh mi-layout` → el mismo flujo.

## Formato del `.toml` (subset estilo Warp)

```toml
name  = "mi-layout"
title = "MI LAYOUT"        # título del tab
color = "green"            # green|magenta|blue|red|yellow|cyan|orange|purple o "#hex"

# --- Panel único ---
[[panes]]
id = "main"
directory = "~/proyectos/mi-proyecto"
commands = ["npm i", "npm run dev"]   # opcional; se unen con && ; el panel queda abierto
```

Ejemplos incluidos en `configs/`: `example-single`, `example-columns`, `example-grid-2x2`,
`example-shells` (mezcla bash/PowerShell/CMD).

Rejillas — se arman con contenedores (`split` + `children`) que apuntan a otros
paneles por `id`. **La raíz es el pane que nadie referencia en `children`.**

```toml
[[panes]]                  # raíz: 2 columnas
id = "root"
split = "horizontal"       # horizontal = COLUMNAS (izq | der)
children = ["left", "right"]

[[panes]]
id = "left"
split = "vertical"         # vertical = FILAS (arriba / abajo)
children = ["a", "b"]

[[panes]]
id = "right"
children = ["c"]           # 1 hijo = pasa directo

[[panes]]
id = "a"
directory = "~/proyectos/a"
commands = ["npm run dev"]
[[panes]]
id = "b"
directory = "~/proyectos/b"
[[panes]]
id = "c"
directory = "~/proyectos/c"
```

Regla de dirección (verificada con los configs reales de Warp):

| `split`        | dirección          | Windows Terminal |
|----------------|--------------------|------------------|
| `"horizontal"` | columnas (izq/der) | `-V`             |
| `"vertical"`   | filas (arr/abajo)  | `-H`             |

Notas del formato:
- `directory`: `~` = tu carpeta de usuario (`%USERPROFILE%`). También acepta rutas `C:/...`.
- `commands`: lista; se ejecutan en orden. Sin `commands` → solo abre el shell en la carpeta.
- `shell`: **el shell del panel** — `bash` (por defecto), `pwsh` (PowerShell 7),
  `powershell` (Windows PowerShell 5.1) o `cmd`. Puedes mezclar shells en un mismo layout.
  El comando `lay` y todo el sistema siguen igual; solo cambia en qué shell corre el panel.
  Para cambiar el shell por defecto de TODOS los paneles: `lay shell pwsh|powershell|cmd|bash`.
- Paneles **huérfanos** (definidos pero fuera del árbol de `children`) se ignoran, igual que en Warp.
- Anidación arbitraria soportada (columnas dentro de filas dentro de columnas…).

## Archivos

- `configs/*.toml` — **la fuente de verdad**. Edita/crea aquí.
- `toml2wt.mjs` — convertidor TOML → args de `wt.exe` (Node, sin dependencias).
- `open.sh` — motor: junta 1+ layouts en una ventana (un tab c/u). `sh open.sh [-w last] a b c`.
- `lay.sh` — comando único (`lay …`) usable desde cualquier carpeta (vía alias).
- `doctor.sh` — chequeo de salud de los layouts (`lay doctor`).
- `grid.sh` — crea una rejilla CxR en una línea (`lay grid`).
- `backup.sh` — export/import de layouts para respaldo/otra PC (`lay export`/`import`).
- `pin.sh` — crea accesos en el menú Inicio para anclar (`lay pin`).
- `install.sh` / `install.cmd` — deja una PC lista de un jalón (idempotente). `.cmd` = doble clic.
- `INSTALL.md` — guía corta de instalación para compañeros.
- `wt-setup.mjs` — configura WT (perfiles + atajos + tema de colores) idempotente (`lay setup`).
- `pick.sh` / `pick.cmd` — menú interactivo para **elegir cuáles** abrir juntos.
- `add.sh` — agrega layout(s) como tab a la **ventana actual** (`open.sh -w last`).
- `savecombo.sh` — guarda un conjunto → `combo-<nombre>.sh/.cmd`.
- `editcombo.sh` — editor interactivo de combos (`lay edit combo-<n>`).
- `wizard.sh` / `wizard.cmd` — asistente de rejilla (columnas×filas + carpeta/comando).
- `cheatsheet.sh` / `cheatsheet.cmd` — referencia rápida de comandos (IAs + layouts).
- `ai-aliases.sh` — comando `lay` + atajos IA (`cr`, `csp`…) + carga la integración de shell. Se auto-localiza.
- `shell-integration.sh` — marcas de comando + errores en rojo (OSC 133) para WT.
- `run-keep.sh` — corre el/los comando(s) del panel y deja un bash interactivo.
- `new.sh` — crea un `.toml` nuevo + su `.cmd`.
- `<layout>.sh` / `<layout>.cmd` — atajos (llaman a `open.sh <layout>`).
- `all.sh` / `all.cmd` — la vista MEGA (todos).

## Instalar / respaldar / mover a otra PC

**Para qué sirve:** dejar todo listo en una máquina nueva (o reparar la config), y
llevar tus layouts de una PC a otra.

**Instalar en una PC nueva** (idempotente — puedes repetirlo sin miedo):
```bash
sh install.sh
```
Hace 3 cosas: **1)** configura Windows Terminal (perfiles Git Bash + Layouts + atajos,
vía `wt-setup.mjs`), **2)** activa el comando `lay` en `~/.bashrc`, **3)** regenera los
atajos de todos los layouts. Requiere: Git Bash + Node + Windows Terminal.

**Mover tus layouts a otra PC** (respaldo):
```bash
lay export mis-layouts.tgz     # en la PC A: empaqueta todos los configs
#   copia el .tgz a la PC B (dentro de terminal-layouts) y ahí:
lay import mis-layouts.tgz     # en la PC B: restaura + regenera atajos
```

**Solo reconfigurar Windows Terminal** (si borraste un perfil o atajo):
```bash
lay setup      # = node wt-setup.mjs — solo AGREGA lo que falte, no borra nada
```

## Compartir con compañeros (que no hagan casi nada)

**Para qué sirve:** que un compañero tenga TODO esto (`lay`, atajos, tema, marcas) casi
sin esfuerzo.

**Tú (una vez):**
```bash
lay bundle          # crea ../terminal-layouts-bundle.tgz con TODA la carpeta
```
Pásale ese `.tgz` (o comparte la carpeta por git).

**Tu compañero (2 pasos)** — hay una guía lista para él en **`INSTALL.md`**:
1. Descomprime la carpeta `terminal-layouts` donde quiera.
2. **Doble clic en `install.cmd`** *(o: Git Bash ahí → `sh install.sh`)*.
3. Abre una terminal **nueva** → ya tiene `lay`, atajos, tema y marcas.

**Requisitos en su PC** (el `install.cmd` avisa si falta algo):
- Git para Windows / Git Bash — <https://git-scm.com/download/win>
- Node.js — <https://nodejs.org>
- Windows Terminal — Microsoft Store

**Nota:** los layouts que apuntan a repos tuyos (ej. `pos-deploys`) solo levantan bien si
tu compañero tiene esos repos en `~/Documents/GitHub/…`. Con `lay doctor` ve cuáles tienen
carpetas que faltan; puede borrarlos (`lay rm`) o crear los suyos (`lay wiz`/`lay grid`).
El **sistema** (`lay`, atajos, tema, marcas) funciona igual para todos.

## Anclar a la barra de tareas / accesos en el Escritorio

`lay pin` crea accesos directos (**"Layout &lt;n&gt;"** o **"Combo &lt;n&gt;"**) que apuntan a
`bash.exe` — por eso Windows **sí** te deja anclarlos a la barra (con un `.cmd` no se puede).

```bash
lay pin                    # menú: elige cuáles y DÓNDE (Escritorio / solo Inicio / ambos)
lay pin all                # TODOS los layouts (solo en Inicio, sin saturar el Escritorio)
lay pin dev pos-deploys    # esos (en Escritorio + Inicio)
lay pin --start dev        # solo Inicio  ·  --desktop = solo Escritorio  ·  --both = ambos
lay pin combo-deploys      # un COMBO: un acceso que levanta TODO el combo de un clic ⭐
```

- **Menú Inicio**: ⊞ Windows → escribe **`Layout`** (o **`Combo`**) → salen todos.
- **Escritorio**: doble clic en "Layout &lt;n&gt;" / "Combo &lt;n&gt;".
- **Anclar a la barra**: clic derecho en el acceso → en Windows 11 **"Mostrar más opciones"**
  → **"Anclar a la barra de tareas"** (o arrastra el acceso del Escritorio a la barra).

> Un **combo** anclado abre varios layouts como tabs de una ventana → con un clic levantas
> **todo** tu entorno. Crea combos con `lay combo <nombre> <a> <b> …` y ánclalos con `lay pin`.

## Shell de los paneles (bash / PowerShell / CMD)

Cada quien usa el shell que prefiera. El **comando `lay` y todo el sistema son iguales**
para todos (por debajo lo maneja Git Bash, invisible); lo que cambia es **en qué shell
abre cada panel**.

- **Por panel**, en el `.toml`:
  ```toml
  [[panes]]
  id = "srv"
  directory = "~/mi-proyecto"
  commands = ["npm run dev"]
  shell = "pwsh"        # bash (def.) · pwsh (PowerShell 7) · powershell (5.1) · cmd
  ```
- **Por defecto para todos los paneles** (si no ponen `shell` propio):
  ```bash
  lay shell pwsh        # o powershell / cmd / bash   ·   lay shell  = ver el actual
  ```

Los `commands` corren en ese shell y la terminal **queda abierta** (bash: `run-keep`;
PowerShell: `-NoExit`; cmd: `/k`). Puedes **mezclar** shells en un mismo layout.

## Apertura por etapas (evita el error `0x80070057`)

Windows Terminal a veces falla al crear **muchos paneles de golpe** con
`error 0x80070057 al iniciar bash.exe` (una carrera interna de ConPTY). Para evitarlo,
`open.sh` **no** abre todo en un disparo: manda varias llamadas a `wt.exe` a la misma
ventana, con una micro‑pausa. Modos (variable `LAY_STAGE`):

| `LAY_STAGE` | Qué hace | Velocidad |
|---|---|---|
| `auto` (por defecto) | Layouts chicos = 1 llamada (instantáneo). Layouts **densos** (más de `LAY_STAGE_MAX`=4 paneles) = **un panel por llamada** (a prueba de fallos). Varios layouts = un tab a la vez. | rápido |
| `pane` | Siempre un panel por llamada. Úsalo si algo **aún** falla. | lento pero infalible |
| `tab` | Un tab por llamada (no separa paneles dentro de un tab). | medio |
| `none` | Todo en un disparo (comportamiento viejo). | máximo, pero puede fallar |

Ejemplos (rara vez los necesitas — `auto` ya cubre casi todo):
```bash
LAY_STAGE=pane lay surveys-deploys     # blindaje total para un layout muy denso
LAY_STAGE=none lay dev                  # abrir de un jalón
LAY_STAGE_MAX=2 lay all                 # ser más agresivo (stage a partir de 3 paneles)
```

> Si un layout apunta a una **carpeta inexistente**, ese panel también da `0x80070057`.
> Revisa con `lay doctor` (te avisa cuáles faltan).

## Windows Terminal

Se añadió el perfil **Git Bash** (abre en `%USERPROFILE%`) como **perfil por
defecto**, y el perfil oculto **Layouts** (títulos fijos + **tema de colores propio**:
paleta oscura con acento coral). Respaldo del `settings.json` previo:
`…\WindowsTerminal_…\LocalState\settings.json.bak`.

El **tema de colores** vive en el esquema `"Layouts"` (schemes de WT) y se aplica solo
al perfil Layouts; tu Git Bash normal no cambia. Se (re)crea con `lay setup`.

## Gotchas `wt.exe` desde Git Bash (por si editas los scripts)

- `export MSYS_NO_PATHCONV=1` — evita que MSYS reescriba rutas `C:/...`.
- Rutas para node/wt en forma Windows: usar `pwd -W` (no `pwd`, que da `/c/...`).
- Delimitador de acciones de wt = `;` (aquí se emite como token propio en el array).
- Comandos multi-paso unidos con `&&`, **nunca `;`** (choca con el delimitador de wt).

## Requisitos (ya presentes)

`wt.exe` (Windows Terminal), Git Bash, `node`, y en PATH: `bun`, `npm`, `tunnels`.
