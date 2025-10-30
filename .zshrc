# ============================================================================
# Startup Time Measurement
# ============================================================================
# Set ZSH_STARTUP_TIME=true to display shell startup time
# Set ZSH_PROFILE=true to show detailed profiling
# Start timer
ZSH_STARTUP_TIME=true
ZSH_PROFILE=true
if [[ "$ZSH_STARTUP_TIME" == "true" ]] || [[ "$ZSH_PROFILE" == "true" ]]; then
    zmodload zsh/datetime
    startup_start=$EPOCHREALTIME
fi

# Profiling function
profile_step() {
    if [[ "$ZSH_PROFILE" == "true" ]]; then
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
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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
# Oh My Zsh Configuration
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Using Pure theme via zplug

# Oh My Zsh Settings
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

# Minimal plugins for OMZ
plugins=(git)

zstyle ':omz:plugins:nvm' lazy yes
source $ZSH/oh-my-zsh.sh

profile_step "Oh My Zsh loaded"

# ============================================================================
# Environment Variables
# ============================================================================
export LANG=en_US.UTF-8
export EDITOR='nvim'
export VISUAL='nvim'

profile_step "Environment variables"

# ============================================================================
# Zplug Plugin Manager
# ============================================================================
export ZPLUG_HOME=~/.zplug

# Check if zplug is installed
if [[ ! -d $ZPLUG_HOME ]]; then
    echo "Installing zplug..."
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

source $ZPLUG_HOME/init.zsh

profile_step "Zplug initialized"

# ============================================================================
# Zplug Plugins
# ============================================================================
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

ZOXIDE_CMD_OVERRIDE="cd"
# zplug "plugins/nvm", from:oh-my-zsh
zplug "plugins/zoxide", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh

# zplug "zsh-users/zsh-completions", depth:1
zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Load all plugins
zplug load

profile_step "Zplug plugins loaded"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

profile_step "Zplug check complete"

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

profile_step "FZF configured"

# FZF options
export FZF_DEFAULT_OPTS="--height=40% --border --inline-info"

# FZF commands with fd/ripgrep if available
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# FZF preview with bat if available
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi

profile_step "FZF options set"

# ============================================================================
# Custom Aliases
# ============================================================================
alias vim='nvim'
alias vi='nvim'
alias zshconfig="nvim ~/.zshrc"
alias zshreload="source ~/.zshrc"

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
# Startup Time Display
# ============================================================================
if [[ "$ZSH_STARTUP_TIME" == "true" ]] || [[ "$ZSH_PROFILE" == "true" ]]; then
    startup_end=$EPOCHREALTIME
    startup_time=$(printf "%.3f" $(($startup_end - $startup_start)))
    echo "zsh startup: ${startup_time}s"
fi

# Add machine-specific configuration to ~/.zshrc.local
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
