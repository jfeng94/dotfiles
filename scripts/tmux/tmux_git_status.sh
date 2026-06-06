#!/usr/bin/env bash
# tmux_git_status.sh — Show git branch/status in tmux status bar.
# Displays nothing when not in a git repo.

branch=$(git -C "${PWD}" rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
dirty=$(git -C "${PWD}" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [[ "$dirty" -gt 0 ]]; then
    echo " ✎ $branch ($dirty) "
else
    echo "  $branch "
fi
