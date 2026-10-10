# terminal-layouts

Lanzadores de **Windows Terminal + Git Bash** que reemplazan los *tab configs* de
Warp. Warp usa render por GPU (50–99% GPU); Windows Terminal es mucho más ligero
→ menos presión de GPU/RAM.

> **Layouts de terminal estilo Warp para Windows Terminal + Git Bash** — sin el consumo de GPU/RAM de Warp.

**Todo se maneja con archivos `.toml`** (mismo formato que Warp). Un convertidor en
Node (`toml2wt.mjs`) los traduce a comandos `wt.exe`. Agregar un layout = agregar un
`.toml`. No hay que tocar scripts.

## ✨ Características

- 🧩 **Layouts en `.toml`** — columnas/filas anidadas, con carpeta y comando por panel.
- 🚀 **Comando `lay`** — abrir, combinar en tabs, menú interactivo, crear, previsualizar en ASCII…
- 🎨 **Perfil + tema propios** en Windows Terminal (colores, títulos fijos por layout).
- ⌨️ **Atajos estilo Warp** — Ctrl+Shift+T/D/E, mover/reacomodar paneles, saltar entre comandos.
- 🩺 **Ayudas visuales** — panel activo resaltado, marcas por comando y **errores en rojo**.
- 🧙 **Asistente + `lay grid`** para armar rejillas en segundos.
- 📌 **Anclar a la barra de tareas** y accesos en el Escritorio.
- 💾 **Respaldo, portabilidad e instalador idempotente** (`install.cmd` de doble clic).


## Uso

Con una terminal ya abierta (`sh`):

```bash
Con una terminal ya abierta (`sh`):

```bash
sh open.sh                 # MEGA: 1 ventana, 1 tab por layout (todos)
sh open.sh pos-deploys     # solo ese layout
sh open.sh dev surveys-dev # esos dos como tabs de una ventana
sh pos-deploys.sh          # atajo equivalente a: sh open.sh pos-deploys

sh open.sh                                   # MEGA: 1 ventana, 1 tab por layout (TODOS)
sh open.sh example-columns                   # solo ese layout (1 ventana)
sh open.sh example-columns example-grid-2x2 example-shells   # ESTOS 3 como tabs de UNA sola ventana ⭐
sh example-columns.sh                        # atajo equivalente a: sh open.sh example-columns
```

Con **doble clic** (Explorador): abre el `.cmd` del layout — `all.cmd`,
`pos-deploys.cmd`, `surveys-deploys.cmd`, etc. Pínchalos a la barra de tareas si
quieres accesos directos.

### Abrir varios juntos, eligiendo cuáles ⭐

Dos formas:

1. **Directo** — pasa los nombres que quieras a `open.sh`; se abren como **tabs en una
   sola ventana** (en el orden que los escribas):
   ```bash
   sh open.sh example-single example-columns example-grid-2x2
   ```
2. **Menú interactivo** — `pick` te lista los layouts y eliges por número o nombre
   (ideal para no recordarlos). Con terminal abierta o **doble clic en `pick.cmd`**:
   ```bash
   sh pick.sh
   #  Layouts disponibles:
   #    1) example-columns   2) example-grid-2x2   3) example-shells   4) example-single ...
   #  > 1 2 4              ← escribes números o nombres (o 'all')
   #  Abriendo: example-columns example-grid-2x2 example-single
   ```


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

Si `ORDER` se deja vacío, el orden final es simplemente **alfabético** sobre
`configs/*.toml`.

Es decir: en cuanto existe `configs/mi-layout.toml`, aparece **solo** como un tab más
en `sh open.sh` / `all.cmd`. Si quieres fijar cierta posición (no alfabética),
agrega los nombres que quieras a `ORDER` en `open.sh`: esos salen primero, en ese
orden, y el resto se añade alfabéticamente después.


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
# --- Panel único ---
[[panes]]
id = "main"
directory = "~/Documents/GitHub/mi-proyecto"   # o "~/proyectos/mi-proyecto"
commands = ["npm i", "npm run dev"]   # opcional; se unen con && ; el panel queda abierto

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
[[panes]]
id = "a"
directory = "~/Documents/GitHub/a"   # o "~/proyectos/a"
commands = ["npm run dev"]
[[panes]]
id = "b"
directory = "~/Documents/GitHub/b"   # o "~/proyectos/b"
[[panes]]
id = "c"
directory = "~/Documents/GitHub/c"   # o "~/proyectos/c"

```

Regla de dirección (verificada con los configs reales de Warp):

| `split`        | dirección          | Windows Terminal |
|----------------|--------------------|------------------|
| `"horizontal"` | columnas (izq/der) | `-V`             |
| `"vertical"`   | filas (arr/abajo)  | `-H`             |

Notas del formato:
- `directory`: `~` = tu home (`C:\Users\moise`). También acepta rutas `C:/...`.
- `commands`: lista; se ejecutan con `&&` en orden. Sin `commands` → solo abre el shell en la carpeta.
- `shell`: **el shell del panel** — `bash` (por defecto), `pwsh` (PowerShell 7),
  `powershell` (Windows PowerShell 5.1) o `cmd`. Puedes mezclar shells en un mismo layout.
  El comando `lay` y todo el sistema siguen igual; solo cambia en qué shell corre el panel.
  Para cambiar el shell por defecto de TODOS los paneles: `lay shell pwsh|powershell|cmd|bash`.

- Paneles **huérfanos** (definidos pero fuera del árbol de `children`) se ignoran, igual que en Warp.
- Anidación arbitraria soportada (columnas dentro de filas dentro de columnas…).

## Archivos

- `configs/*.toml` — **la fuente de verdad**. Edita/crea aquí.
- `toml2wt.mjs` — convertidor TOML → args de `wt.exe` (Node, sin dependencias).
- `configs/*.toml` — **la fuente de verdad**. Edita/crea aquí.
- `toml2wt.mjs` — convertidor TOML → args de `wt.exe` (Node, sin dependencias).
- `open.sh` — motor: junta 1+ layouts en una ventana (un tab c/u). `sh open.sh [-w last] a b c`.
- `run-keep.sh` — corre el/los comando(s) del panel y deja un bash interactivo.
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
- `run-keep.sh` + `run-keep-rc.sh` — abren una bash interactiva y corren ahí el comando
  del panel (Ctrl+C detiene solo el comando; la terminal sigue viva).
- `new.sh` — crea un `.toml` nuevo + su `.cmd`.
- `<layout>.sh` / `<layout>.cmd` — atajos (llaman a `open.sh <layout>`).
- `all.sh` / `all.cmd` — la vista MEGA (todos).

- `new.sh` — crea un `.toml` nuevo + su `.cmd`.
- `<layout>.sh` / `<layout>.cmd` — atajos (llaman a `open.sh <layout>`).
- `all.sh` / `all.cmd` — la vista MEGA (todos).

## Windows Terminal

Se añadió el perfil **Git Bash** (abre en `C:\Users\moise`) como **perfil por
defecto**. Respaldo del `settings.json` previo:
`…\WindowsTerminal_…\LocalState\settings.json.bak`.

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

## Gotchas `wt.exe` desde Git Bash (por si editas los scripts)

- `export MSYS_NO_PATHCONV=1` — evita que MSYS reescriba rutas `C:/...`.
- Rutas para node/wt en forma Windows: usar `pwd -W` (no `pwd`, que da `/c/...`).
- Delimitador de acciones de wt = `;` (aquí se emite como token propio en el array).
- Comandos multi-paso unidos con `&&`, **nunca `;`** (choca con el delimitador de wt).

## Requisitos (ya presentes)

`wt.exe` (Windows Terminal), Git Bash, `node`, y en PATH: los comandos que usen tus
paneles (por ejemplo `bun`, `npm`, `tunnels`).

