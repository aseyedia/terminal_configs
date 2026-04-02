# Terminal Configurations

Optimized shell and terminal configurations for Bash, Zsh, and Tmux.
**Optimized for RHEL/Enterprise Linux** - Build modern CLI tools from source when package managers are outdated.

## Quick Install

```bash
git clone https://github.com/aseyedia/terminal_configs.git
cd terminal_configs
./install.sh
```

## What's Included

- **`.bashrc`** - Git-aware prompt, FZF, lazy-loaded NVM, extensive aliases
- **`.zshrc`** - Pure prompt, FZF, smart plugins, auto-completion (when zsh available)
- **`tmux.conf`** - Browser-like tabs, mouse support, custom keybindings
- **`install.sh`** - Interactive installer with tool building from source

## Installation Options

The installer offers three modes:
1. **Full installation** - Configs + build tools from source
2. **Configs only** - Skip tool building (faster)
3. **Tools only** - Build tools, skip configs

### Building Tools from Source

The installer can build these modern CLI tools from source:
- **fd** - Fast file finder (essential)
- **zoxide** - Smarter cd command (essential)
- **ripgrep** - Fast text search (essential)
- **bat** - Better cat with syntax highlighting (optional)
- **eza** - Modern ls replacement (optional)

This is ideal for RHEL 9/CentOS/Enterprise Linux where:
- Homebrew isn't feasible
- DNF/YUM repos have outdated versions
- You need modern tools without admin privileges

### Prerequisites for Building

```bash
# RHEL/CentOS/Rocky Linux
sudo dnf groupinstall 'Development Tools'
sudo dnf install openssl-devel

# Ubuntu/Debian
sudo apt update && sudo apt install build-essential libssl-dev pkg-config

# Install Rust (required for building tools)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

The installer will guide you through this and can install Rust automatically.

## Tools Overview

**Auto-installed:**
- **fzf** - Fuzzy finder (auto-installed by configs)

**Build from source (via installer):**
- **fd** - Fast file finder, respects .gitignore
- **zoxide** - Smarter cd with frecency algorithm
- **ripgrep** - Lightning fast grep alternative
- **bat** - Cat clone with syntax highlighting
- **eza** - Modern ls with git integration

**Optional (install separately):**
- **neovim** - Modern vim
- **tmux** - Terminal multiplexer

## Features

**Bash/Zsh** - Lazy-loaded NVM, smart history, git prompts, auto-correction
**FZF** - Auto-install, respects `.gitignore`, custom keybindings, bat previews
**Tmux** - Ctrl+T (new window), Ctrl+PgUp/PgDn (navigate), Alt+1-9 (jump to window)

## Server-Friendly

This configuration is optimized for enterprise Linux servers:
- Works great with bash only (no zsh required)
- Tools install to `~/.local/bin` (no sudo needed)
- Minimal dependencies, fast startup
- SELinux compatible

## Customization

Machine-specific configs: `~/.zshrc.local` or `~/.bashrc.local`  
Backups saved to: `~/.config_backups/terminal_configs_YYYYMMDD_HHMMSS/`

## Credits

- [nvim-starter-kit](https://github.com/bcampolo/nvim-starter-kit) - Neovim config
- [tmux.conf guide](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/) - Ham Vocke
- [Browser-like tmux](https://www.seanh.cc/2020/12/30/how-to-make-tmux's-windows-behave-like-browser-tabs/) - Sean Hammond
- [iTerm2 beautification](https://medium.com/airfrance-klm/beautify-your-iterm2-and-prompt-40f148761a49) - Terminal styling
