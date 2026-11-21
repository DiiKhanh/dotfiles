# dotfiles

Personal macOS development environment. Clone this on a new machine, run one
script, and get the familiar setup back.

## What is managed

| Tool | Repo path | Symlinked to |
|------|-----------|--------------|
| Zsh | `zsh/.zshenv`, `zsh/.zshrc`, `zsh/.zprofile`, `zsh/.zshrc.pre-oh-my-zsh`, `zsh/fzf.zsh`, `zsh/codex-prune.zsh` | `~/.zshenv`, `~/.zshrc`, `~/.zprofile`, … (`fzf.zsh` and `codex-prune.zsh` are sourced directly from the repo) |
| Git | `git/.gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` |
| Ghostty | `ghostty/` | `~/.config/ghostty` |
| herdr | `herdr/config.toml`, `herdr/quota-status.sh` | `~/.config/herdr/config.toml`, `~/.config/herdr/quota-status.sh` |
| lazygit | `lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` |
| yazi | `yazi/yazi.toml`, `yazi/theme.toml`, `yazi/flavors/` | `~/.config/yazi/yazi.toml`, `~/.config/yazi/theme.toml`, `~/.config/yazi/flavors` |
| micro | `micro/settings.json`, `micro/colorschemes/`, `micro/syntax/` | `~/.config/micro/settings.json`, `~/.config/micro/colorschemes`, `~/.config/micro/syntax` |
| Claude Code | `claude/settings.json`, `claude/rules/`, `home/AGENTS.md` | `~/.claude/settings.json`, `~/.claude/rules`, `~/.claude/CLAUDE.md` |
| Codex | `home/AGENTS.md` | `~/.codex/AGENTS.md` |
| OMP | `home/AGENTS.md` | `~/.omp/agent/AGENTS.md` |
| opencode | `home/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| SSH | `ssh/config.example` | seeded to `~/.ssh/config` if absent (not symlinked) |
| Homebrew | `Brewfile` | installed via `brew bundle` |

## New machine setup

```sh
git clone git@github.com:DiiKhanh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Homebrew, the `Brewfile` packages (CLI + casks like
Raycast/Ghostty), Oh My Zsh + plugins, SDKMAN, nvm + Node LTS, then runs
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
- **Claude statusline**: `claude/settings.json` runs claude-hud with an absolute
  bun path under `~/.nvm/versions/node/<version>/` (username included). Update it
  on a new machine or after a Node upgrade.
- **Claude settings are rewritten by tools**: Claude Code and Orca edit
  `~/.claude/settings.json` (Orca installs its agent hooks there) and can replace
  the symlink with a real file. Check `ls -l ~/.claude/settings.json`, copy any
  real file back into the repo, then re-link with `./install.sh`.
- **Paths use `$HOME`**: shell configs reference `$HOME` (not a hardcoded
  username), so they are portable across machines.

## Updating configs

Because everything is symlinked, editing a file in place (e.g. `~/.zshrc`)
edits the repo copy directly. Just `git add` / `git commit` here.
