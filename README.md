# dotfiles

Personal macOS development environment. Clone this on a new machine, run one
script, and get the familiar setup back.

## What is managed

| Tool | Repo path | Symlinked to |
|------|-----------|--------------|
| Zsh | `zsh/.zshrc`, `zsh/.zprofile`, `zsh/.zshrc.pre-oh-my-zsh`, `zsh/fzf.zsh` | `~/.zshrc`, `~/.zprofile`, … (`fzf.zsh` is sourced directly from the repo) |
| Git | `git/.gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| Ghostty | `ghostty/` | `~/.config/ghostty` |
| Claude Code | `claude/settings.json`, `claude/rules/`, `home/AGENTS.md` | `~/.claude/settings.json`, `~/.claude/rules`, `~/.claude/CLAUDE.md` |
| SSH | `ssh/config.example` | seeded to `~/.ssh/config` if absent (not symlinked) |
| Cursor | `cursor/settings.json`, `cursor/keybindings.json` | `~/Library/Application Support/Cursor/User/…` |
| Homebrew | `Brewfile` | installed via `brew bundle` |

## New machine setup

```sh
git clone git@github.com:DiiKhanh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Homebrew, the `Brewfile` packages (CLI + casks like
Raycast/Ghostty/Cursor), Oh My Zsh + plugins, SDKMAN, nvm + Node LTS, then runs
`install.sh` to symlink every config.

Already have the tools and only want the symlinks:

```sh
./install.sh            # create/repair symlinks (backs up anything in the way)
DRY_RUN=1 ./install.sh  # preview without changing anything
```

## What is deliberately NOT stored

- **SSH keys and the real `~/.ssh/config`.** Only `ssh/config.example` (a
  redacted template with placeholder hosts/users) is tracked. Copy keys in
  manually and `chmod 600`; edit real hosts into `~/.ssh/config` after seeding.
- Claude Code runtime/secrets: `settings.local.json`, `history.jsonl`,
  `sessions/`, `projects/`, caches, `.zsh_history`, `stats-cache.json`.
- Anything installed by the bootstrap: `~/.oh-my-zsh`, `~/.sdkman`, `~/.nvm`.

## Notes / manual steps

- **Fonts**: `ghostty/font/*` snippets reference many Nerd Fonts. Install the
  ones you use separately, or Ghostty falls back to a default.
- **Claude statusline**: `claude/settings.json` hardcodes a Node path
  (`~/.nvm/versions/node/<version>/bin/node`). If the Node version differs on a
  new machine, update it there.
- **Paths use `$HOME`**: shell configs and the Claude statusline reference
  `$HOME` (not a hardcoded username), so they are portable across machines.

## Updating configs

Because everything is symlinked, editing a file in place (e.g. `~/.zshrc`)
edits the repo copy directly. Just `git add` / `git commit` here.
