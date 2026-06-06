# dotfiles

Personal dotfiles for Jerry Feng. Public base layer — work-specific config lives in a private overlay repo.

## Quick start

```bash
# Soft install (symlinks only, no packages)
curl -fsSL df.feng.codes | bash

# Full install (vim from source, plugins, CoC, Claude Code, fzf)
curl -fsSL df.feng.codes | bash -s -- --all
```

Or clone manually:

```bash
git clone https://github.com/jfeng94/dotfiles ~/.dotfiles
bash ~/.dotfiles/setup.sh --all
```

## setup.sh flags

| Flag | Effect |
|------|--------|
| *(none)* | Symlink dotfiles only |
| `--all` | Everything below |
| `--vim` | Build vim from source + plugins + CoC |
| `--plugins` | Install Vundle plugins (`:PluginInstall`) |
| `--coc` | Fix/rebuild coc.nvim |
| `--ycm` | Build YouCompleteMe |
| `--claude` | Install Claude Code CLI |
| `--revup` | Install revup via pip |
| `--soft` | Symlinks only, skip packages |
| `--work` | Apply work overlay (`*_local` symlinks) |

## Structure

```
.bashrc              # Portable shell config (PS1, aliases, fzf, PATH)
.vimrc               # Portable vim config (Vundle, CoC/YCM, keybindings, skyrg)
.gitconfig           # Git identity + aliases (includes ~/.gitconfig_local)
.tmux.conf           # Tmux config
.inputrc             # Readline config
.gitignore           # Excludes skyrg-plugin/ (cloned by setup.sh)
setup.sh             # Bootstrap script
bootstrap.sh         # curl-pipe-to-bash entry point (used by df.feng.codes)

skyrg/
  global.vim         # SkyRG config: leader keys, pages, workflows dir

remote/
  strap-linux        # Minimal vim+bash strap for Linux remotes (EXIT trap cleanup)
  strap-android      # Minimal vi strap for Android/toybox (explicit cleanup.sh)
  vimrc.min          # No-plugin vimrc for remote sessions
  bashrc.min         # Minimal bashrc for remote sessions

scripts/
  tmux/              # tmux_git_status.sh, pane-border-format.sh
  util/              # ordered_grep.py

work-overlay/        # Staging area — files to migrate into private work repo
```

## Layering

Machine-local config is sourced at the end of each dotfile:

| File | Sourced by |
|------|-----------|
| `~/.bashrc_local` | `.bashrc` |
| `~/.vimrc_local` | `.vimrc` |
| `~/.vimrc_plugins_local` | `.vimrc` (inside Vundle block) |
| `~/.gitconfig_local` | `.gitconfig` |

On personal machines these files are absent (silently ignored). On work machines they're symlinked from the private overlay repo via `setup.sh --work`.

## SkyRG

[SkyRG](https://github.com/jerry-feng-skydio/SkyRG) is a personal vim grep/search plugin. It's cloned (not submoduled) by `setup.sh` to `skyrg-plugin/` and always tracks `main`.

Config lives in `skyrg/global.vim` (leader keys, pages, workflows). Work-specific config (Device page, aircam actions/filters) lives in the private overlay.

## Remote strapping

For quick sessions on remotes with no persistent config:

```bash
# Linux drone / server
source <(curl -fsSL https://raw.githubusercontent.com/jfeng94/dotfiles/main/remote/strap-linux)

# Android device (adb shell)
curl -fsSL https://raw.githubusercontent.com/jfeng94/dotfiles/main/remote/strap-android | sh
```

Leaves no artifacts — EXIT trap (Linux) or explicit `cleanup.sh` (Android) removes everything on exit.

## Platforms

- macOS (Homebrew)
- Ubuntu / WSL (apt + NodeSource for Node 18+)
