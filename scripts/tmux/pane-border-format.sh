#!/usr/bin/env bash
# pane-border-format.sh — Render pane border content for tmux.
# Args: --pane-current-path=PATH --pane-active=0|1

pane_path=""
pane_active="0"

for arg in "$@"; do
    case "$arg" in
        --pane-current-path=*) pane_path="${arg#*=}" ;;
        --pane-active=*)       pane_active="${arg#*=}" ;;
    esac
done

# Shorten the path: replace $HOME with ~
short_path="${pane_path/#$HOME/\~}"

# Show git branch if in a repo
branch=$(git -C "$pane_path" rev-parse --abbrev-ref HEAD 2>/dev/null) || branch=""

if [[ -n "$branch" ]]; then
    echo "$short_path ($branch)"
else
    echo "$short_path"
fi
