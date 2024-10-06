#!/bin/bash

set -euo pipefail

# ================================
# Configuration Variables
# ================================

# Directories
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
SOURCE_DIR="$(pwd)"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
POWERLEVEL10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# ================================
# Helper Functions
# ================================

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages using the appropriate package manager
install_packages() {
    echo "Detecting package manager..."

    if command_exists apt-get; then
        PM="apt-get"
        UPDATE_CMD="sudo apt-get update"
        INSTALL_CMD="sudo apt-get install -y"
    elif command_exists brew; then
        PM="brew"
        UPDATE_CMD="brew update"
        INSTALL_CMD="brew install"
    elif command_exists pacman; then
        PM="pacman"
        UPDATE_CMD="sudo pacman -Sy"
        INSTALL_CMD="sudo pacman -S --noconfirm"
    else
        echo "Unsupported package manager. Please install the required packages manually."
        echo "Required packages: git, zsh, tmux, neovim, wget, curl"
        exit 1
    fi

    echo "Using package manager: $PM"

    echo "Updating package lists..."
    eval "$UPDATE_CMD"

    REQUIRED_PACKAGES=(git zsh tmux neovim wget curl)

    echo "Installing required packages..."
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! command_exists "$pkg"; then
            echo "Installing $pkg..."
            eval "$INSTALL_CMD $pkg"
        else
            echo "$pkg is already installed."
        fi
    done
}

# Function to backup and replace a configuration file
backup_and_replace() {
    local src=$1
    local dest=$2

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $(basename "$dest") to $BACKUP_DIR..."
        mkdir -p "$(dirname "$BACKUP_DIR/$dest")"
        cp -r "$dest" "$BACKUP_DIR/"
    fi

    echo "Replacing $(basename "$dest") with the version from the repository..."
    ln -sfn "$src" "$dest"
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        echo "Installing Oh My Zsh..."
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Oh My Zsh is already installed."
    fi
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    if [ ! -d "$POWERLEVEL10K_DIR" ]; then
        echo "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL10K_DIR"
    else
        echo "Powerlevel10k is already installed."
    fi
}

# Function to install Zoxide
install_zoxide() {
    if ! command_exists zoxide; then
        echo "Installing Zoxide..."
        if command_exists brew; then
            brew install zoxide
        elif command_exists cargo; then
            cargo install zoxide
        else
            echo "Zoxide installation method not found. Please install it manually."
            exit 1
        fi
    else
        echo "Zoxide is already installed."
    fi
}

# Function to initialize Git submodules
initialize_git_submodules() {
    echo "Initializing Git submodules..."
    git submodule update --init --recursive
}

# Function to set Zsh as the default shell
set_zsh_as_default() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Changing default shell to Zsh..."
        chsh -s "$(which zsh)"
        echo "Please log out and log back in to apply the shell change."
    else
        echo "Zsh is already the default shell."
    fi
}

# Function to reload tmux configuration
reload_tmux() {
    if command_exists tmux; then
        if tmux ls &>/dev/null; then
            echo "Reloading tmux configuration..."
            tmux source-file "$SOURCE_DIR/tmux.conf"
        else
            echo "No active tmux sessions found. Skipping tmux reload."
        fi
    fi
}

# ================================
# Main Installation Process
# ================================

echo "Starting dotfiles installation..."

# Install required packages
install_packages

# Initialize Git submodules (e.g., Neovim configurations)
initialize_git_submodules

# Install Oh My Zsh
install_oh_my_zsh

# Install Powerlevel10k theme
install_powerlevel10k

# Install Zoxide
install_zoxide

# Set Zsh as the default shell
set_zsh_as_default

# Create backup directory
echo "Creating backup directory at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Backup and replace configurations
echo "Backing up and setting up configurations..."
# Backup and replace .zshrc
backup_and_replace "$SOURCE_DIR/.zshrc" "$HOME/.zshrc"

# Backup and replace tmux.conf if it exists in the repository
if [ -f "$SOURCE_DIR/tmux.conf" ]; then
    backup_and_replace "$SOURCE_DIR/tmux.conf" "$HOME/.tmux.conf"
fi

# Backup and replace Neovim configurations if they exist in the repository
if [ -d "$SOURCE_DIR/nvim" ]; then
    backup_and_replace "$SOURCE_DIR/nvim" "$CONFIG_DIR/nvim"
fi

# Reload tmux configuration if applicable
reload_tmux

echo "Configuration backup and setup complete."
echo "Backups are stored in $BACKUP_DIR"
echo "New configurations have been placed in your home directory and $CONFIG_DIR"

echo "Please restart your terminal or log out and log back in to apply all changes."

# ================================
# End of Script
# ================================

