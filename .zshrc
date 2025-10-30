# ============================================================================
# Fast ZSH Configuration (No Oh My Zsh)
# ============================================================================
# This is a faster version that skips Oh My Zsh entirely
# Expected startup time: ~0.3-0.4s (vs 0.8s with OMZ)

# ============================================================================
# Local Configuration
# ============================================================================
# Load local config if it exists (not tracked by git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ============================================================================
# Startup Time Measurement
# ============================================================================
# Set ZSH_STARTUP_TIME=true to display shell startup time
# Set ZSH_PROFILE=true to show detailed profiling
if [[ "$ZSH_STARTUP_TIME" == "true" ]] || [[ "$ZSH_PROFILE" == "true" ]]; then
    zmodload zsh/datetime
    startup_start=$EPOCHREALTIME
fi

# Profiling function
profile_step() {
    if [[ "$ZSH_PROFILE" == "true" ]] && [[ -n "$startup_start" ]]; then
        local step_end=$EPOCHREALTIME
        local step_time=$(printf "%.3f" $(($step_end - ${profile_last:-$startup_start})))
        local total_time=$(printf "%.3f" $(($step_end - $startup_start)))
        printf "[%s] %s (total: %s)\n" "$step_time" "$1" "$total_time"
        profile_last=$step_end
    fi
}

# ============================================================================
# PATH Configuration
# ============================================================================
# Set initial PATH with system paths first
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/bin:$HOME/.local/bin:$PATH"

# Homebrew initialization (this will prepend Homebrew paths)
if [[ -f /opt/homebrew/bin/brew ]]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    # Linux
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

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
# ZSH Options & History
# ============================================================================
# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000                      # Number of commands to remember in current session
SAVEHIST=10000                      # Number of commands to save to history file
setopt HIST_IGNORE_ALL_DUPS         # Remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS            # Don't show duplicates when searching history
setopt HIST_SAVE_NO_DUPS            # Don't write duplicate entries to history file
setopt SHARE_HISTORY                # Share history between all sessions
setopt APPEND_HISTORY               # Append to history file (don't overwrite)
setopt INC_APPEND_HISTORY           # Write to history file immediately, not on shell exit

# Other useful options
setopt AUTO_CD                      # Type directory name to cd into it (no need for 'cd')
setopt AUTO_PUSHD                   # Automatically push directories onto the directory stack
setopt PUSHD_IGNORE_DUPS            # Don't push duplicate directories onto the stack
setopt INTERACTIVE_COMMENTS         # Allow comments in interactive shell (lines starting with #)

profile_step "ZSH options set"

# ============================================================================
# Environment Variables
# ============================================================================
export LANG=en_US.UTF-8
export EDITOR='nvim'
export VISUAL='nvim'

# ============================================================================
# Completion System
# ============================================================================
# Initialize completion (faster than OMZ)
autoload -Uz compinit

# Only regenerate compdump once a day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

profile_step "Completion initialized"

# ============================================================================
# Zplug Plugin Manager
# ============================================================================
export ZPLUG_HOME=~/.zplug

if [[ ! -d $ZPLUG_HOME ]]; then
    echo "Installing zplug..."
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

source $ZPLUG_HOME/init.zsh

profile_step "Zplug initialized"

# ============================================================================
# Zplug Plugins (Minimal Set)
# ============================================================================
# Pure theme
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# Essential plugins only
zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Load plugins
zplug load

profile_step "Zplug plugins loaded"

# Install plugins if needed (quiet check)
if ! zplug check; then
    zplug install
fi

profile_step "Zplug check complete"

# ============================================================================
# Zoxide (Better cd)
# ============================================================================
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

profile_step "Zoxide initialized"

# ============================================================================
# FZF Configuration
# ============================================================================
# Auto-install FZF if not present
if ! command -v fzf &>/dev/null && [[ ! -d ~/.fzf ]]; then
    echo "FZF not found. Installing..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF options
export FZF_DEFAULT_OPTS="--height=40% --border --inline-info"

# FZF commands with fd if available
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# FZF preview with bat if available
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi

profile_step "FZF configured"

# ============================================================================
# Custom Aliases
# ============================================================================
alias vim='nvim'
alias vi='nvim'
alias zshconfig="nvim ~/.zshrc"
alias zshreload="source ~/.zshrc"

# Git aliases (replacing OMZ git plugin)
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

# Eza aliases (if installed)
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first'
    alias ll='eza --group-directories-first -lh --git --group'
    alias la='eza --group-directories-first -lha --git --group'
    alias l='eza --group-directories-first -lh --git --group'
    alias lt='eza --group-directories-first -lh --git --group --sort=modified'
    alias tree='eza --tree'
    alias tree2='eza --tree --level=2'
    alias tree3='eza --tree --level=3'
fi

# Bat integration (if installed)
if command -v bat &>/dev/null; then
    alias cat='bat'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

profile_step "Aliases configured"

# ============================================================================
# Git Prompt (Replacing OMZ)
# ============================================================================
# Pure theme handles this, but you can customize if needed

# ============================================================================
# Startup Time Display
# ============================================================================
if [[ "$ZSH_STARTUP_TIME" == "true" ]] || [[ "$ZSH_PROFILE" == "true" ]]; then
    if [[ -n "$startup_start" ]]; then
        startup_end=$EPOCHREALTIME
        startup_time=$(printf "%.3f" $(($startup_end - $startup_start)))
        echo "⚡ zsh startup: ${startup_time}s"
    fi
fi
