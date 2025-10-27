# ============================================================================
# PATH Configuration
# ============================================================================
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ============================================================================
# Oh My Zsh Configuration
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Using Pure theme via zplug instead

# Oh My Zsh Settings
DISABLE_UNTRACKED_FILES_DIRTY="true"  # Faster git status for large repos
HIST_STAMPS="yyyy-mm-dd"

# Minimal plugins for OMZ (rest handled by zplug)
plugins=(git)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# Environment Variables
# ============================================================================
export LANG=en_US.UTF-8
export EDITOR='nvim'
export VISUAL='nvim'

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

# ============================================================================
# Zplug Plugins
# ============================================================================
# Theme
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# OMZ plugins via zplug
zplug "plugins/nvm", from:oh-my-zsh
zplug "plugins/zoxide", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh
zplug "plugins/aliases", from:oh-my-zsh
zplug "plugins/alias-finder", from:oh-my-zsh

# Enhanced shell features
zplug "zsh-users/zsh-completions", depth:1
zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Load all plugins
zplug load

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
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# Initialize FZF if installed via git
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF default options (fixes the height error)
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
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ============================================================================
# Zoxide Configuration
# ============================================================================
ZOXIDE_CMD_OVERRIDE="cd"

# ============================================================================
# Custom Aliases
# ============================================================================
alias vim='nvim'
alias vi='nvim'
alias zshconfig="nvim ~/.zshrc"
alias zshreload="source ~/.zshrc"

# ============================================================================
# Performance Optimizations
# ============================================================================
# Skip global compinit as OMZ already handles it
skip_global_compinit=1
