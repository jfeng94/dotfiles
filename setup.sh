#!/bin/bash
# setup.sh — Bootstrap a development machine (personal dotfiles)
#
# FLAGS (composable — multiple can be combined):
#   --soft       Re-link dotfiles only, skip all installs. Exits early.
#   --vim        Build Vim from source + install plugins (implies --plugins --coc)
#   --plugins    Only run Vim :PluginInstall/:PluginUpdate
#   --ycm        Only rebuild YouCompleteMe
#   --coc        Only fix/rebuild coc.nvim
#   --claude     Only install Claude Code CLI
#   --all        Run everything (default when no component flags given)
#
# EXECUTION ORDER:
#   1. Symlink dotfiles (.bashrc, .vimrc, .tmux.conf, .gitconfig, etc.)
#   2. [--vim]    Install packages, build Vim from source, install plugins, build YCM, fix CoC
#   3. [--claude] Install Claude Code CLI
#
# NOTES:
#   - Step 1 always runs (even with component flags).
#   - --soft exits after step 1.
#   - No flags = --all (runs everything).

set -euo pipefail

SETUP_LOG="/tmp/setup-$(date +%s).log"
exec > >(tee -a "$SETUP_LOG") 2>&1
echo "Setup log: $SETUP_LOG"

####################################################################################################
# Detect platform
####################################################################################################
detect_platform() {
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    elif [[ "$(uname)" == "Linux" ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}
PLATFORM=$(detect_platform)
echo "[setup] Platform: $PLATFORM"

####################################################################################################
# Parse flags
####################################################################################################
soft_reset=false
do_vim=false
do_claude=false
any_component=false
do_plugins=false
do_ycm=false
do_coc=false
do_revup=false
do_work=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --soft       Soft reset: only re-link dotfiles, skip installs"
      echo "  --vim        Build Vim from source + install plugins (implies --plugins --coc)"
      echo "  --plugins    Only run Vim :PluginInstall/:PluginUpdate"
      echo "  --ycm        Only rebuild YouCompleteMe"
      echo "  --coc        Only fix/rebuild coc.nvim"
      echo "  --claude     Only install Claude Code CLI"
  echo "  --revup      Only install revup (stacked PRs tool)"
      echo "  --all        Run everything (default when no component flags given)"
  echo "  --work         Apply work overlay: symlink .*_local files from parent dir"
      echo "  -h, --help   Show this help"
      echo ""
      echo "Component flags compose: --claude --vim runs both."
      echo "No component flags = --all."
      exit 0
      ;;
    -s|--soft)    soft_reset=true ;;
    --vim)        do_vim=true; any_component=true ;;
    --plugins)    do_plugins=true; any_component=true ;;
    --ycm)        do_ycm=true; any_component=true ;;
    --coc)        do_coc=true; any_component=true ;;
    --claude)     do_claude=true; any_component=true ;;
    --revup)      do_revup=true; any_component=true ;;
    --all)        any_component=true ;;
    --work)       do_work=true ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

# No component flags = run everything
if ! $any_component && ! $soft_reset; then
    do_vim=true
    do_claude=true
    do_revup=true
fi

# --vim implies --plugins and --coc
if $do_vim; then
    do_plugins=true
    do_coc=true
fi

####################################################################################################
# Resolve paths
####################################################################################################
DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
echo "[setup] DOTFILES_DIR=$DOTFILES_DIR"

####################################################################################################
# Step 0 — Clone/update skyrg-plugin
####################################################################################################
SKYRG_DIR="$DOTFILES_DIR/skyrg-plugin"
SKYRG_URL="https://github.com/jerry-feng-skydio/SkyRG.git"
if [[ -d "$SKYRG_DIR/.git" ]]; then
    echo "[setup] Updating skyrg-plugin..."
    git -C "$SKYRG_DIR" pull --ff-only origin main
else
    echo "[setup] Cloning skyrg-plugin..."
    git clone "$SKYRG_URL" "$SKYRG_DIR"
fi

####################################################################################################
# Step 1 — Symlink dotfiles
####################################################################################################
echo "[setup] Symlinking dotfiles..."

symlink() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "  Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    echo "  $dst → $src"
}

symlink "$DOTFILES_DIR/.bashrc"       ~/.bashrc
symlink "$DOTFILES_DIR/.vimrc"        ~/.vimrc
symlink "$DOTFILES_DIR/.tmux.conf"    ~/.tmux.conf
symlink "$DOTFILES_DIR/.gitconfig"    ~/.gitconfig
symlink "$DOTFILES_DIR/.inputrc"      ~/.inputrc

if [[ -f "$DOTFILES_DIR/coc-settings.json" ]]; then
    mkdir -p ~/.vim
    symlink "$DOTFILES_DIR/coc-settings.json" ~/.vim/coc-settings.json
fi

# macOS: symlink .vimrc_macos extra if present
if [[ "$PLATFORM" == "macos" && -f "$DOTFILES_DIR/.vimrc_macos" ]]; then
    symlink "$DOTFILES_DIR/.vimrc_macos" ~/.vimrc_macos
fi

# Apply work overlay: symlink any .*_local files from the parent directory
# (When personal is a submodule at work/personal/, parent = work repo root)
if $do_work; then
    overlay_dir="$(dirname "$DOTFILES_DIR")"
    if [[ ! -d "$overlay_dir" ]]; then
        echo "[setup] WARNING: --work overlay dir not found: $overlay_dir"
    else
        echo "[setup] Applying work overlay from $overlay_dir..."
        while IFS= read -r -d '' f; do
            name="$(basename "$f")"
            dst="$HOME/$name"
            if [[ -e "$dst" && ! -L "$dst" ]]; then
                echo "  Backing up $dst → $dst.bak"
                mv "$dst" "$dst.bak"
            fi
            ln -sf "$f" "$dst"
            echo "  ~/$name → $f"
        done < <(find "$overlay_dir" -maxdepth 1 -name '.*_local' -print0)
    fi
fi

if $soft_reset; then
    echo "[setup] Soft reset complete."
    exit 0
fi

####################################################################################################
# Step 1b — SSH config include
####################################################################################################
setup_ssh_config() {
    local ssh_config="$HOME/.ssh/config"
    local include_line="Include $DOTFILES_DIR/ssh/config"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    if [[ ! -f "$ssh_config" ]] || ! grep -qF "$include_line" "$ssh_config"; then
        # Include must be at the top of ssh/config to apply to all hosts
        local tmp
        tmp=$(mktemp)
        echo "$include_line" > "$tmp"
        [[ -f "$ssh_config" ]] && cat "$ssh_config" >> "$tmp"
        mv "$tmp" "$ssh_config"
        chmod 600 "$ssh_config"
        echo "[setup] Added SSH config include → $DOTFILES_DIR/ssh/config"
    fi
}

setup_ssh_config

####################################################################################################
# Step 2 — Install packages
####################################################################################################
install_packages() {
    echo "[setup] Installing packages..."
    case "$PLATFORM" in
      macos)
        if ! command -v brew &>/dev/null; then
            echo "  Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install \
            cmake python3 nodejs npm \
            tmux fzf ripgrep git curl wget \
            lua luajit
        # macOS uses system vim or brew vim — don't build from source unless explicitly requested
        if $do_vim; then
            brew install vim
        fi
        ;;
      linux|wsl)
        sudo apt-get update -y
        sudo apt-get install -y \
            build-essential cmake python3 python3-dev python3-pip \
            tmux fzf ripgrep git curl wget \
            libncurses5-dev libncursesw5-dev \
            lua5.4 liblua5.4-dev luajit libluajit-5.1-dev \
            libpython3-dev libperl-dev ruby-dev \
            universal-ctags
        # Install Node.js 18+ via NodeSource (apt nodejs is too old on Focal)
        # NODE_VERSION can be overridden by work overlay (e.g. NODE_VERSION=20)
        NODE_VERSION="${NODE_VERSION:-lts}"
        local node_major
        node_major=$(node --version 2>/dev/null | grep -oE '[0-9]+' | head -1)
        if [[ -z "$node_major" ]] || [[ "$node_major" -lt 18 ]]; then
            echo "[setup] Installing Node.js ${NODE_VERSION} via NodeSource..."
            sudo apt-get remove -y nodejs libnode-dev libnode72 2>/dev/null || true
            sudo apt-get autoremove -y 2>/dev/null || true
            curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
        ;;
    esac
}

if $do_vim || $do_plugins || $do_ycm || $do_coc; then
    install_packages
fi

####################################################################################################
# Step 3 — Install/build Vim
#   macOS:      brew install vim  (fast, no source build needed)
#   Linux/WSL:  build from source for full feature set (python3, lua, etc.)
####################################################################################################
install_vim_macos() {
    echo "[setup] macOS: installing Vim via brew..."
    brew install vim
    echo "[setup] Vim installed: $(vim --version | head -1)"
}

build_vim_linux() {
    echo "[setup] Linux: building Vim from source..."
    local vim_src="/tmp/vim-src"
    rm -rf "$vim_src"
    git clone --depth=1 https://github.com/vim/vim.git "$vim_src"
    cd "$vim_src"

    ./configure \
        --with-features=huge \
        --enable-multibyte \
        --enable-python3interp=yes \
        --with-python3-config-dir="$(python3-config --configdir)" \
        --enable-perlinterp=yes \
        --enable-luainterp=yes \
        --enable-rubyinterp=yes \
        --enable-cscope \
        --prefix=/usr/local

    make -j"$(nproc)"
    sudo make install
    cd -
    rm -rf "$vim_src"
    echo "[setup] Vim built: $(vim --version | head -1)"
}

if $do_vim; then
    case "$PLATFORM" in
      macos)        install_vim_macos ;;
      linux|wsl)    build_vim_linux ;;
      *)            echo "[setup] Unknown platform, skipping Vim install." ;;
    esac
fi

####################################################################################################
# Step 4 — Vundle + plugins
####################################################################################################
install_plugins() {
    echo "[setup] Installing Vundle..."
    local vundle_dir=~/.vim/bundle/Vundle.vim
    if [[ ! -d "$vundle_dir" ]]; then
        git clone https://github.com/VundleVim/Vundle.vim.git "$vundle_dir"
    else
        git -C "$vundle_dir" pull --ff-only
    fi

    mkdir -p ~/.vim/undodir

    echo "[setup] Running :PluginInstall..."
    vim -E -s -u "$DOTFILES_DIR/.vimrc" +PluginInstall +qall || true
    echo "[setup] Plugins installed."
}

if $do_plugins; then
    install_plugins
fi

####################################################################################################
# Step 5 — YouCompleteMe
####################################################################################################
build_ycm() {
    local ycm_dir=~/.vim/bundle/YouCompleteMe
    if [[ ! -d "$ycm_dir" ]]; then
        echo "[setup] YCM not found — run :PluginInstall first."
        return 1
    fi
    echo "[setup] Building YouCompleteMe..."
    cd "$ycm_dir"
    python3 install.py --clangd-completer
    cd -
    echo "[setup] YCM built."
}

if $do_ycm; then
    build_ycm
fi

####################################################################################################
# Step 6 — coc.nvim
####################################################################################################
fix_coc() {
    local coc_dir=~/.vim/bundle/coc.nvim
    if [[ ! -d "$coc_dir" ]]; then
        echo "[setup] coc.nvim not found — run :PluginInstall first."
        return 1
    fi
    echo "[setup] Fixing coc.nvim (switching to release branch + npm ci)..."
    cd "$coc_dir"
    git fetch origin release
    git checkout -B release FETCH_HEAD
    npm install --legacy-peer-deps
    cd -
    echo "[setup] coc.nvim ready."
}

if $do_coc; then
    fix_coc
fi

####################################################################################################
# Step 7 — FZF shell integration
####################################################################################################
setup_fzf() {
    echo "[setup] Setting up fzf shell integration..."
    local fzf_dir=~/.fzf
    if [[ ! -d "$fzf_dir" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    fi
    "$fzf_dir/install" --key-bindings --completion --no-update-rc
}

if $do_vim || $do_plugins; then
    setup_fzf
fi

####################################################################################################
# Step 8 — Claude Code CLI
####################################################################################################
install_claude() {
    echo "[setup] Installing Claude Code CLI..."
    if ! command -v npm &>/dev/null; then
        echo "[setup] npm not found — skipping Claude Code install."
        return
    fi
    # Install to user-local prefix (no sudo, works without root)
    npm config set prefix "$HOME/.local"
    npm install -g @anthropic-ai/claude-code
    echo "[setup] Claude Code installed: $(claude --version 2>/dev/null || echo 'check PATH — ensure ~/.local/bin is in PATH')"
}

if $do_claude; then
    install_claude
fi

####################################################################################################
# Step 9 — revup (stacked PRs)
####################################################################################################
install_revup() {
    echo "[setup] Installing revup..."
    if command -v pip3 &>/dev/null; then
        pip3 install --user --upgrade revup
        echo "[setup] revup installed: $(revup --version 2>/dev/null || echo 'check PATH')"
    elif command -v pip &>/dev/null; then
        pip install --user --upgrade revup
    else
        echo "[setup] pip not found — skipping revup install."
        return
    fi
    # First-time GitHub token setup reminder
    echo "[setup] Note: run 'revup config github_oauth' to configure GitHub access."
}

if $do_revup; then
    install_revup
fi

####################################################################################################
# Done
####################################################################################################
echo ""
echo "[setup] Done! Log saved to $SETUP_LOG"
echo ""
echo "Next steps:"
echo "  source ~/.bashrc             # pick up new shell config"
if $do_vim; then
    echo "  vim +PluginInstall           # if anything was missed"
fi
