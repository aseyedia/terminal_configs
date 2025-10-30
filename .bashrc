# ============================================================================
# .bashrc - Bash Configuration
# ============================================================================

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ============================================================================
# Startup Time Measurement
# ============================================================================
# Set BASH_STARTUP_TIME=true to display shell startup time
# Set BASH_PROFILE=true to show detailed profiling
if [[ "$BASH_STARTUP_TIME" == "true" ]] || [[ "$BASH_PROFILE" == "true" ]]; then
    startup_start=$(date +%s%N)
fi

# Profiling function
profile_step() {
    if [[ "$BASH_PROFILE" == "true" ]]; then
        local step_end=$(date +%s%N)
        local step_time=$(awk "BEGIN {printf \"%.3f\", (${step_end} - ${profile_last:-$startup_start}) / 1000000000}")
        local total_time=$(awk "BEGIN {printf \"%.3f\", (${step_end} - ${startup_start}) / 1000000000}")
        printf "[%s] %s (total: %s)\n" "$step_time" "$1" "$total_time"
        profile_last=$step_end
    fi
}

# ============================================================================
# PATH Configuration
# ============================================================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Add Neovim to PATH if installed manually
if [[ -d /opt/nvim-linux-x86_64/bin ]]; then
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
elif [[ -d /opt/nvim-macos-arm64/bin ]]; then
    export PATH="$PATH:/opt/nvim-macos-arm64/bin"
elif [[ -d /opt/nvim-macos-x86_64/bin ]]; then
    export PATH="$PATH:/opt/nvim-macos-x86_64/bin"
fi

profile_step "PATH configuration"

# ============================================================================
# History Configuration
# ============================================================================
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and commands starting with space
shopt -s histappend               # Append to history, don't overwrite
shopt -s cmdhist                  # Save multi-line commands as one entry

profile_step "History configured"

# ============================================================================
# Shell Options
# ============================================================================
shopt -s checkwinsize             # Update LINES and COLUMNS after each command
shopt -s globstar 2>/dev/null     # Enable ** recursive globbing
shopt -s nocaseglob               # Case-insensitive globbing
shopt -s cdspell                  # Autocorrect typos in path names when using cd
shopt -s dirspell 2>/dev/null     # Autocorrect directory names

profile_step "Shell options set"

# ============================================================================
# Environment Variables
# ============================================================================
export LANG=en_US.UTF-8
export EDITOR='nvim'
export VISUAL='nvim'
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

profile_step "Environment variables"

# ============================================================================
# Colors
# ============================================================================
# Reset
Color_Off='\[\033[0m\]'

# Regular Colors
Black='\[\033[0;30m\]'
Red='\[\033[0;31m\]'
Green='\[\033[0;32m\]'
Yellow='\[\033[0;33m\]'
Blue='\[\033[0;34m\]'
Purple='\[\033[0;35m\]'
Cyan='\[\033[0;36m\]'
White='\[\033[0;37m\]'

# Bold
BBlack='\[\033[1;30m\]'
BRed='\[\033[1;31m\]'
BGreen='\[\033[1;32m\]'
BYellow='\[\033[1;33m\]'
BBlue='\[\033[1;34m\]'
BPurple='\[\033[1;35m\]'
BCyan='\[\033[1;36m\]'
BWhite='\[\033[1;37m\]'

# ============================================================================
# Git Prompt Function
# ============================================================================
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# ============================================================================
# Custom Prompt (PS1)
# ============================================================================
# Format: user@host:directory (git-branch) $
export PS1="${BGreen}\u@\h${Color_Off}:${BBlue}\w${Color_Off}${BPurple}\$(parse_git_branch)${Color_Off}\$ "

profile_step "Prompt configured"

# ============================================================================
# FZF Configuration
# ============================================================================
# Auto-install FZF if not present
if ! command -v fzf &>/dev/null && [[ ! -d ~/.fzf ]]; then
    echo "FZF not found. Installing..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
fi

# Initialize FZF if installed via Homebrew
if [[ -f /opt/homebrew/opt/fzf/shell/completion.bash ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.bash
fi

if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.bash
fi

# Initialize FZF if installed via git
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# FZF default options
export FZF_DEFAULT_OPTS="
  --height=40%
  --border
  --inline-info
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
"

# FZF file search (respects .gitignore)
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# FZF preview with bat
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi

profile_step "FZF configured"

# ============================================================================
# Zoxide (better cd)
# ============================================================================
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    # Override cd with zoxide
    alias cd='z'
fi

profile_step "Zoxide initialized"

# ============================================================================
# Homebrew
# ============================================================================
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

profile_step "Homebrew initialized"

# ============================================================================
# Aliases
# ============================================================================
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Editor
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Eza (better ls) integration
if command -v eza &> /dev/null; then
    # Basic ls replacement (no icons to avoid ? characters on systems without Nerd Fonts)
    alias ls='eza --group-directories-first'
    alias ll='eza --group-directories-first -lh --git --group'
    alias la='eza --group-directories-first -lha --git --group'
    alias l='eza --group-directories-first -lh --git --group'
    alias lt='eza --group-directories-first -lh --git --group --sort=modified'
    
    # Tree views
    alias tree='eza --tree'
    alias tree2='eza --tree --level=2'
    alias tree3='eza --tree --level=3'
    
    # Detailed views
    alias lsa='eza --group-directories-first -lha --git --git-repos --total-size --group'
    alias lsf='eza --group-directories-first -lh --git --only-files --group'
    alias lsd='eza --group-directories-first -lh --git --only-dirs --group'
else
    # Fallback to standard ls
    alias ls='ls -G'
    alias ll='ls -alFh'
    alias la='ls -A'
    alias l='ls -CF'
    alias lt='ls -alFht'
fi

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Utilities
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias path='echo -e ${PATH//:/\\n}'
alias ports='netstat -tulanp'

# Config shortcuts
alias bashconfig='nvim ~/.bashrc'
alias bashreload='source ~/.bashrc'
alias zshconfig='nvim ~/.zshrc'

# Bat (better cat) integration
if command -v bat &> /dev/null; then
    alias cat='bat'
    alias bathelp='bat --plain --language=help'
    
    # Help function with bat (unalias first in case it's already defined)
    unalias help 2>/dev/null
    help() {
        "$@" --help 2>&1 | bathelp
    }
    
    # Man pages with bat
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Tmux
alias t='tmux'
alias ta='tmux attach'
alias tls='tmux ls'
alias tn='tmux new -s'

profile_step "Aliases configured"

# ============================================================================
# Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find file by name
ff() {
    find . -type f -iname "*$1*"
}

# Find directory by name
fd() {
    find . -type d -iname "*$1*"
}

# Quick git add, commit, push
gacp() {
    git add .
    git commit -m "$1"
    git push
}

# Weather from wttr.in
weather() {
    local city="${1:-}"
    curl -s "wttr.in/${city}?format=3"
}

# Cheat sheet from cht.sh
cheat() {
    curl -s "cht.sh/$1"
}

profile_step "Functions defined"

# ============================================================================
# Bash Completion
# ============================================================================
if [[ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    source /opt/homebrew/etc/profile.d/bash_completion.sh
elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

profile_step "Bash completion loaded"

# ============================================================================
# Local Configuration (not tracked by git)
# ============================================================================
# Add machine-specific configuration to ~/.bashrc.local
if [[ -f ~/.bashrc.local ]]; then
    source ~/.bashrc.local
fi

profile_step "Local config loaded"

# ============================================================================
# Startup Time Display
# ============================================================================
if [[ "$BASH_STARTUP_TIME" == "true" ]] || [[ "$BASH_PROFILE" == "true" ]]; then
    startup_end=$(date +%s%N)
    startup_time=$(awk "BEGIN {printf \"%.3f\", (${startup_end} - ${startup_start}) / 1000000000}")
    echo "⚡ bash startup: ${startup_time}s"
fi

# ============================================================================
# Welcome Message (optional - comment out if you don't want it)
# ============================================================================
# echo -e "${BGreen}Welcome back, $(whoami)!${Color_Off}"
# echo -e "${BBlue}Today is $(date '+%A, %B %d, %Y')${Color_Off}"
