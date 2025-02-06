#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
# https://timonbimon.medium.com/yet-another-step-by-step-guide-for-a-better-terminal-setup-6c5e879d4c8c

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

eval "$(zoxide init --cmd cd zsh)"

eval "$(starship init zsh)"

source /usr/share/doc/fzf/examples/key-bindings.zsh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

alias ls="eza --icons --long --header"
