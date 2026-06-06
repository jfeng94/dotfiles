#!/usr/bin/env bash
# bootstrap.sh — Clone personal dotfiles and run setup
# Usage: curl -fsSL df.feng.codes | bash -s -- [setup.sh flags]
#
# Examples:
#   curl -fsSL df.feng.codes | bash                     # soft install (symlinks only)
#   curl -fsSL df.feng.codes | bash -s -- --all         # full install
#   curl -fsSL df.feng.codes | bash -s -- --vim --coc   # vim + coc only

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
REPO="https://github.com/jfeng94/dotfiles"

# Clone if not present, pull if already there
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    echo "[bootstrap] Updating existing dotfiles at $DOTFILES_DIR..."
    git -C "$DOTFILES_DIR" pull --ff-only
else
    echo "[bootstrap] Cloning dotfiles to $DOTFILES_DIR..."
    git clone "$REPO" "$DOTFILES_DIR"
fi

echo "[bootstrap] Running setup..."
bash "$DOTFILES_DIR/setup.sh" "$@"
