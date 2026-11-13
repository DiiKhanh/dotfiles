# dotfiles (linux branch)

Ubuntu variant of the macOS dotfiles on `main`, for headless hosts such as a
VPS used as a herdr SSH machine. Tested on Ubuntu 20.04 (x86_64 and aarch64).
Claude Code and Ghostty are not set up here; `claude/`, `ghostty/`,
`bootstrap.sh` and `Brewfile` are macOS-only leftovers from `main`.

## What is managed

| Tool | Repo path | Symlinked to |
|------|-----------|--------------|
| Zsh | `zsh/.zshrc`, `zsh/.zprofile`, `zsh/.zshrc.pre-oh-my-zsh`, `zsh/fzf.zsh` | `~/.zshrc`, `~/.zprofile`, … (`fzf.zsh` is sourced directly from the repo) |
| Git | `git/.gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` (identity lives in `~/.gitconfig.local`) |
| herdr | `herdr/config.toml` | `~/.config/herdr/config.toml` |
| lazygit | `lazygit/config.yml` | `~/.config/lazygit/config.yml` |
| yazi | `yazi/yazi.toml`, `yazi/theme.toml`, `yazi/flavors/` | `~/.config/yazi/yazi.toml`, `~/.config/yazi/theme.toml`, `~/.config/yazi/flavors` |
| micro | `micro/settings.json`, `micro/colorschemes/`, `micro/syntax/` | `~/.config/micro/settings.json`, `~/.config/micro/colorschemes`, `~/.config/micro/syntax` |
| Codex | `home/AGENTS.md` | `~/.codex/AGENTS.md` |
| SSH | `ssh/config.example` | seeded to `~/.ssh/config` if absent (not symlinked) |
| CLI tools | `linux/tools.sh` | fzf, eza, fd, bat, delta, lazygit, yazi, micro, jq, gh in `~/.local/bin` |
| Oh My Zsh | `linux/tools.sh` | `~/.oh-my-zsh` + zsh-autosuggestions, zsh-syntax-highlighting |
| Ghostty terminfo | `linux/xterm-ghostty.terminfo` | compiled into `~/.terminfo` |

## Setup

Needs `git`, `curl`, `zsh` and `python3` (or `unzip`); no sudo.

```sh
git clone -b linux https://github.com/DiiKhanh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh
```

The clone must live at `~/dotfiles`: `.zshrc` sources files from that path.

```sh
DRY_RUN=1 ./install.sh       # preview without changing anything
SKIP_TOOLS=1 ./install.sh    # symlinks only
UPDATE_TOOLS=1 ./install.sh  # reinstall tools at the pinned versions
```

## Why it differs from main

- **Tools come from pinned upstream releases**, verified by SHA256, because
  Ubuntu 20.04's apt has fzf 0.20 (too old for `zsh/fzf.zsh`) and no eza,
  delta, lazygit or yazi. Bump a tool by editing its row in `linux/tools.sh`.
- **herdr panes are non-login shells on Linux**, so `.zshrc` itself puts
  `~/.local/bin` on `PATH` and loads nvm; `.zprofile` does the same for login
  shells such as `zsh -lc` used by Codex.
- **herdr on a saved SSH machine** takes theme and keybindings from the client
  (the Mac), but custom commands (`prefix+alt+g` lazygit, `prefix+alt+f` yazi)
  from this host's `herdr/config.toml`. The quota popup and tab-bar entry are
  dropped: they need quota-axi.
- **Clipboard over SSH** uses OSC 52: fzf `Ctrl-Y` pipes into
  `linux/osc52-copy`, micro uses `"clipboard": "terminal"`.
- **Git** uses `gh auth git-credential` from `PATH` (run `gh auth login` once)
  and no AWS CodeCommit helper.

## What is deliberately NOT stored

- SSH keys and the real `~/.ssh/config`. Prefer `ForwardAgent` from the Mac over
  copying keys to the host.
- Git identity: `~/.gitconfig.local`, filled from an existing `~/.gitconfig` on
  first install.

## Updating configs

Because everything is symlinked, editing a file in place (e.g. `~/.zshrc`)
edits the repo copy directly. Just `git add` / `git commit` here.
