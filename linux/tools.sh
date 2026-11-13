#!/usr/bin/env bash
#
# linux/tools.sh - install the CLI tools these dotfiles expect, without sudo.
#
# Ubuntu 20.04's apt packages are too old (fzf 0.20 lacks options used in
# zsh/fzf.zsh) or missing (eza, delta, lazygit, yazi), so pinned upstream
# release binaries go into ~/.local/bin instead. Every download is checked
# against a pinned SHA256. x86_64 builds are static (musl or Go); on aarch64,
# eza and delta only ship glibc builds.
#
# Also installs Oh My Zsh + the plugins .zshrc loads, and the Ghostty terminfo
# entry so `ssh` straight from Ghostty (TERM=xterm-ghostty) works.
#
# Idempotent: a tool already in ~/.local/bin is skipped unless UPDATE_TOOLS=1.
# Run by install.sh; DRY_RUN=1 prints actions only.

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BIN="$HOME/.local/bin"
DRY_RUN="${DRY_RUN:-0}"
UPDATE_TOOLS="${UPDATE_TOOLS:-0}"

log() { printf '  %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

case "$(uname -m)" in
  x86_64)         ARCH=x86_64 ;;
  aarch64|arm64)  ARCH=aarch64 ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

for cmd in curl tar git sha256sum; do
  command_exists "$cmd" || die "'$cmd' is required (sudo apt install -y curl tar git coreutils)"
done

# name | version | url (x86_64) | sha256 (x86_64) | url (aarch64) | sha256 (aarch64)
# A release can hold several binaries; the extra ones are listed in EXTRA_BINS.
GH=https://github.com
TOOLS=(
  "fzf|0.75.0|$GH/junegunn/fzf/releases/download/v0.75.0/fzf-0.75.0-linux_amd64.tar.gz|0d6640f83582d991cf429754baad64b07e3a4e439a6019670f4b91da1314141c|$GH/junegunn/fzf/releases/download/v0.75.0/fzf-0.75.0-linux_arm64.tar.gz|bd0717badb6a5620387e014bb94209aac4d9eab6ab77b5348eabb0833aeb4d59"
  "eza|0.23.5|$GH/eza-community/eza/releases/download/v0.23.5/eza_x86_64-unknown-linux-musl.tar.gz|e06eebab74b73d6b7d51a796a353824b001bea82df077706382e100815d28904|$GH/eza-community/eza/releases/download/v0.23.5/eza_aarch64-unknown-linux-gnu.tar.gz|40b87ae8628aa2ff0f0d2dc24ab52f689631366385c3da630bae745671fd71ec"
  "fd|10.5.2|$GH/sharkdp/fd/releases/download/v10.5.2/fd-v10.5.2-x86_64-unknown-linux-musl.tar.gz|7e2d07fa2b8807642aaec67b7e2972a9fbe4db26fcb340a7372392db42b26694|$GH/sharkdp/fd/releases/download/v10.5.2/fd-v10.5.2-aarch64-unknown-linux-musl.tar.gz|63ea52cb31586e6d98efa2f06d73d542f16c7d0c4af0f07b579aaf9714cf907a"
  "bat|0.26.1|$GH/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-x86_64-unknown-linux-musl.tar.gz|0dcd8ac79732c0d5b136f11f4ee00e581440e16a44eab5b3105b611bbf2cf191|$GH/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-aarch64-unknown-linux-musl.tar.gz|6369242c584065f195fb20cb36fbd7cb63ae690605bbe89868a7596b596c2c23"
  "delta|0.20.1|$GH/dandavison/delta/releases/download/0.20.1/delta-0.20.1-x86_64-unknown-linux-musl.tar.gz|69dcb4043f55c29118f408c6efd30115e0a4e0a6709253343b8c8fa814ab4a31|$GH/dandavison/delta/releases/download/0.20.1/delta-0.20.1-aarch64-unknown-linux-gnu.tar.gz|da7f4338f593572ff426ae153e0870e2fdc72729416eff551b40cdeb67940db8"
  "lazygit|0.66.3|$GH/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_x86_64.tar.gz|0a23f429a95f0d09db298b3c291536d818de066aa5a85c255806f0490ff6656b|$GH/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_arm64.tar.gz|ac0b48237f3d0283813e7154ec063237e519532feb0470c0881a1793ee78fd42"
  "yazi|26.9.1|$GH/sxyazi/yazi/releases/download/v26.9.1/yazi-x86_64-unknown-linux-musl.zip|9b9c39decccf8cb0ff53a7d637d38f8a79d93bbd0099f4ea9c619ef6bb392f5d|$GH/sxyazi/yazi/releases/download/v26.9.1/yazi-aarch64-unknown-linux-musl.zip|dd569daecaae914185f295634109295ccd25c1b42b02eb89a74f651970024f2e"
  "micro|2.0.15|$GH/zyedidia/micro/releases/download/v2.0.15/micro-2.0.15-linux64-static.tar.gz|267d238eac1e26ed053d13d4d48bd421b87f9eb538b604f0b2f74a85598b6cc2|$GH/zyedidia/micro/releases/download/v2.0.15/micro-2.0.15-linux-arm64.tar.gz|5ca127857bf5500be3879f1a70b27556e737a49da04a1be5334de9e8e8781ad9"
  "jq|1.8.2|$GH/jqlang/jq/releases/download/jq-1.8.2/jq-linux-amd64|b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f|$GH/jqlang/jq/releases/download/jq-1.8.2/jq-linux-arm64|8b85c817833814ddca00a144c33705546355afccf0cf39b188f3cdb48b852309"
  "gh|2.104.0|$GH/cli/cli/releases/download/v2.104.0/gh_2.104.0_linux_amd64.tar.gz|98cb101ad87dbbd3f6b2f2bfcbd43197ccd07643140121d8a9cfaa91eadbc24e|$GH/cli/cli/releases/download/v2.104.0/gh_2.104.0_linux_arm64.tar.gz|cb34cefc6f4e77b90731374a2b737516bb8f3033c6ca46aa949e5344f68069e3"
)
declare -A EXTRA_BINS=( [yazi]="ya" )

# Unpack an archive into a directory; zip falls back to python3, which Ubuntu
# ships by default, when unzip is not installed.
extract() {
  local archive="$1" dest="$2"
  case "$archive" in
    *.tar.gz) tar -xzf "$archive" -C "$dest" ;;
    *.zip)
      if command_exists unzip; then unzip -q "$archive" -d "$dest"
      elif command_exists python3; then python3 -m zipfile -e "$archive" "$dest"
      else die "need unzip or python3 to extract $archive"
      fi ;;
    *) cp "$archive" "$dest/" ;;
  esac
}

install_tool() {
  local name version url sha url_arm sha_arm
  IFS='|' read -r name version url sha url_arm sha_arm <<<"$1"
  if [[ "$ARCH" == aarch64 ]]; then url="$url_arm"; sha="$sha_arm"; fi

  if [[ -x "$BIN/$name" && "$UPDATE_TOOLS" != "1" ]]; then
    log "OK    $name (already in $BIN)"
    return
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] install $name $version from $url"
    return
  fi

  local tmp archive
  tmp="$(mktemp -d)"
  archive="$tmp/${url##*/}"
  curl -fsSL --retry 3 -o "$archive" "$url"
  echo "$sha  $archive" | sha256sum -c --quiet - || die "checksum mismatch for $name"
  mkdir -p "$tmp/x"
  extract "$archive" "$tmp/x"

  local bin src
  for bin in "$name" ${EXTRA_BINS[$name]:-}; do
    # Raw single-file downloads (jq) keep their release name.
    src="$(find "$tmp/x" -type f \( -name "$bin" -o -name "${url##*/}" \) | head -n 1)"
    [[ -n "$src" ]] || die "$bin not found in ${url##*/}"
    install -m 755 "$src" "$BIN/$bin"
  done
  rm -rf "$tmp"
  log "INST  $name $version"
}

clone_once() {
  local repo="$1" dest="$2"
  if [[ -d "$dest" ]]; then
    log "OK    $dest"
  elif [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] git clone $repo $dest"
  else
    git clone --quiet --depth 1 "$repo" "$dest"
    log "CLONE $dest"
  fi
}

echo "CLI tools -> $BIN ($ARCH):"
[[ "$DRY_RUN" == "1" ]] || mkdir -p "$BIN"
for spec in "${TOOLS[@]}"; do install_tool "$spec"; done

# Cloned rather than run through the upstream installer, which would also
# rewrite ~/.zshrc; the repo's .zshrc is linked by install.sh instead.
echo "Oh My Zsh:"
ZSH_DIR="$HOME/.oh-my-zsh"
clone_once https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
clone_once https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_DIR/custom/plugins/zsh-autosuggestions"
clone_once https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_DIR/custom/plugins/zsh-syntax-highlighting"

echo "Ghostty terminfo:"
if infocmp xterm-ghostty >/dev/null 2>&1; then
  log "OK    xterm-ghostty"
elif ! command_exists tic; then
  log "SKIP  tic not found (sudo apt install -y ncurses-bin)"
elif [[ "$DRY_RUN" == "1" ]]; then
  log "[dry-run] tic -x -o ~/.terminfo linux/xterm-ghostty.terminfo"
else
  tic -x -o "$HOME/.terminfo" "$DOTFILES/linux/xterm-ghostty.terminfo"
  log "INST  xterm-ghostty -> ~/.terminfo"
fi
