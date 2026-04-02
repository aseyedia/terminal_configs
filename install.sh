#!/usr/bin/env bash

# ============================================================================
# Terminal Configs Installer (Optimized for RHEL/Enterprise Linux)
# ============================================================================
# Simple installer: backup old configs, install new ones
# Downloads static musl binaries for modern CLI tools (no compilation needed!)
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

detect_architecture() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        armv7l) echo "armv7" ;;
        *) echo "unknown" ;;
    esac
}

ensure_dependencies() {
    echo ""
    echo -e "${BLUE}Checking dependencies...${NC}"

    local missing_deps=()

    # Check for essential tools
    command -v curl &>/dev/null || missing_deps+=("curl")
    command -v tar &>/dev/null || missing_deps+=("tar")
    command -v gzip &>/dev/null || missing_deps+=("gzip")

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
        echo ""
        echo -e "${BLUE}These are usually pre-installed. Install with your package manager if needed.${NC}"
        echo ""
        if ! ask_yes_no "Continue anyway?"; then
            echo -e "${RED}Aborting installation.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}  ✓ All dependencies present${NC}"
    fi
}

download_fd() {
    echo ""
    echo -e "${BLUE}Downloading fd...${NC}"

    local arch=$(detect_architecture)
    local version="v10.2.0"  # Update as needed
    local filename="fd-${version}-${arch}-unknown-linux-musl.tar.gz"
    local url="https://github.com/sharkdp/fd/releases/download/${version}/${filename}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if curl -fsSL "$url" -o "$filename" 2>/dev/null; then
        tar -xzf "$filename"
        mkdir -p "$INSTALL_DIR/bin"
        cp fd-*/fd "$INSTALL_DIR/bin/"
        echo -e "${GREEN}  ✓ fd installed to $INSTALL_DIR/bin/fd${NC}"
    else
        echo -e "${RED}  ✗ Failed to download fd${NC}"
        return 1
    fi
}

download_ripgrep() {
    echo ""
    echo -e "${BLUE}Downloading ripgrep...${NC}"

    local arch=$(detect_architecture)
    local version="14.1.1"  # Update as needed
    local filename="ripgrep-${version}-${arch}-unknown-linux-musl.tar.gz"
    local url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/${filename}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if curl -fsSL "$url" -o "$filename" 2>/dev/null; then
        tar -xzf "$filename"
        mkdir -p "$INSTALL_DIR/bin"
        cp ripgrep-*/rg "$INSTALL_DIR/bin/"
        echo -e "${GREEN}  ✓ ripgrep installed to $INSTALL_DIR/bin/rg${NC}"
    else
        echo -e "${RED}  ✗ Failed to download ripgrep${NC}"
        return 1
    fi
}

download_zoxide() {
    echo ""
    echo -e "${BLUE}Downloading zoxide...${NC}"

    local arch=$(detect_architecture)
    local version="v0.9.6"  # Update as needed
    local filename="zoxide-${version}-${arch}-unknown-linux-musl.tar.gz"
    local url="https://github.com/ajeetdsouza/zoxide/releases/download/${version}/${filename}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if curl -fsSL "$url" -o "$filename" 2>/dev/null; then
        tar -xzf "$filename"
        mkdir -p "$INSTALL_DIR/bin"
        cp zoxide "$INSTALL_DIR/bin/"
        echo -e "${GREEN}  ✓ zoxide installed to $INSTALL_DIR/bin/zoxide${NC}"
    else
        echo -e "${RED}  ✗ Failed to download zoxide${NC}"
        return 1
    fi
}

download_bat() {
    echo ""
    echo -e "${BLUE}Downloading bat...${NC}"

    local arch=$(detect_architecture)
    local version="v0.24.0"  # Update as needed
    local filename="bat-${version}-${arch}-unknown-linux-musl.tar.gz"
    local url="https://github.com/sharkdp/bat/releases/download/${version}/${filename}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if curl -fsSL "$url" -o "$filename" 2>/dev/null; then
        tar -xzf "$filename"
        mkdir -p "$INSTALL_DIR/bin"
        cp bat-*/bat "$INSTALL_DIR/bin/"
        echo -e "${GREEN}  ✓ bat installed to $INSTALL_DIR/bin/bat${NC}"
    else
        echo -e "${RED}  ✗ Failed to download bat${NC}"
        return 1
    fi
}

download_eza() {
    echo ""
    echo -e "${BLUE}Downloading eza...${NC}"

    local arch=$(detect_architecture)
    local version="v0.20.10"  # Update as needed
    local filename="eza_${arch}-unknown-linux-musl.tar.gz"
    local url="https://github.com/eza-community/eza/releases/download/${version}/${filename}"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if curl -fsSL "$url" -o "$filename" 2>/dev/null; then
        tar -xzf "$filename"
        mkdir -p "$INSTALL_DIR/bin"
        cp eza "$INSTALL_DIR/bin/"
        echo -e "${GREEN}  ✓ eza installed to $INSTALL_DIR/bin/eza${NC}"
    else
        echo -e "${RED}  ✗ Failed to download eza${NC}"
        return 1
    fi
}

install_via_homebrew() {
    echo ""
    echo -e "${BLUE}Installing tools via Homebrew...${NC}"

    local tools=("fd" "zoxide" "ripgrep" "bat" "eza")
    local installed_count=0

    for tool in "${tools[@]}"; do
        # Check if already installed
        if command -v "$tool" &>/dev/null || command -v "${tool/ripgrep/rg}" &>/dev/null; then
            echo -e "${YELLOW}  ⊘ $tool already installed, skipping${NC}"
            continue
        fi

        # Install via brew
        local brew_name="$tool"
        if [[ "$tool" == "ripgrep" ]]; then
            brew_name="ripgrep"
        fi

        echo -e "${BLUE}  Installing $tool...${NC}"
        if brew install "$brew_name" &>/dev/null; then
            echo -e "${GREEN}  ✓ $tool installed${NC}"
            ((installed_count++))
        else
            echo -e "${RED}  ✗ Failed to install $tool${NC}"
        fi
    done

    if [[ $installed_count -gt 0 ]]; then
        echo ""
        echo -e "${GREEN}Installed $installed_count tool(s) via Homebrew${NC}"
    fi
}

install_tools() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Tool Installation${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"

    # Check if homebrew is available
    local has_brew=false
    if command -v brew &>/dev/null; then
        has_brew=true
    fi

    echo ""
    if [[ "$has_brew" == "true" ]]; then
        echo -e "${BLUE}Installation method:${NC}"
        echo "  1. Static binaries (recommended for RHEL/servers)"
        echo "  2. Homebrew (if you prefer brew)"
        echo ""
        read -r -p "$(echo -e "${BLUE}Choose method [1/2]: ${NC}")" method_choice

        case "$method_choice" in
            2)
                install_via_homebrew
                return
                ;;
            1|*)
                # Continue with static binaries
                ;;
        esac
    else
        echo -e "${YELLOW}Homebrew not detected. Using static binaries.${NC}"
    fi

    # Essential tools for the user
    local essential_tools=("fd" "zoxide" "ripgrep")
    local optional_tools=("bat" "eza")

    echo ""
    echo -e "${BLUE}Essential tools (fd, zoxide, ripgrep)${NC}"
    if ask_yes_no "Download essential tools?"; then
        for tool in "${essential_tools[@]}"; do
            if command -v "$tool" &>/dev/null || command -v "${tool/ripgrep/rg}" &>/dev/null; then
                echo -e "${YELLOW}  ⊘ $tool already installed, skipping${NC}"
            else
                case "$tool" in
                    fd) download_fd ;;
                    zoxide) download_zoxide ;;
                    ripgrep) download_ripgrep ;;
                esac
            fi
        done
    fi

    echo ""
    echo -e "${BLUE}Optional tools (bat, eza)${NC}"
    if ask_yes_no "Download optional tools?"; then
        for tool in "${optional_tools[@]}"; do
            if command -v "$tool" &>/dev/null; then
                echo -e "${YELLOW}  ⊘ $tool already installed, skipping${NC}"
            else
                case "$tool" in
                    bat) download_bat ;;
                    eza) download_eza ;;
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
    echo "  1. Full installation (configs + tools)"
    echo "  2. Configs only (skip tool downloads)"
    echo "  3. Tools only (skip configs)"
    echo ""
    read -r -p "$(echo -e "${BLUE}Choose option [1/2/3]: ${NC}")" choice

    case "$choice" in
        1)
            ensure_dependencies
            install_tools
            install_configs
            install_kickstart
            ;;
        2)
            install_configs
            install_kickstart
            ;;
        3)
            ensure_dependencies
            install_tools
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting.${NC}"
            exit 1
            ;;
    esac

    show_complete
}

main "$@"
