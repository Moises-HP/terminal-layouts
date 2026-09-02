#!/usr/bin/env bash
# run-keep.sh — run an optional command in the current pane, then keep an
# interactive shell open (so the pane does NOT close when the command exits).
# Usage: run-keep.sh "cmd1 && cmd2"   |   run-keep.sh   (just a shell)
if [ "$#" -gt 0 ] && [ -n "$1" ]; then
  bash -lc "$*"
fi
exec bash -l
