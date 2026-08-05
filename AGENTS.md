# Project notes for agents

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.

## What this repo is

Symlink-based macOS dotfiles. `install.sh` links files from topic dirs
(`zsh/`, `git/`, `ghostty/`, `claude/`, `ssh/`, `cursor/`) into `$HOME`.
Authoritative map of every managed file: `README.md` and the `link` calls in
`install.sh`. `bootstrap.sh` provisions a fresh machine (brew, Brewfile, omz,
sdkman, nvm) then calls `install.sh`.

## Rules for agents working here

- **The repo is the source of truth.** Configs in `$HOME` are symlinks back
  here, so editing e.g. `~/.zshrc` edits `zsh/.zshrc`. Edit files in the repo.
- **To manage a new config**: put the file in (or add) a topic dir, add one
  `link "<repo-path>" "<dest>"` line in `install.sh`, and add a row to the
  README table. Keep those three in sync - they are the contract.
- **Never commit secrets.** SSH keys and the real `~/.ssh/config`,
  `settings.local.json`, history, sessions, caches stay out. `.gitignore`
  enforces this; only `ssh/config.example` (a redacted placeholder template) is
  tracked under `ssh/`. The real `~/.ssh/config` is seeded from it and never
  symlinked back. Check `.gitignore` before adding anything under `ssh/` or
  `claude/`, and keep real hosts/users/keys out of the template.
- **`install.sh` must stay idempotent and non-destructive**: it backs up any
  existing real file to `<dest>.bak.<timestamp>` before linking. Preserve that
  behavior. Verify changes with `DRY_RUN=1 ./install.sh`.
- **Regenerate `Brewfile`** with `brew bundle dump --file=Brewfile --force`;
  hand-added GUI casks (ghostty, cursor) carry a comment - do not drop them.
- **Don't confuse the two AGENTS.md files.** This one is repo/agent notes.
  `home/AGENTS.md` is symlinked to `~/.claude/CLAUDE.md` (global Claude
  instructions) - editing it changes agent behavior everywhere, not just here.
- **`zsh/fzf.zsh` is sourced directly from the repo path** by `.zshrc`, so it
  is intentionally not symlinked. Don't add a `link` line for it.
- Follow the user's global git rule: commit only when explicitly asked, and do
  not add agent co-author trailers.
