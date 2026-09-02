# Instalar terminal-layouts (guía rápida)

Sistema de terminales de Windows Terminal con *layouts*, atajos de teclado y el comando
`lay` para abrir/crear/administrar todo. Esta guía es para dejarlo listo en tu PC.

## 1) Requisitos (instálalos primero si no los tienes)

- **Git para Windows** (incluye Git Bash) → https://git-scm.com/download/win
- **Node.js** → https://nodejs.org
- **Windows Terminal** → Microsoft Store (busca *"Windows Terminal"*)

## 2) Instalar (2 pasos)

1. Copia la carpeta **`terminal-layouts`** a:
   `C:\Users\TU_USUARIO\Documents\GitHub\Proyectos\`
2. **Doble clic en `install.cmd`**.
   *(o, si prefieres: abre Git Bash en esa carpeta y corre `sh install.sh`)*

Es **idempotente**: puedes correrlo las veces que quieras sin romper nada.

## 3) Usar

Abre una ventana **nueva** de Windows Terminal y escribe:

```bash
lay -h        # ayuda con todos los comandos
lay           # menú para elegir qué abrir
```

## ¿Qué te dejó instalado?

- El comando **`lay`** (funciona desde cualquier carpeta).
- Perfil **Git Bash** por defecto (abre en tu carpeta de usuario) + perfil **Layouts**
  con tema de colores propio.
- **Atajos**: Ctrl+Shift+T (tab en el mismo directorio), Ctrl+Shift+D (dividir a la
  derecha), Ctrl+Shift+E (dividir abajo), Alt+flechas (mover foco), Ctrl+Alt+flechas
  (reacomodar panel), Ctrl+Shift+↑/↓ (saltar entre comandos).
- **Ayudas visuales**: panel activo resaltado, marcas por comando y **errores en rojo**
  en la barra de scroll.

## Notas

- Algunos *layouts* de ejemplo apuntan a carpetas/repos específicos. Revisa cuáles con
  **`lay doctor`** (te avisa si falta una carpeta), bórralos con `lay rm <nombre>` o crea
  los tuyos con `lay wiz` / `lay grid`.
- ¿Los atajos no aparecen en una terminal ya abierta? Corre `source ~/.bashrc` o abre una
  terminal nueva.
