#!/usr/bin/env bash

# ============================================================================
# Terminal Configs Installer (Optimized for RHEL/Enterprise Linux)
# ============================================================================
# Simple installer: backup old configs, install new ones
# Supports building modern CLI tools from source (fd, zoxide, ripgrep)
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backups/terminal_configs_$(date +%Y%m%d_%H%M%S)"
INSTALL_DIR="$HOME/.local"
BUILD_DIR="/tmp/terminal_tools_build_$$"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}  Terminal Configuration Installer${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo ""
}

ask_yes_no() {
    local prompt="$1"
    read -r -p "$(echo -e "${BLUE}$prompt [y/N]: ${NC}")" response
    [[ "$response" =~ ^[Yy]$ ]]
}

ensure_build_deps() {
    echo ""
    echo -e "${BLUE}Checking build dependencies...${NC}"

    local missing_deps=()

    # Check for essential build tools
    command -v gcc &>/dev/null || missing_deps+=("gcc")
    command -v make &>/dev/null || missing_deps+=("make")
    command -v git &>/dev/null || missing_deps+=("git")

    # Check for Rust/Cargo (needed for fd, ripgrep, bat, eza)
    if ! command -v cargo &>/dev/null; then
        missing_deps+=("cargo")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
        echo ""

        # Detect package manager
        if command -v dnf &>/dev/null; then
            echo -e "${BLUE}Install with:${NC}"
            echo "  sudo dnf groupinstall 'Development Tools'"
            echo "  sudo dnf install openssl-devel"
            if [[ " ${missing_deps[@]} " =~ " cargo " ]]; then
                echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            fi
        elif command -v yum &>/dev/null; then
            echo -e "${BLUE}Install with:${NC}"
            echo "  sudo yum groupinstall 'Development Tools'"
            echo "  sudo yum install openssl-devel"
            if [[ " ${missing_deps[@]} " =~ " cargo " ]]; then
                echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            fi
        elif command -v apt &>/dev/null; then
            echo -e "${BLUE}Install with:${NC}"
            echo "  sudo apt update && sudo apt install build-essential libssl-dev pkg-config"
            if [[ " ${missing_deps[@]} " =~ " cargo " ]]; then
                echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            fi
        fi

        echo ""
        if ask_yes_no "Continue anyway?"; then
            return 0
        else
            echo -e "${RED}Aborting installation.${NC}"
            exit 1
        fi
    fi

    echo -e "${GREEN}  ✓ All build dependencies present${NC}"
}

install_rust_if_needed() {
    if ! command -v cargo &>/dev/null; then
        echo ""
        echo -e "${YELLOW}Rust/Cargo not found. It's required to build fd, ripgrep, bat, and eza.${NC}"
        if ask_yes_no "Install Rust now?"; then
            echo -e "${BLUE}Installing Rust...${NC}"
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            echo -e "${GREEN}  ✓ Rust installed${NC}"
        else
            echo -e "${YELLOW}Skipping tools that require Rust${NC}"
            return 1
        fi
    fi
    return 0
}

build_fd() {
    echo ""
    echo -e "${BLUE}Building fd from source...${NC}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    git clone --depth 1 https://github.com/sharkdp/fd.git
    cd fd
    cargo build --release

    mkdir -p "$INSTALL_DIR/bin"
    cp target/release/fd "$INSTALL_DIR/bin/"

    echo -e "${GREEN}  ✓ fd installed to $INSTALL_DIR/bin/fd${NC}"
}

build_ripgrep() {
    echo ""
    echo -e "${BLUE}Building ripgrep from source...${NC}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    git clone --depth 1 https://github.com/BurntSushi/ripgrep.git
    cd ripgrep
    cargo build --release

    mkdir -p "$INSTALL_DIR/bin"
    cp target/release/rg "$INSTALL_DIR/bin/"

    echo -e "${GREEN}  ✓ ripgrep installed to $INSTALL_DIR/bin/rg${NC}"
}

build_zoxide() {
    echo ""
    echo -e "${BLUE}Building zoxide from source...${NC}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    git clone --depth 1 https://github.com/ajeetdsouza/zoxide.git
    cd zoxide
    cargo build --release

    mkdir -p "$INSTALL_DIR/bin"
    cp target/release/zoxide "$INSTALL_DIR/bin/"

    echo -e "${GREEN}  ✓ zoxide installed to $INSTALL_DIR/bin/zoxide${NC}"
}

build_bat() {
    echo ""
    echo -e "${BLUE}Building bat from source...${NC}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    git clone --depth 1 https://github.com/sharkdp/bat.git
    cd bat
    cargo build --release

    mkdir -p "$INSTALL_DIR/bin"
    cp target/release/bat "$INSTALL_DIR/bin/"

    echo -e "${GREEN}  ✓ bat installed to $INSTALL_DIR/bin/bat${NC}"
}

build_eza() {
    echo ""
    echo -e "${BLUE}Building eza from source...${NC}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    git clone --depth 1 https://github.com/eza-community/eza.git
    cd eza
    cargo build --release

    mkdir -p "$INSTALL_DIR/bin"
    cp target/release/eza "$INSTALL_DIR/bin/"

    echo -e "${GREEN}  ✓ eza installed to $INSTALL_DIR/bin/eza${NC}"
}

install_tools_from_source() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Tool Installation from Source${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"

    if ! install_rust_if_needed; then
        return
    fi

    # Essential tools for the user
    local essential_tools=("fd" "zoxide" "ripgrep")
    local optional_tools=("bat" "eza")

    echo ""
    echo -e "${BLUE}Essential tools (fd, zoxide, ripgrep)${NC}"
    if ask_yes_no "Build essential tools from source?"; then
        for tool in "${essential_tools[@]}"; do
            if command -v "$tool" &>/dev/null || command -v "${tool/ripgrep/rg}" &>/dev/null; then
                echo -e "${YELLOW}  ⊘ $tool already installed, skipping${NC}"
            else
                case "$tool" in
                    fd) build_fd ;;
                    zoxide) build_zoxide ;;
                    ripgrep) build_ripgrep ;;
                esac
            fi
        done
    fi

    echo ""
    echo -e "${BLUE}Optional tools (bat, eza)${NC}"
    if ask_yes_no "Build optional tools from source?"; then
        for tool in "${optional_tools[@]}"; do
            if command -v "$tool" &>/dev/null; then
                echo -e "${YELLOW}  ⊘ $tool already installed, skipping${NC}"
            else
                case "$tool" in
                    bat) build_bat ;;
                    eza) build_eza ;;
                esac
            fi
        done
    fi

    # Cleanup build directory
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
    fi

    # Ensure ~/.local/bin is in PATH message
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo ""
        echo -e "${YELLOW}Note: Add $HOME/.local/bin to your PATH${NC}"
        echo -e "${YELLOW}This will be done automatically when you install .bashrc${NC}"
    fi
}

backup_and_install() {
    local source="$1"
    local dest="$2"
    local name="$3"
    
    # Backup existing file
    if [[ -f "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$dest" "$BACKUP_DIR/$(basename "$dest")"
        echo -e "${YELLOW}  Backed up existing $name${NC}"
    fi
    
    # Install new file
    cp "$source" "$dest"
    echo -e "${GREEN}  ✓ Installed $name${NC}"
}

check_tools() {
    echo ""
    echo -e "${BLUE}Tool Status:${NC}"

    local tools=("git" "nvim" "fzf" "fd" "zoxide" "rg" "bat" "eza" "tmux")

    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${YELLOW}✗${NC} $tool"
        fi
    done
    echo ""
}

install_configs() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Configuration Files${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""

    # Install .bashrc (most important for RHEL servers)
    if ask_yes_no "Install .bashrc?"; then
        backup_and_install "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc" ".bashrc"
    fi

    # Install .zshrc (if zsh is available)
    if command -v zsh &>/dev/null; then
        if ask_yes_no "Install .zshrc?"; then
            backup_and_install "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" ".zshrc"
        fi
    fi

    # Install tmux.conf
    if command -v tmux &>/dev/null; then
        if ask_yes_no "Install tmux.conf?"; then
            backup_and_install "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf" "tmux.conf"
        fi
    fi
}

install_kickstart() {
    if ! command -v nvim &>/dev/null; then
        return
    fi

    echo ""
    if ask_yes_no "Install kickstart.nvim config?"; then
        local nvim_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

        # Backup existing config
        if [[ -d "$nvim_dir" ]]; then
            local backup="$nvim_dir.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$nvim_dir" "$backup"
            echo -e "${YELLOW}  Backed up existing nvim config to $backup${NC}"
        fi

        # Clone kickstart
        if git clone https://github.com/aseyedia/kickstart.nvim.git "$nvim_dir" &>/dev/null; then
            echo -e "${GREEN}  ✓ Installed kickstart.nvim${NC}"
        else
            echo -e "${YELLOW}  ✗ Failed to clone kickstart.nvim${NC}"
        fi
    fi
}

show_complete() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""

    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "${YELLOW}Backups: $BACKUP_DIR${NC}"
        echo ""
    fi

    echo -e "${BLUE}Next steps:${NC}"
    echo "  • Restart your terminal or run: source ~/.bashrc"
    if [[ -f "$HOME/.cargo/env" ]]; then
        echo "  • Load Rust environment: source $HOME/.cargo/env"
    fi
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_header
    check_tools

    echo ""
    echo -e "${BLUE}Installation Options:${NC}"
    echo "  1. Full installation (configs + tools from source)"
    echo "  2. Configs only (skip tool building)"
    echo "  3. Tools only (skip configs)"
    echo ""
    read -r -p "$(echo -e "${BLUE}Choose option [1/2/3]: ${NC}")" choice

    case "$choice" in
        1)
            ensure_build_deps
            install_tools_from_source
            install_configs
            install_kickstart
            ;;
        2)
            install_configs
            install_kickstart
            ;;
        3)
            ensure_build_deps
            install_tools_from_source
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting.${NC}"
            exit 1
            ;;
    esac

    show_complete
}

main "$@"
