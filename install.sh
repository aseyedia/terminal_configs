#!/usr/bin/env bash

# ============================================================================
# Terminal Configs Installer
# ============================================================================
# This script installs .zshrc, .bashrc, and tmux.conf configurations
# with backup and safety checks.
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECKMARK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${BLUE}→${NC}"
WARN="${YELLOW}⚠${NC}"
DRYRUN="${YELLOW}[DRY RUN]${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backups/terminal_configs_$(date +%Y%m%d_%H%M%S)"

# Dry run mode flag
DRY_RUN=false

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  Terminal Configuration Installer${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${CHECKMARK} $1"
}

print_error() {
    echo -e "${CROSS} $1"
}

print_warning() {
    echo -e "${WARN} $1"
}

print_info() {
    echo -e "${ARROW} $1"
}

print_dryrun() {
    echo -e "${DRYRUN} $1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    while true; do
        read -r -p "$(echo -e "${BLUE}?${NC} $prompt")" response
        response=${response:-$default}
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                echo -e "${YELLOW}Please answer yes or no.${NC}"
                ;;
        esac
    done
}

create_backup() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if $DRY_RUN; then
            print_dryrun "Would backup $(basename "$file") to $BACKUP_DIR"
        else
            mkdir -p "$BACKUP_DIR"
            cp "$file" "$BACKUP_DIR/$(basename "$file")"
            print_success "Backed up $(basename "$file") to $BACKUP_DIR"
        fi
        return 0
    fi
    return 1
}

install_file() {
    local source_file="$1"
    local dest_file="$2"
    local file_desc="$3"
    
    print_section "Installing $file_desc"
    
    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        print_error "Source file not found: $source_file"
        return 1
    fi
    
    # Check if destination file exists
    if [[ -f "$dest_file" ]]; then
        print_warning "Existing $file_desc found at $dest_file"
        
        if ask_yes_no "Do you want to replace it?"; then
            if ask_yes_no "Create a backup first?" "y"; then
                create_backup "$dest_file"
            fi
            
            if $DRY_RUN; then
                print_dryrun "Would copy $source_file to $dest_file"
                print_dryrun "$file_desc would be installed"
            else
                cp "$source_file" "$dest_file"
                print_success "$file_desc installed successfully"
            fi
            return 0
        else
            print_info "Skipped $file_desc installation"
            return 1
        fi
    else
        # No existing file, just install
        if $DRY_RUN; then
            print_dryrun "Would copy $source_file to $dest_file"
            print_dryrun "$file_desc would be installed"
        else
            cp "$source_file" "$dest_file"
            print_success "$file_desc installed successfully"
        fi
        return 0
    fi
}

check_dependencies() {
    print_section "Checking Dependencies"
    
    local missing_deps=()
    
    # Check for git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    else
        print_success "git is installed"
    fi
    
    # Check for nvim (recommended)
    if ! command -v nvim &> /dev/null; then
        print_warning "nvim not found (recommended but not required)"
        print_info "Install with: brew install neovim"
    else
        print_success "nvim is installed"
    fi
    
    # Check for fd (optional but recommended for fzf)
    if ! command -v fd &> /dev/null; then
        print_warning "fd not found (recommended for better fzf performance)"
        print_info "Install with: brew install fd"
    else
        print_success "fd is installed"
    fi
    
    # Check for tmux (if installing tmux.conf)
    if ! command -v tmux &> /dev/null; then
        print_warning "tmux not found"
        print_info "Install with: brew install tmux"
    else
        print_success "tmux is installed"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install them before continuing"
        return 1
    fi
    
    echo ""
    return 0
}

install_shell_config() {
    print_section "Shell Configuration"
    
    local current_shell=$(basename "$SHELL")
    print_info "Your current shell is: $current_shell"
    echo ""
    
    # Determine what to install
    local install_zsh=false
    local install_bash=false
    
    if ask_yes_no "Install .zshrc (Zsh configuration)?"; then
        install_zsh=true
    fi
    
    if ask_yes_no "Install .bashrc (Bash configuration)?"; then
        install_bash=true
    fi
    
    # Install selected configurations
    if $install_zsh; then
        if install_file "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" "Zsh configuration"; then
            print_info "To apply changes, run: source ~/.zshrc"
        fi
    fi
    
    if $install_bash; then
        if install_file "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc" "Bash configuration"; then
            print_info "To apply changes, run: source ~/.bashrc"
            
            # Suggest bash_profile setup
            if [[ ! -f "$HOME/.bash_profile" ]] && [[ ! -f "$HOME/.profile" ]]; then
                echo ""
                if ask_yes_no "Create ~/.bash_profile to source .bashrc automatically?"; then
                    if $DRY_RUN; then
                        print_dryrun "Would create ~/.bash_profile"
                    else
                        cat > "$HOME/.bash_profile" << 'EOF'
# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF
                        print_success "Created ~/.bash_profile"
                    fi
                fi
            fi
        fi
    fi
    
    return 0
}

install_tmux_config() {
    print_section "Tmux Configuration"
    
    if ask_yes_no "Install tmux.conf?"; then
        install_file "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf" "Tmux configuration"
        
        # Offer to reload tmux config if tmux is running
        if pgrep -x tmux > /dev/null; then
            echo ""
            if ask_yes_no "Tmux is running. Reload configuration now?"; then
                if $DRY_RUN; then
                    print_dryrun "Would reload tmux configuration"
                else
                    tmux source-file "$HOME/.tmux.conf" 2>/dev/null && \
                        print_success "Tmux configuration reloaded" || \
                        print_warning "Could not reload tmux config (you may need to do it manually)"
                fi
            fi
        fi
    fi
    
    return 0
}

install_optional_tools() {
    print_section "Optional Tools Installation"
    
    print_info "The following tools enhance your shell experience:"
    echo ""
    echo "  • fzf      - Fuzzy finder (auto-installed by config files)"
    echo "  • fd       - Fast file finder (better than find)"
    echo "  • zoxide   - Smarter cd command"
    echo "  • ripgrep  - Fast text search"
    echo "  • bat      - Better cat with syntax highlighting"
    echo "  • eza      - Modern ls replacement"
    echo "  • neovim   - Modern vim editor"
    echo ""
    
    # Check if neovim needs installation
    if ! command -v nvim &> /dev/null; then
        echo ""
        if ask_yes_no "Neovim not found. Would you like to install it?"; then
            install_neovim
        fi
    fi
    
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew not found. Install from: https://brew.sh"
        
        # Offer manual eza installation on Linux
        if [[ "$OSTYPE" == "linux-gnu"* ]] && ! command -v eza &> /dev/null; then
            echo ""
            if ask_yes_no "Install eza manually (Linux)?"; then
                install_eza_linux
            fi
        fi
        return 0
    fi
    
    if ask_yes_no "Install recommended tools via Homebrew?"; then
        local tools=("fd" "zoxide" "ripgrep" "bat" "eza")
        
        # Add neovim to the list if not installed
        if ! command -v nvim &> /dev/null; then
            tools+=("neovim")
        fi
        
        for tool in "${tools[@]}"; do
            if command -v "$tool" &> /dev/null || [[ "$tool" == "neovim" && $(command -v nvim &> /dev/null) ]]; then
                local display_name="$tool"
                [[ "$tool" == "neovim" ]] && display_name="nvim"
                print_success "$display_name is already installed"
            else
                if $DRY_RUN; then
                    print_dryrun "Would install $tool via Homebrew"
                else
                    print_info "Installing $tool..."
                    if brew install "$tool" > /dev/null 2>&1; then
                        print_success "$tool installed"
                    else
                        print_error "Failed to install $tool"
                    fi
                fi
            fi
        done
    fi
    
    return 0
}

install_neovim() {
    print_section "Installing Neovim"
    
    if $DRY_RUN; then
        print_dryrun "Would install Neovim"
        return 0
    fi
    
    if command -v brew &> /dev/null; then
        print_info "Installing via Homebrew..."
        if brew install neovim > /dev/null 2>&1; then
            print_success "Neovim installed via Homebrew"
            return 0
        else
            print_error "Failed to install via Homebrew"
        fi
    fi
    
    # Detect OS and install manually
    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_neovim_macos
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install_neovim_linux
    else
        print_error "Unsupported OS for automatic Neovim installation"
        print_info "Please install manually from: https://github.com/neovim/neovim/releases"
        return 1
    fi
}

install_neovim_macos() {
    print_info "Installing Neovim for macOS..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1
    
    # Detect architecture
    local arch=$(uname -m)
    local nvim_url
    local nvim_dir
    
    if [[ "$arch" == "arm64" ]]; then
        nvim_url="https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz"
        nvim_dir="nvim-macos-arm64"
    else
        nvim_url="https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-x86_64.tar.gz"
        nvim_dir="nvim-macos-x86_64"
    fi
    
    if curl -LO "$nvim_url" && tar xzf "$nvim_dir.tar.gz"; then
        sudo mkdir -p /opt
        sudo rm -rf "/opt/$nvim_dir"
        sudo mv "$nvim_dir" /opt/
        
        print_success "Neovim installed to /opt/$nvim_dir"
        print_info "PATH is automatically configured in shell configs"
        print_info "Restart your shell or run: export PATH=\"\$PATH:/opt/$nvim_dir/bin\""
    else
        print_error "Failed to download or extract Neovim"
        cd - > /dev/null || return 1
        rm -rf "$temp_dir"
        return 1
    fi
    
    cd - > /dev/null || return 1
    rm -rf "$temp_dir"
}

install_neovim_linux() {
    print_info "Installing Neovim for Linux..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1
    
    if curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; then
        sudo rm -rf /opt/nvim-linux-x86_64
        if sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; then
            print_success "Neovim installed to /opt/nvim-linux-x86_64"
            print_info "PATH is automatically configured in shell configs"
            print_info "Restart your shell or run: export PATH=\"\$PATH:/opt/nvim-linux-x86_64/bin\""
        else
            print_error "Failed to extract Neovim"
            cd - > /dev/null || return 1
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_error "Failed to download Neovim"
        cd - > /dev/null || return 1
        rm -rf "$temp_dir"
        return 1
    fi
    
    cd - > /dev/null || return 1
    rm -rf "$temp_dir"
}

install_eza_linux() {
    print_info "Installing eza for Linux..."
    
    if $DRY_RUN; then
        print_dryrun "Would download eza from GitHub releases"
        print_dryrun "Would install eza to /usr/local/bin/eza"
        return 0
    fi
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1
    
    if wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz; then
        if sudo chmod +x eza && sudo chown root:root eza && sudo mv eza /usr/local/bin/eza; then
            print_success "eza installed successfully"
        else
            print_error "Failed to install eza (permission issue)"
        fi
    else
        print_error "Failed to download eza"
    fi
    
    cd - > /dev/null || return 1
    rm -rf "$temp_dir"
}

install_nvim_kickstart() {
    print_section "Neovim Kickstart Configuration"
    
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim is not installed. Skipping kickstart configuration."
        return 1
    fi
    
    local nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    
    if [[ -d "$nvim_config_dir" ]]; then
        print_warning "Neovim configuration already exists at $nvim_config_dir"
        
        if ask_yes_no "Install kickstart.nvim configuration?"; then
            if ask_yes_no "Backup existing configuration?" "y"; then
                local backup_path="$nvim_config_dir.backup.$(date +%Y%m%d_%H%M%S)"
                if $DRY_RUN; then
                    print_dryrun "Would backup $nvim_config_dir to $backup_path"
                else
                    mv "$nvim_config_dir" "$backup_path"
                    print_success "Backed up to $backup_path"
                fi
            else
                if $DRY_RUN; then
                    print_dryrun "Would remove $nvim_config_dir"
                else
                    rm -rf "$nvim_config_dir"
                fi
            fi
        else
            print_info "Skipped kickstart.nvim installation"
            return 1
        fi
    fi
    
    if ask_yes_no "Install kickstart.nvim configuration?" "y"; then
        if $DRY_RUN; then
            print_dryrun "Would clone kickstart.nvim to $nvim_config_dir"
        else
            if git clone https://github.com/aseyedia/kickstart.nvim.git "$nvim_config_dir"; then
                print_success "Kickstart.nvim installed successfully"
                print_info "Run 'nvim' to complete the setup"
            else
                print_error "Failed to clone kickstart.nvim"
                return 1
            fi
        fi
    fi
    
    return 0
}

show_post_install() {
    print_section "Installation Complete!"
    
    echo ""
    print_success "Your terminal configurations have been installed"
    echo ""
    
    if [[ -d "$BACKUP_DIR" ]]; then
        print_info "Backups saved to: $BACKUP_DIR"
        echo ""
    fi
    
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo "  1. Restart your terminal or source your config:"
    echo "     ${GREEN}source ~/.zshrc${NC}  (for Zsh)"
    echo "     ${GREEN}source ~/.bashrc${NC}  (for Bash)"
    echo ""
    echo "  2. FZF will auto-install on first shell startup if not present"
    echo ""
    echo "  3. For best experience, install recommended tools:"
    echo "     ${GREEN}brew install fd zoxide ripgrep bat eza${NC}"
    echo ""
    echo "  4. If using Zsh, zplug will prompt to install plugins on first run"
    echo ""
    echo "  5. Consider installing Oh My Zsh if not already installed:"
    echo "     ${GREEN}sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"${NC}"
    echo ""
    
    print_info "For tmux changes, either restart tmux or run: tmux source-file ~/.tmux.conf"
    echo ""
    
    echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Enjoy your new terminal setup! 🚀${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════${NC}"
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -n, --dry-run       Show what would be done without making changes
    -y, --yes           Answer yes to all prompts (use with caution)
    --skip-deps         Skip dependency checks
    --backup-only       Create backups without installing
    --zsh-only          Install only .zshrc
    --bash-only         Install only .bashrc
    --tmux-only         Install only tmux.conf

Examples:
    $0                  Interactive installation (recommended)
    $0 --dry-run        Preview what would be installed
    $0 --zsh-only       Install only Zsh configuration
    $0 -y               Install everything without prompts

EOF
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    local auto_yes=false
    local skip_deps=false
    local backup_only=false
    local zsh_only=false
    local bash_only=false
    local tmux_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -y|--yes)
                auto_yes=true
                shift
                ;;
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --backup-only)
                backup_only=true
                shift
                ;;
            --zsh-only)
                zsh_only=true
                shift
                ;;
            --bash-only)
                bash_only=true
                shift
                ;;
            --tmux-only)
                tmux_only=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Show header
    print_header
    
    # Show dry run notice
    if $DRY_RUN; then
        echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}  DRY RUN MODE - No changes will be made to your system${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
        echo ""
    fi
    
    # Backup only mode
    if $backup_only; then
        print_section "Backup Mode"
        if $DRY_RUN; then
            print_dryrun "Would create backup directory: $BACKUP_DIR"
            for file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.tmux.conf"; do
                if [[ -f "$file" ]]; then
                    print_dryrun "Would backup $(basename "$file")"
                fi
            done
        else
            mkdir -p "$BACKUP_DIR"
            for file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.tmux.conf"; do
                if [[ -f "$file" ]]; then
                    cp "$file" "$BACKUP_DIR/$(basename "$file")"
                    print_success "Backed up $(basename "$file")"
                fi
            done
            print_info "Backups saved to: $BACKUP_DIR"
        fi
        exit 0
    fi
    
    # Check dependencies
    if ! $skip_deps; then
        check_dependencies || exit 1
    fi
    
    # Install based on mode
    if $zsh_only; then
        install_file "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" "Zsh configuration"
    elif $bash_only; then
        install_file "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc" "Bash configuration"
    elif $tmux_only; then
        install_file "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf" "Tmux configuration"
    else
        # Interactive mode - install everything user selects
        install_shell_config
        echo ""
        install_tmux_config
        echo ""
        install_optional_tools
        echo ""
        install_nvim_kickstart
    fi
    
    # Show completion message
    echo ""
    if $DRY_RUN; then
        echo ""
        echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}  DRY RUN COMPLETE${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
        echo ""
        print_info "No changes were made to your system"
        print_info "Run without --dry-run to actually install"
        echo ""
    else
        show_post_install
    fi
}

# Run main function
main "$@"
