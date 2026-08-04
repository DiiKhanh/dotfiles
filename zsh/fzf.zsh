#!/bin/zsh
# FZF Configuration

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"

export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_COMPLETION_TRIGGER='**'
export FZF_COMPLETION_OPTS='--border --info=inline'

FZF_COLORS="fg:-1,fg+:#1a1625,bg:-1,bg+:#bea3d9,hl:#ca5a83,hl+:#97576f,info:#7254a6,marker:#ceb250,prompt:#7254a6,spinner:#bea3d9,pointer:#bea3d9,header:#e9d6fa,border:#644e88,label:#bea3d9,query:#e9d6fa,disabled:#7254a6"

export FZF_DEFAULT_OPTS="--height 60% --border rounded --layout reverse --color '$FZF_COLORS' --prompt '▶ ' --pointer ▪︎ --marker '✔ ' --bind='ctrl-o:execute(code {})+abort' --bind 'ctrl-/:change-preview-window(hidden|)' --preview-window='border-rounded' --info right"

_fzf_compgen_path() {
  fd --hidden --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --exclude ".git" . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

source <(fzf --zsh)
