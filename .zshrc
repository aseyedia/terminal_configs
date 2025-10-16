# If you come from bash you might have to change your $PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

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

export ZPLUG_HOME=/Users/seyediana/.zplug
source $ZPLUG_HOME/init.zsh

zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug "plugins/nvm", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh

ZOXIDE_CMD_OVERRIDE="cd"
zplug "plugins/zoxide", from:oh-my-zsh

zplug "junegunn/fzf", use:"shell/*.zsh", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
zplug 'zsh-users/zsh-completions', depth:1 # more completions

zplug load
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
