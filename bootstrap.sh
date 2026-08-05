#!/usr/bin/env bash
#
# bootstrap.sh - set up a fresh macOS machine from this repo.
#
# Installs the tools that the configs depend on, then symlinks the configs.
# Safe to re-run: every step checks before installing.
#
# Usage:  ./bootstrap.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# 1. Homebrew ---------------------------------------------------------------
step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into this shell (Apple Silicon path).
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Brew packages (formulae + casks) --------------------------------------
step "brew bundle (Brewfile)"
brew bundle --file="$DOTFILES/Brewfile"

# 3. Oh My Zsh --------------------------------------------------------------
step "Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local repo="$1" dir="$ZSH_CUSTOM/plugins/$2"
  if [[ ! -d "$dir" ]]; then
    git clone --depth=1 "$repo" "$dir"
  fi
}
clone_plugin https://github.com/zsh-users/zsh-autosuggestions     zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting

# 4. SDKMAN -----------------------------------------------------------------
step "SDKMAN"
if [[ ! -d "$HOME/.sdkman" ]]; then
  curl -s "https://get.sdkman.io" | bash
fi

# 5. nvm + Node -------------------------------------------------------------
step "nvm + Node LTS"
export NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
if command -v nvm >/dev/null 2>&1; then
  nvm install --lts
fi

# 6. Symlink all configs ----------------------------------------------------
step "Symlinking configs (install.sh)"
"$DOTFILES/install.sh"

step "Bootstrap complete"
cat <<'EOF'

Manual steps left (not automated on purpose):
  - SSH keys: copy your private keys into ~/.ssh (they are NOT stored in this
    repo), then `chmod 600 ~/.ssh/<key>`. ~/.ssh/config is already linked.
  - Fonts: install the Nerd Fonts referenced by ghostty/font/* snippets.
  - Restart the terminal (or `source ~/.zshrc`) to load everything.
EOF
