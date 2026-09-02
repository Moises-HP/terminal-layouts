#!/usr/bin/env node
// toml2wt.mjs — convierte un tab-config estilo Warp en la lista de argumentos de
// una pestaña de Windows Terminal (wt.exe). Imprime un arg por línea.
//
//   node toml2wt.mjs <config.toml>
//
// Lo consume open.sh, que junta varias pestañas en una sola ventana.
//
// Mapeo de dirección (semántica Warp, verificada con los configs reales):
//   split="horizontal"  => columnas (izq | der)  => wt -V  (divisor vertical)
//   split="vertical"    => filas (arriba/abajo)  => wt -H  (divisor horizontal)
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const HERE = dirname(fileURLToPath(import.meta.url));
const GB = 'C:\\Program Files\\Git\\bin\\bash.exe';        // shell de cada panel
const RUNKEEP = join(HERE, 'run-keep.sh').replace(/\\/g, '/'); // C:/.../run-keep.sh
const PROFILE = 'Layouts';   // perfil dedicado (Git Bash + suppressApplicationTitle)
const HOME = (process.env.USERPROFILE || 'C:\\Users\\Default').replace(/\\/g, '/');
const COLORS = { green:'#2ea043', magenta:'#c026d3', blue:'#2563eb', red:'#dc2626',
                 yellow:'#d4a72c', cyan:'#0891b2', orange:'#ea580c', purple:'#7c3aed' };

// ── Parser TOML (subset Warp: top-level key=val + arrays [[panes]]) ───────────
function parseValue(raw) {
  raw = raw.trim();
  if (raw.startsWith('[') && raw.endsWith(']')) {                 // array de strings
    const inner = raw.slice(1, -1).trim();
    if (!inner) return [];
    return inner.split(',').map(s => s.trim().replace(/^["']|["']$/g, '')).filter(s => s !== '');
  }
  if (/^["']/.test(raw)) return raw.replace(/^["']|["']$/g, '');   // string
  if (raw === 'true') return true;
  if (raw === 'false') return false;
  if (/^-?\d+(\.\d+)?$/.test(raw)) return Number(raw);
  return raw;
}
function stripInlineComment(s) {           // corta en el primer # fuera de comillas
  let q = null;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (q) { if (c === q) q = null; }
    else if (c === '"' || c === "'") q = c;
    else if (c === '#') return s.slice(0, i);
  }
  return s;
}
function parseToml(text) {
  const top = {}; const panes = []; let cur = top;
  for (let line of text.split(/\r?\n/)) {
    let t = line.trim();
    if (!t || t.startsWith('#')) continue;
    t = stripInlineComment(t).trim();
    if (!t) continue;
    if (t === '[[panes]]') { cur = {}; panes.push(cur); continue; }
    if (t.startsWith('[')) { cur = {}; continue; }               // otras tablas: ignorar
    const eq = t.indexOf('=');
    if (eq === -1) continue;
    const key = t.slice(0, eq).trim();
    cur[key] = parseValue(t.slice(eq + 1));
  }
  return { top, panes };
}

// ── Construir el árbol a partir de ids/children ──────────────────────────────
const MISSING = [];   // carpetas que no existen (se avisan por stderr, no falla)
function expandDir(d) {
  if (!d) return HOME;
  return d.startsWith('~') ? HOME + d.slice(1) : d;
}
function buildTree(panes) {
  const byId = new Map(panes.map(p => [p.id, p]));
  const childIds = new Set();
  for (const p of panes) for (const c of (p.children || [])) childIds.add(c);

  const toNode = (p) => {
    const kids = (p.children || []).map(id => byId.get(id)).filter(Boolean);
    if (kids.length) return { split: p.split || 'vertical', children: kids.map(toNode) };
    const cmds = p.commands || [];
    const dir = expandDir(p.directory);
    if (dir && !existsSync(dir)) MISSING.push(dir);   // aviso: carpeta inexistente
    return { leaf: true, dir, cmd: cmds.length ? cmds.join(' && ') : '' };
  };

  // raíz = pane no referenciado como hijo; si hay varios, el que tenga children
  // (contenedor). Los leaves no referenciados son huérfanos → se ignoran.
  const roots = panes.filter(p => !childIds.has(p.id));
  const root = roots.find(p => (p.children || []).length) || roots[0] || panes[0];
  return toNode(root);
}

function firstLeaf(n) { return n.leaf ? n : firstLeaf(n.children[0]); }

// ── Emisión de argumentos wt.exe ─────────────────────────────────────────────
const A = [];
let LAYOUT_TITLE = 'tab';                    // título fijo del layout (todas las panes)
const push = (...xs) => { for (const x of xs) A.push(String(x)); };
const size = (num, den) => (num / den).toFixed(3);

function createLeaf(leaf) {                 // args comunes de creación de un panel
  // Cada panel lleva el título del layout → el tab lo muestra fijo (con
  // suppressApplicationTitle del perfil 'Layouts'), sin importar qué panel enfoques.
  push('--title', LAYOUT_TITLE);
  push('-p', PROFILE, '-d', leaf.dir);
  if (leaf.cmd) push(GB, '-l', RUNKEEP, leaf.cmd);
}

// emit(node): asume que el panel enfocado es firstLeaf(node) ocupando toda la
// región de node; subdivide para realizar el subárbol.
function emit(node) {
  if (node.leaf) return;
  const O = node.split;
  const flag = O === 'horizontal' ? '-V' : '-H';   // horizontal=columnas, vertical=filas
  const back = O === 'horizontal' ? 'left' : 'up';
  const fwd  = O === 'horizontal' ? 'right' : 'down';
  const kids = node.children;
  const m = kids.length;
  // 1) crear TODAS las regiones hermanas como paneles simples (altura/ancho completo)
  for (let i = 1; i < m; i++) {
    push(';', 'split-pane', flag, '-s', size(m - i, m - i + 1));
    createLeaf(firstLeaf(kids[i]));
  }
  // 2) volver a la primera región (moviéndose entre hermanas aún simples = fiable)
  for (let i = 1; i < m; i++) push(';', 'move-focus', back);
  // 3) rellenar en orden; cada avance entra a una región prístina (aún sin subdividir),
  //    por eso el cruce move-focus SIEMPRE aterriza bien (a diferencia de cruzar
  //    hacia una columna ya partida en filas).
  for (let i = 0; i < m; i++) {
    if (i > 0) push(';', 'move-focus', fwd);
    emit(kids[i]);
  }
}

// ── Preview ASCII del árbol (node toml2wt.mjs <file> --preview) ──────────────
const CW = 24;
const trunc = (s, n) => (s.length > n ? s.slice(0, n - 1) + '…' : s);
function leafBlock(leaf) {
  const name = (leaf.dir || '~').replace(/[\/\\]+$/, '').split(/[\/\\]/).pop() || '~';
  const inner = CW - 2;
  const l = (s) => '│' + (' ' + s).padEnd(inner).slice(0, inner) + '│';
  return [
    '┌' + '─'.repeat(inner) + '┐',
    l(trunc(name, inner - 1)),
    l(leaf.cmd ? '▸ ' + trunc(leaf.cmd, inner - 3) : ''),
    '└' + '─'.repeat(inner) + '┘',
  ];
}
function renderBlock(node) {
  if (node.leaf) return leafBlock(node);
  const parts = node.children.map(renderBlock);
  if (node.split === 'horizontal') {                 // columnas lado a lado
    const h = Math.max(...parts.map(p => p.length));
    const padded = parts.map(p => { const w = p[0].length; const c = [...p]; while (c.length < h) c.push(' '.repeat(w)); return c; });
    const out = [];
    for (let i = 0; i < h; i++) out.push(padded.map(p => p[i]).join(' '));
    return out;
  }
  const w = Math.max(...parts.map(p => p[0].length));  // filas apiladas
  const out = [];
  for (const p of parts) for (const line of p) out.push(line.padEnd(w));
  return out;
}

// ── Main ─────────────────────────────────────────────────────────────────────
const file = process.argv[2];
if (!file) { console.error('uso: node toml2wt.mjs <config.toml>'); process.exit(2); }
const { top, panes } = parseToml(readFileSync(file, 'utf8'));
const tree = buildTree(panes);
const f0 = firstLeaf(tree);
LAYOUT_TITLE = top.title || top.name || 'tab';
const color = COLORS[top.color] || (String(top.color || '').startsWith('#') ? top.color : '');

if (process.argv[3] === '--preview') {
  const rows = renderBlock(tree);
  const cols = tree.leaf ? 1 : (tree.split === 'horizontal' ? tree.children.length : 1);
  process.stdout.write(`\n  \x1b[1m${LAYOUT_TITLE}\x1b[0m  \x1b[2m(${top.color || 'sin color'})\x1b[0m\n\n`);
  process.stdout.write(rows.map(l => '  ' + l).join('\n') + '\n\n');
  process.stdout.write('  \x1b[2m▸ = corre un comando al abrir. Etiqueta = nombre de la carpeta.\x1b[0m\n');
  process.exit(0);
}

push('new-tab');
if (color) push('--tabColor', color);
createLeaf(f0);
emit(tree);

if (MISSING.length) {
  const uniq = [...new Set(MISSING)];
  process.stderr.write(`⚠️  [${top.name || top.title || file}] carpeta(s) que NO existen (el panel puede fallar con 0x80070057):\n`
    + uniq.map(d => '   • ' + d).join('\n') + '\n');
}

process.stdout.write(A.join('\n') + '\n');
