#!/usr/bin/env bash
# .bashrc — portable shell config
# Machine-local overrides (work aliases, private env vars, etc.) go in ~/.bashrc_local

# Resolve dotfiles repo root from this symlinked .bashrc
DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export DOTFILES_DIR

# ============================================================
# Prompt
# ============================================================

parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Hostname-based prompt color — add more cases in ~/.bashrc_local
case "$(hostname)" in
  *home*)
    # Blue cwd, green git branch
    export PS1="\u@\h \[\033[1;34m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
    ;;
  *)
    # Magenta cwd, green git branch (default / remote machines)
    export PS1="\u@\h \[\033[1;35m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
    ;;
esac

DISABLE_AUTO_TITLE=true

# ============================================================
# Editor
# ============================================================

export EDITOR=vim

# ============================================================
# Config editing helpers
# ============================================================

edit_tmux() {
    vim ~/.tmux.conf
    tmux source ~/.tmux.conf
}

edit_bashrc() {
    vim ~/.bashrc
    source ~/.bashrc
}

toggle_skymux_git() {
    FILE=~/.iwanttmuxgitstatus
    if test -f "$FILE"; then
        echo "Disabling tmux git statuses"
        rm "$FILE"
    else
        echo "Enabling tmux git statuses"
        touch "$FILE"
    fi
}

# ============================================================
# Tmux launcher
# ============================================================

skymux() {
    "$DOTFILES_DIR/scripts/tmux/skymux.sh"
}

# ============================================================
# Dotfiles management
# ============================================================

# Pull latest, update submodules, re-source
alias zuk='(cd "$DOTFILES_DIR" && git pull --ff-only && git submodule update --init --recursive) && source ~/.bashrc && echo "[dotfiles] Updated and re-sourced"'

alias gdf='cd "$DOTFILES_DIR"'
alias jroot='cd "$DOTFILES_DIR"'
alias gitjf='git -C "$DOTFILES_DIR"'
alias vimjf='vim "$DOTFILES_DIR"'
alias brc='vim "$DOTFILES_DIR/.bashrc"'
alias vrc='vim "$DOTFILES_DIR/.vimrc"'
alias src='source ~/.bashrc'
alias jerry_first_time_setup="$DOTFILES_DIR/setup.sh"

# ============================================================
# Git shortcuts
# ============================================================

alias glp="git log --pretty=oneline"
alias gle="git log --oneline"
alias oopsies='git add . && git commit --amend --no-edit && git push --force'

# ============================================================
# revup — stacked PRs and git productivity
# https://github.com/Skydio/revup
# ============================================================

alias revupl="revup upload"
alias revupa="revup amend"
alias revupr="revup restack"

# ============================================================
# Utility
# ============================================================

# Grep multiple patterns in given order
alias order='python3 "$DOTFILES_DIR/scripts/util/ordered_grep.py"'

# Generic ctags — add project-specific excludes in ~/.bashrc_local
alias ctaggen='ctags -R --exclude=.git'

# ============================================================
# PATH / tooling
# ============================================================

export PATH=$HOME/.local/bin:$HOME/.npm-global/bin:$PATH

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# ============================================================
# Machine-local overrides (work-specific config, private env vars, per-host tweaks)
# ============================================================

[ -f ~/.bashrc_local ] && source ~/.bashrc_local
