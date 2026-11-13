#!/usr/bin/env bash
#
# install.sh (linux branch) - set up these dotfiles on an Ubuntu host.
#
# 1. linux/tools.sh installs the CLI tools, Oh My Zsh + plugins and the Ghostty
#    terminfo entry into $HOME (no sudo). Skip with SKIP_TOOLS=1.
# 2. Configs are symlinked from this repo into their expected locations.
#
# Idempotent and safe: any existing real file/dir at a destination is moved to
# "<dest>.bak.<timestamp>" before the symlink is created. Re-running only fixes
# links that are missing or wrong. Claude Code and Ghostty are not set up here.
#
# Usage:
#   ./install.sh                 # install tools, create/repair all symlinks
#   DRY_RUN=1 ./install.sh       # print what would happen, change nothing
#   SKIP_TOOLS=1 ./install.sh    # symlinks only
#   UPDATE_TOOLS=1 ./install.sh  # reinstall tools at the pinned versions

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"
SKIP_TOOLS="${SKIP_TOOLS:-0}"
export DOTFILES DRY_RUN

log()  { printf '  %s\n' "$*"; }
run()  { if [[ "$DRY_RUN" == "1" ]]; then printf '  [dry-run] %s\n' "$*"; else eval "$*"; fi; }

# link <repo-relative-src> <absolute-dest>
link() {
  local src="$DOTFILES/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    log "SKIP  $1 -> $dest  (source missing in repo)"
    return
  fi

  # Already the correct symlink? Nothing to do.
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log "OK    $dest"
    return
  fi

  run "mkdir -p \"$(dirname "$dest")\""

  # Back up anything real (or a wrong symlink) sitting at the destination.
  if [[ -e "$dest" || -L "$dest" ]]; then
    log "BACKUP $dest -> $dest.bak.$TS"
    run "mv \"$dest\" \"$dest.bak.$TS\""
  fi

  log "LINK  $dest -> $src"
  run "ln -s \"$src\" \"$dest\""
}

# The tracked .gitconfig carries no identity; it includes ~/.gitconfig.local.
# Carry user.name/email over from a real ~/.gitconfig before it is backed up.
keep_git_identity() {
  local old="$HOME/.gitconfig" local_cfg="$HOME/.gitconfig.local" key value
  [[ -f "$old" && ! -L "$old" && ! -e "$local_cfg" ]] || return 0
  for key in user.name user.email; do
    value="$(git config -f "$old" --get "$key" || true)"
    [[ -n "$value" ]] || continue
    log "KEEP  $key -> $local_cfg"
    [[ "$DRY_RUN" == "1" ]] || git config -f "$local_cfg" "$key" "$value"
  done
}

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This is the linux branch; use the main branch on macOS." >&2
  exit 1
fi

echo "Dotfiles: $DOTFILES"
[[ "$DRY_RUN" == "1" ]] && echo "(dry run - no changes will be made)"
echo

if [[ "$SKIP_TOOLS" != "1" ]]; then
  "$DOTFILES/linux/tools.sh"
  echo
fi

echo "Zsh:"
link "zsh/.zshrc"                 "$HOME/.zshrc"
link "zsh/.zprofile"              "$HOME/.zprofile"
link "zsh/.zshrc.pre-oh-my-zsh"   "$HOME/.zshrc.pre-oh-my-zsh"
# Note: fzf.zsh is sourced directly from this repo by .zshrc, so it needs no link.

echo "Git:"
keep_git_identity
link "git/.gitconfig"             "$HOME/.gitconfig"
link "git/ignore"                 "$HOME/.config/git/ignore"

echo "herdr:"
# Only config.toml is linked: ~/.config/herdr also holds sockets, logs and sessions.
link "herdr/config.toml"          "$HOME/.config/herdr/config.toml"

echo "lazygit:"
# Only config.yml is linked: the directory also holds lazygit's session state.
link "lazygit/config.yml"         "$HOME/.config/lazygit/config.yml"

echo "yazi:"
link "yazi/yazi.toml"             "$HOME/.config/yazi/yazi.toml"
link "yazi/theme.toml"            "$HOME/.config/yazi/theme.toml"
link "yazi/flavors"               "$HOME/.config/yazi/flavors"

echo "micro:"
# Only these are linked: ~/.config/micro also holds buffer history and backups.
link "micro/settings.json"        "$HOME/.config/micro/settings.json"
link "micro/colorschemes"         "$HOME/.config/micro/colorschemes"
link "micro/syntax"               "$HOME/.config/micro/syntax"

echo "Codex:"
link "home/AGENTS.md"             "$HOME/.codex/AGENTS.md"

echo "SSH (template - seeded, not symlinked, to keep real values private):"
run "mkdir -p \"$HOME/.ssh\""
run "chmod 700 \"$HOME/.ssh\" 2>/dev/null || true"
if [[ -e "$HOME/.ssh/config" ]]; then
  log "OK    $HOME/.ssh/config already exists - left untouched"
else
  log "SEED  ssh/config.example -> $HOME/.ssh/config (edit in real values)"
  run "cp \"$DOTFILES/ssh/config.example\" \"$HOME/.ssh/config\""
  run "chmod 600 \"$HOME/.ssh/config\""
fi

if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
  echo
  echo "Login shell is ${SHELL:-unset}; switch with: chsh -s \"$(command -v zsh)\""
fi

echo
echo "Done. Backups (if any) use the suffix .bak.$TS"
echo "Next: open a new shell (exec zsh). If herdr is running here, restart it"
echo "with 'herdr server stop' so it picks up the new shell and config."
