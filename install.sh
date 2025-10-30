#!/usr/bin/env bash

# ============================================================================
# Terminal Configs Installer (Simplified)
# ============================================================================
# Simple installer: backup old configs, install new ones
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backups/terminal_configs_$(date +%Y%m%d_%H%M%S)"

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
    
    local tools=("git" "nvim" "fzf" "fd" "zoxide" "ripgrep" "bat" "eza" "tmux")
    local install_cmd=""
    
    if command -v brew &>/dev/null; then
        install_cmd="brew install"
    elif command -v apt &>/dev/null; then
        install_cmd="sudo apt install"
    fi
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${YELLOW}✗${NC} $tool (install: ${install_cmd} $tool)"
        fi
    done
    echo ""
}

install_configs() {
    echo ""
    echo -e "${BLUE}What would you like to install?${NC}"
    echo ""
    
    # Install .zshrc
    if ask_yes_no "Install .zshrc?"; then
        backup_and_install "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" ".zshrc"
    fi
    
    # Install .bashrc
    if ask_yes_no "Install .bashrc?"; then
        backup_and_install "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc" ".bashrc"
    fi
    
    # Install tmux.conf
    if ask_yes_no "Install tmux.conf?"; then
        backup_and_install "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf" "tmux.conf"
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
    echo "  • Restart your terminal"
    echo "  • Or run: source ~/.zshrc (or ~/.bashrc)"
    echo ""
    echo -e "${BLUE}Missing tools? Install with:${NC}"
    echo "  brew install fd zoxide ripgrep bat eza"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_header
    check_tools
    install_configs
    install_kickstart
    show_complete
}

main "$@"
