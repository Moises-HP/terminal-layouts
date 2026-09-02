#!/usr/bin/env node
// wt-setup.mjs — configura Windows Terminal para el sistema de layouts, de forma
// IDEMPOTENTE: solo AGREGA lo que falte, nunca borra. Sirve para dejar una PC nueva
// lista (perfiles + atajos de teclado) sin tocar a mano el settings.json.
//
// Asegura:
//   • perfil "Git Bash"  (perfil por defecto, abre en el home)
//   • perfil "Layouts"   (Git Bash + suppressApplicationTitle, oculto del menú)
//   • keybindings estilo Warp: Ctrl+Shift+T (tab en mismo dir), Ctrl+Shift+D/E
//     (dividir der/abajo), Alt+flechas (mover foco), Ctrl+Alt+flechas (swap), Ctrl+Shift+W.
//
//   node wt-setup.mjs
import fs from 'node:fs';

const LA = process.env.LOCALAPPDATA || '';
const CANDIDATES = [
  `${LA}\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState\\settings.json`,
  `${LA}\\Microsoft\\Windows Terminal\\settings.json`,
];
const path = CANDIDATES.find(p => fs.existsSync(p));
if (!path) { console.error('❌ No encontré settings.json de Windows Terminal. ¿Está instalado?'); process.exit(1); }

const j = JSON.parse(fs.readFileSync(path, 'utf8'));
const changes = [];

j.profiles = j.profiles || {};
j.profiles.list = j.profiles.list || [];
const list = j.profiles.list;
const CMD = '"C:\\Program Files\\Git\\bin\\bash.exe" -i -l';
const ICON = 'C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico';
const GITBASH = { guid: '{2ece5bfe-50ed-5f3a-ab87-5cd4baafed2b}', name: 'Git Bash', commandline: CMD, startingDirectory: '%USERPROFILE%', icon: ICON, hidden: false };
const LAYOUTS = { guid: '{7d3e9f2a-4b6c-5d8e-a1f0-3c9b2e7d5a10}', name: 'Layouts', commandline: CMD, startingDirectory: '%USERPROFILE%', icon: ICON, suppressApplicationTitle: true, hidden: true };
for (const p of [GITBASH, LAYOUTS]) {
  if (!list.some(x => x.guid === p.guid)) { list.push(p); changes.push('perfil ' + p.name); }
}
if (j.defaultProfile !== GITBASH.guid) { j.defaultProfile = GITBASH.guid; changes.push('perfil por defecto → Git Bash'); }

j.keybindings = j.keybindings || [];
const KB = [
  { keys: 'ctrl+shift+t', command: 'duplicateTab' },
  { keys: 'ctrl+shift+d', command: { action: 'splitPane', split: 'right', splitMode: 'duplicate' } },
  { keys: 'ctrl+shift+e', command: { action: 'splitPane', split: 'down', splitMode: 'duplicate' } },
  { keys: 'alt+left', command: { action: 'moveFocus', direction: 'left' } },
  { keys: 'alt+right', command: { action: 'moveFocus', direction: 'right' } },
  { keys: 'alt+up', command: { action: 'moveFocus', direction: 'up' } },
  { keys: 'alt+down', command: { action: 'moveFocus', direction: 'down' } },
  { keys: 'ctrl+alt+left', command: { action: 'swapPane', direction: 'left' } },
  { keys: 'ctrl+alt+right', command: { action: 'swapPane', direction: 'right' } },
  { keys: 'ctrl+alt+up', command: { action: 'swapPane', direction: 'up' } },
  { keys: 'ctrl+alt+down', command: { action: 'swapPane', direction: 'down' } },
  { keys: 'ctrl+shift+w', command: 'closePane' },
  { keys: 'ctrl+shift+up', command: { action: 'scrollToMark', direction: 'previous' } },
  { keys: 'ctrl+shift+down', command: { action: 'scrollToMark', direction: 'next' } },
];
for (const b of KB) {
  if (!j.keybindings.some(x => x.keys === b.keys)) { j.keybindings.push(b); changes.push('tecla ' + b.keys); }
}

// Tema de colores propio para el perfil "Layouts" (paleta oscura, acento coral Claude).
const SCHEME = {
  name: 'Layouts',
  background: '#0E1116', foreground: '#E6E6E6',
  cursorColor: '#D97757', selectionBackground: '#264F78',
  black: '#1B1F24', red: '#F87171', green: '#4ADE80', yellow: '#FBBF24',
  blue: '#60A5FA', purple: '#C084FC', cyan: '#22D3EE', white: '#D1D5DB',
  brightBlack: '#4B5563', brightRed: '#FCA5A5', brightGreen: '#86EFAC', brightYellow: '#FDE68A',
  brightBlue: '#93C5FD', brightPurple: '#D8B4FE', brightCyan: '#67E8F9', brightWhite: '#F9FAFB',
};
j.schemes = j.schemes || [];
if (!j.schemes.some(s => s.name === SCHEME.name)) { j.schemes.push(SCHEME); changes.push('esquema de color "Layouts"'); }
const lp = list.find(x => x.guid === LAYOUTS.guid);
if (lp && lp.colorScheme !== 'Layouts') { lp.colorScheme = 'Layouts'; changes.push('colorScheme del perfil Layouts'); }

// Marcas de comandos en la barra de scroll (rojas si el comando FALLÓ) + atenuar el
// panel inactivo para distinguir cuál está activo cuando hay varios divididos.
const gb = list.find(x => x.guid === GITBASH.guid);
for (const p of [gb, lp]) {
  if (!p) continue;
  if (p.showMarksOnScrollbar !== true) { p.showMarksOnScrollbar = true; changes.push('marcas de scroll en ' + p.name); }
  if (p.autoMarkPrompts !== true) { p.autoMarkPrompts = true; changes.push('autoMarkPrompts en ' + p.name); }
  if (!p.unfocusedAppearance) { p.unfocusedAppearance = { background: '#0A0C10' }; changes.push('panel inactivo atenuado en ' + p.name); }
}

if (changes.length) {
  if (!fs.existsSync(path + '.bak')) fs.copyFileSync(path, path + '.bak');
  fs.writeFileSync(path, JSON.stringify(j, null, 4));
  console.log('✓ Windows Terminal configurado. Agregado: ' + changes.join(', '));
} else {
  console.log('✓ Windows Terminal ya estaba configurado (nada que hacer).');
}
