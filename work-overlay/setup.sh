#!/bin/bash
# setup.sh — Bootstrap a Skydio work machine
#
# Delegates core dotfiles/vim/tools setup to personal/setup.sh,
# then overlays work-specific config on top.
#
# FLAGS (passed through to personal/setup.sh):
#   --soft       Re-link dotfiles only, skip all installs
#   --vim        Build Vim + install plugins
#   --plugins    Vim :PluginInstall/:PluginUpdate only
#   --ycm        Rebuild YouCompleteMe only
#   --coc        Fix/rebuild coc.nvim only
#   --claude     Install Claude Code + configure Bedrock
#   --all        Run everything (default)
#
# WORK-SPECIFIC FLAGS:
#   --no-aws     Skip AWS SSO login (useful on machines already authenticated)

set -euo pipefail

SETUP_LOG="/tmp/setup-work-$(date +%s).log"
exec > >(tee -a "$SETUP_LOG") 2>&1
echo "[work-setup] Log: $SETUP_LOG"

####################################################################################################
# Parse flags
####################################################################################################
no_aws=false
personal_flags=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-aws) no_aws=true ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "  All flags are passed through to personal/setup.sh."
      echo "  --no-aws   Skip AWS SSO login"
      exit 0
      ;;
    *) personal_flags+=("$1") ;;
  esac
  shift
done

####################################################################################################
# Resolve paths
####################################################################################################
WORK_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PERSONAL_DIR="$WORK_DIR/personal"
echo "[work-setup] WORK_DIR=$WORK_DIR"
echo "[work-setup] PERSONAL_DIR=$PERSONAL_DIR"

####################################################################################################
# Step 1 — Initialize submodules (personal dotfiles + skyrg + vim-lcm)
####################################################################################################
echo "[work-setup] Initializing submodules..."
git -C "$WORK_DIR" submodule update --init --remote --recursive
# personal/  → personal dotfiles (tracks main branch)
# skyrg-plugin/  → managed by personal submodule
# vim-lcm/   → work-specific LCM syntax plugin

####################################################################################################
# Step 2 — Run personal setup
####################################################################################################
echo "[work-setup] Running personal setup..."
bash "$PERSONAL_DIR/setup.sh" --work "${personal_flags[@]:-}"

####################################################################################################
# Step 3 — Work-specific symlinks
####################################################################################################

# Windsurf agent rules
mkdir -p ~/.windsurf
ln -sfn "$WORK_DIR/agentic-coding/rules" ~/.windsurf/rules
echo "  ~/.windsurf/rules → agentic-coding/rules"

# Aircam convenience symlink
if [[ -d /home/skydio/aircam ]]; then
    ln -sfn /home/skydio/aircam ~/aircam
    echo "  ~/aircam → /home/skydio/aircam"
fi

####################################################################################################
# Step 4 — Link AI agent context into work repos
####################################################################################################
if [[ -f "$WORK_DIR/agentic-coding/context/setup.sh" ]]; then
    echo "[work-setup] Linking agent context files..."
    bash "$WORK_DIR/agentic-coding/context/setup.sh"
fi

# Soft reset stops here
if [[ " ${personal_flags[*]:-} " =~ " --soft " ]]; then
    echo "[work-setup] Soft reset complete."
    exit 0
fi

####################################################################################################
# Step 5 — Claude Code: configure Bedrock + AWS SSO (work-specific)
####################################################################################################
if [[ " ${personal_flags[*]:-} " =~ " --claude " ]] || \
   [[ " ${personal_flags[*]:-} " =~ " --all " ]] || \
   [[ ${#personal_flags[@]} -eq 0 ]]; then

    if [[ ! -f ~/.claude/settings.json ]]; then
        echo "[work-setup] Creating ~/.claude/settings.json with Bedrock config..."
        mkdir -p ~/.claude
        cat > ~/.claude/settings.json << 'SETTINGS_EOF'
{
  "awsAuthRefresh": "aws sso login",
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
    "CLAUDE_CODE_USE_BEDROCK": "1"
  }
}
SETTINGS_EOF
    else
        echo "[work-setup] ~/.claude/settings.json already exists, skipping."
    fi

    if ! $no_aws; then
        echo "[work-setup] AWS SSO login (copy URL if on a remote machine)..."
        BROWSER=ECHO aws sso login || echo "WARNING: AWS SSO login failed — run 'aws sso login' manually."
    fi
fi

####################################################################################################
# Done
####################################################################################################
echo ""
echo "[work-setup] Done! Log: $SETUP_LOG"
echo "Run 'source ~/.bashrc' to pick up changes."
