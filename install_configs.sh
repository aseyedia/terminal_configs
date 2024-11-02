#!/bin/bash

set -exuo pipefail

# ================================
# Configuration Variables
# ================================

# Directories
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
SOURCE_DIR="$(pwd)"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
POWERLEVEL10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# OS Detection
OS_TYPE="$(uname -s)"
OS="unknown"

# Flags
DRY_RUN=false

# ================================
# Helper Functions
# ================================

# Function to print messages
log() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Function to handle dry-run
execute() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "\033[1;35m[DRY-RUN]\033[0m $1"
    else
        bash -c "$1"
    fi
}

# Function to display help
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --help        Display this help message and exit.
  --dry-run     Simulate the installation process without making any changes.

Description:
  This script installs and configures your dotfiles, including Zsh, Oh My Zsh,
  Powerlevel10k, Zoxide, Tmux, and Neovim. It ensures idempotency and safely
  backs up existing configurations before applying new ones.

Examples:
  $(basename "$0")           Install dotfiles normally.
  $(basename "$0") --dry-run  Simulate the installation process without changes.
EOF
}

# Function to parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect operating system
detect_os() {
    case "$OS_TYPE" in
        Linux*)     OS="linux";;
        Darwin*)    OS="macos";;
        *)          OS="unknown";;
    esac
    log "Detected OS: $OS"
}

# Function to install packages using the appropriate package manager
install_packages() {
    log "Detecting package manager..."

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
        log_warning "Unsupported package manager. Please install the required packages manually."
        log "Required packages: git, zsh, tmux, wget, curl"
        return
    fi

    log "Using package manager: $PM"

    log "Updating package lists..."
    execute "$UPDATE_CMD"

    REQUIRED_PACKAGES=(git zsh tmux wget curl)

    log "Installing required packages..."
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! command_exists "$pkg"; then
            log "Installing $pkg..."
            execute "$INSTALL_CMD $pkg"
            log_success "$pkg installed."
        else
            log "$pkg is already installed."
        fi
    done
}

# Function to install Neovim based on OS
install_neovim() {
    log "Installing Neovim..."

    if [ "$OS" = "linux" ]; then
        install_neovim_linux
    elif [ "$OS" = "macos" ]; then
        install_neovim_macos
    else
        log_warning "Unsupported OS for Neovim installation. Skipping Neovim setup."
    fi
}

# Function to install Neovim on Linux from GitHub Releases
install_neovim_linux() {
    log "Installing Neovim from GitHub Releases on Linux..."

    # Define variables
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep tag_name | cut -d '"' -f 4)
    NVIM_TAR="nvim-linux64.tar.gz"
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
    NVIM_INSTALL_DIR="/opt/nvim"

    log "Latest Neovim version: $NVIM_VERSION"

    # Download Neovim if not already downloaded
    if [ ! -f "$NVIM_TAR" ]; then
        log "Downloading Neovim from $NVIM_URL..."
        execute "curl -LO \"$NVIM_URL\""
    else
        log "Neovim tarball already exists. Skipping download."
    fi

    # Extract Neovim
    if [ ! -d "$NVIM_INSTALL_DIR" ]; then
        log "Extracting Neovim to $NVIM_INSTALL_DIR..."
        execute "sudo rm -rf \"$NVIM_INSTALL_DIR\""
        execute "sudo tar -C /opt -xzf \"$NVIM_TAR\""
        log_success "Neovim extracted to $NVIM_INSTALL_DIR."
    else
        log "Neovim is already installed in $NVIM_INSTALL_DIR."
    fi

    # Cleanup downloaded tar.gz
    if [ -f "$NVIM_TAR" ]; then
        log "Removing downloaded tarball..."
        execute "rm \"$NVIM_TAR\""
    fi

    # Add Neovim to PATH by appending to shell config if not already present
    NVIM_PATH_ENTRY="/opt/nvim-linux64/bin"
    if ! grep -Fxq "export PATH=\"\$PATH:$NVIM_PATH_ENTRY\"" "$HOME/.zshrc" 2>/dev/null; then
        log "Adding Neovim to PATH in .zshrc..."
        execute "echo 'export PATH=\"\$PATH:$NVIM_PATH_ENTRY\"' >> \"$HOME/.zshrc\""
        log_success "Neovim path added to .zshrc."
    else
        log "Neovim path already exists in .zshrc."
    fi

    log_success "Neovim $NVIM_VERSION installed successfully."
}

# Function to install Neovim on macOS using Homebrew
install_neovim_macos() {
    log "Installing Neovim using Homebrew on macOS..."

    if ! command_exists brew; then
        log_error "Homebrew is not installed. Please install Homebrew first: https://brew.sh/"
        exit 1
    fi

    if brew list neovim &>/dev/null; then
        log "Neovim is already installed via Homebrew."
    else
        log "Installing Neovim via Homebrew..."
        execute "brew install neovim"
        log_success "Neovim installed via Homebrew."
    fi
}

# Function to backup and replace a configuration file or directory
backup_and_replace() {
    local src=$1
    local dest=$2

    if [ -L "$dest" ]; then
        # If it's already a symlink to the source, do nothing
        if [ "$(readlink "$dest")" = "$src" ]; then
            log "Symlink for $(basename "$dest") already exists and points to the correct source."
            return
        else
            log "Symlink for $(basename "$dest") points to a different source. Updating symlink..."
            execute "ln -sfn \"$src\" \"$dest\""
            log_success "Symlink for $(basename "$dest") updated."
        fi
    elif [ -e "$dest" ]; then
        # If the destination exists and is not a symlink, backup and replace
        log "Backing up existing $(basename "$dest") to $BACKUP_DIR..."
        execute "mkdir -p \"$(dirname \"$BACKUP_DIR/$dest\")\""
        execute "mv \"$dest\" \"$BACKUP_DIR/\""
        log_success "Existing $(basename "$dest") backed up."

        log "Creating symlink for $(basename "$dest")..."
        execute "ln -s \"$src\" \"$dest\""
        log_success "Symlink for $(basename "$dest") created."
    else
        # If the destination does not exist, create symlink
        log "Creating symlink for $(basename "$dest")..."
        execute "ln -s \"$src\" \"$dest\""
        log_success "Symlink for $(basename "$dest") created."
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        log "Installing Oh My Zsh..."
        execute "RUNZSH=no KEEP_ZSHRC=yes sh -c \"\$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
        log_success "Oh My Zsh installed."
    else
        log "Oh My Zsh is already installed."
    fi
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    if [ ! -d "$POWERLEVEL10K_DIR" ]; then
        log "Installing Powerlevel10k theme..."
        execute "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$POWERLEVEL10K_DIR\""
        log_success "Powerlevel10k installed."
    else
        log "Powerlevel10k is already installed."
    fi
}

# Function to install Zoxide
install_zoxide() {
    if ! command_exists zoxide; then
        log "Installing Zoxide..."
        if [ "$OS" = "macos" ] && command_exists brew; then
            execute "brew install zoxide"
            log_success "Zoxide installed via Homebrew."
        elif [ "$OS" = "linux" ]; then
            execute "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
            log_success "Zoxide installed via curl on Linux."
        elif command_exists cargo; then
            execute "cargo install zoxide"
            log_success "Zoxide installed via Cargo."
        else
            log_error "Zoxide installation method not found. Please install it manually."
            exit 1
        fi
    else
        log "Zoxide is already installed."
    fi
}

# Function to initialize Git submodules
initialize_git_submodules() {
    log "Initializing Git submodules..."
    execute "git submodule update --init --recursive"
    log_success "Git submodules initialized."
}

# Function to set Zsh as the default shell
set_zsh_as_default() {
    CURRENT_SHELL="$(basename "$SHELL")"
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        log "Changing default shell to Zsh..."
        # Ensure Zsh is in /etc/shells
        if ! grep -Fxq "$(which zsh)" /etc/shells; then
            log "Adding $(which zsh) to /etc/shells..."
            execute "echo \"$(which zsh)\" | sudo tee -a /etc/shells"
            log_success "Zsh added to /etc/shells."
        fi
        execute "chsh -s \"$(which zsh)\""
        log_success "Default shell changed to Zsh. Please log out and log back in to apply the change."
    else
        log "Zsh is already the default shell."
    fi
}

# Function to reload tmux configuration
reload_tmux() {
    if command_exists tmux; then
        if tmux ls &>/dev/null; then
            log "Reloading tmux configuration..."
            execute "tmux source-file \"$SOURCE_DIR/tmux.conf\""
            log_success "Tmux configuration reloaded."
        else
            log "No active tmux sessions found. Skipping tmux reload."
        fi
    else
        log "Tmux is not installed. Skipping tmux reload."
    fi
}

# Function to ensure PATH modifications are idempotent
ensure_path() {
    local path_entry=$1
    local shell_config=$2

    if ! grep -Fxq "export PATH=\"\$PATH:$path_entry\"" "$shell_config" 2>/dev/null; then
        log "Adding $path_entry to PATH in $shell_config..."
        execute "echo 'export PATH=\"\$PATH:$path_entry\"' >> \"$shell_config\""
        log_success "$path_entry added to PATH in $shell_config."
    else
        log "$path_entry is already in PATH in $shell_config."
    fi
}

# ================================
# Main Installation Process
# ================================

main() {
    log "Starting dotfiles installation..."

    # Detect Operating System
    detect_os

    # Install required packages
    install_packages

    # Install Neovim based on OS
    install_neovim

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
    if [ "$DRY_RUN" = false ]; then
        if [ ! -d "$BACKUP_DIR" ]; then
            log "Creating backup directory at $BACKUP_DIR..."
            execute "mkdir -p \"$BACKUP_DIR\""
            log_success "Backup directory created."
        else
            log "Backup directory already exists at $BACKUP_DIR."
        fi
    else
        log "[DRY-RUN] Would create backup directory at $BACKUP_DIR."
    fi

    # Backup and replace configurations
    log "Backing up and setting up configurations..."

    # Backup and replace .zshrc
    if [ -f "$SOURCE_DIR/.zshrc" ]; then
        backup_and_replace "$SOURCE_DIR/.zshrc" "$HOME/.zshrc"
    else
        log_warning ".zshrc not found in source directory. Skipping."
    fi

    # Backup and replace tmux.conf if it exists in the repository
    if [ -f "$SOURCE_DIR/tmux.conf" ]; then
        backup_and_replace "$SOURCE_DIR/tmux.conf" "$HOME/.tmux.conf"
    else
        log_warning "tmux.conf not found in source directory. Skipping."
    fi

    # Backup and replace Neovim configurations if they exist in the repository
    if [ -d "$SOURCE_DIR/nvim" ]; then
        backup_and_replace "$SOURCE_DIR/nvim" "$CONFIG_DIR/nvim"
    else
        log_warning "Neovim configuration directory not found in source. Skipping."
    fi

    # Reload tmux configuration if applicable
    reload_tmux

    # Source the new Zsh configuration if the script is run in Zsh
    if [ "$SHELL" = "$(which zsh)" ]; then
        log "Sourcing Zsh configuration..."
        execute "source \"$HOME/.zshrc\""
        log_success "Zsh configuration sourced."
    else
        log "Current shell is not Zsh. Skipping sourcing of .zshrc."
    fi

    log_success "Configuration backup and setup complete."
    log "Backups are stored in $BACKUP_DIR."
    log "New configurations have been placed in your home directory and $CONFIG_DIR."
    log "Please restart your terminal or log out and log back in to apply all changes."
}

# Execute argument parsing
parse_args "$@"

# Execute main function
main

# ================================
# End of Script
# ================================

