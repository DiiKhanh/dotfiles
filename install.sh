#!/usr/bin/env bash
#
# install.sh - symlink dotfiles from this repo into their expected locations.
#
# Idempotent and safe: any existing real file/dir at a destination is moved to
# "<dest>.bak.<timestamp>" before the symlink is created. Re-running only fixes
# links that are missing or wrong.
#
# Usage:
#   ./install.sh            # create/repair all symlinks
#   DRY_RUN=1 ./install.sh  # print what would happen, change nothing

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"

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

echo "Dotfiles: $DOTFILES"
[[ "$DRY_RUN" == "1" ]] && echo "(dry run - no changes will be made)"
echo

echo "Zsh:"
link "zsh/.zshrc"                 "$HOME/.zshrc"
link "zsh/.zprofile"              "$HOME/.zprofile"
link "zsh/.zshrc.pre-oh-my-zsh"   "$HOME/.zshrc.pre-oh-my-zsh"
# Note: fzf.zsh is sourced directly from this repo by .zshrc, so it needs no link.

echo "Git:"
link "git/.gitconfig"             "$HOME/.gitconfig"
link "git/ignore"                 "$HOME/.config/git/ignore"

echo "Ghostty:"
link "ghostty"                    "$HOME/.config/ghostty"

echo "Claude Code:"
link "claude/settings.json"       "$HOME/.claude/settings.json"
link "claude/rules"               "$HOME/.claude/rules"
link "home/AGENTS.md"             "$HOME/.claude/CLAUDE.md"

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

echo "Cursor:"
link "cursor/settings.json"       "$HOME/Library/Application Support/Cursor/User/settings.json"
link "cursor/keybindings.json"    "$HOME/Library/Application Support/Cursor/User/keybindings.json"

echo
echo "Done. Backups (if any) use the suffix .bak.$TS"
