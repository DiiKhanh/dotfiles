command_exists() {
  command -v "$@" &> /dev/null
}

# Customize LS colors
# Used by: ls, fd
LS_COLORS=""
LS_COLORS+="di=34;;1:" # Directories
LS_COLORS+="ex=33:"    # Executable files
LS_COLORS+="ln=36:"    # Symlinks
LS_COLORS+="or=31:"    # Broken symlinks
export LS_COLORS

# Eza colors: https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
EZA_COLORS="reset:$LS_COLORS"       # Reset default colors, like making everything yellow
EZA_COLORS+="da=36:"                # Timestamps
EZA_COLORS+="ur=0:uw=0:ux=0:ue=0:"  # User permissions
EZA_COLORS+="gr=0:gw=0:gx=0:"       # Group permissions
EZA_COLORS+="tr=0:tw=0:tx=0:"       # Other permissions
EZA_COLORS+="xa=0:"                 # Extended attribute marker ('@')
EZA_COLORS+="xx=90:"                # Punctuation ('-') (black)
EZA_COLORS+="nb=90:"                # Files under 1 KB (black)
EZA_COLORS+="nk=90:"                # Files under 1 MB (black)
EZA_COLORS+="nm=37:"                # Files under 1 GB (white)
EZA_COLORS+="ng=97:"                # Files under 1 TB (bright white)
EZA_COLORS+="nt=97:"                # Files over 1 TB (bright white)
EZA_COLORS+="do=32:*.md=32:"        # Documents (green)
EZA_COLORS+="co=35:*.zip=35:"       # Archives (magenta)
EZA_COLORS+="tm=90:cm=90:.*=90:"    # Hidden and temporary files (black)
export EZA_COLORS

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias gs="git status -s"
alias ga="git add ."
alias gcm="git commit -m"
alias gf="git fetch"
alias gp="git pull"
alias gpush="git push origin"
alias glog="git log --oneline --decorate --all --graph"

# alias for common
alias cls="clear"

# Easier navigation
alias .="printf '\U000F17A9 ' && pwd"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# zshrc config
alias reload="source ~/.zshrc && echo 'Shell config reloaded from ~/.zshrc'"

# Sane defaults for built-ins (verbose and interactive)
alias grep="grep -i --color=auto"


# Bat: https://github.com/sharkdp/bat
command_exists bat && alias cat="bat --style=plain"
# Fd: https://github.com/sharkdp/fd
# command_exists fd && alias find="fd"

# Eza: https://eza.rocks/
# Display all clickable entries as a grid with icons
command_exists eza && alias ls="eza --no-user --hyperlink --icons=auto --group-directories-first --color-scale=age -a"
# Display a detailed clickable directory tree with a Git status
command_exists eza && alias lt="ls --tree --level=2 --long --header --git --git-ignore"

# Enable fzf: https://github.com/junegunn/fzf
if command_exists fzf; then
  source $HOME/dotfiles/zsh/fzf.zsh
fi

# Preview and open files in the current dir
command_exists fzf && command_exists bat && alias preview="fzf --preview 'bat --style=numbers --color=always {}'"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# Added by Antigravity IDE
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
