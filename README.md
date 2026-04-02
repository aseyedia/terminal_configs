# Terminal Configurations

Optimized shell and terminal configurations for Bash, Zsh, and Tmux.
**Optimized for RHEL/Enterprise Linux** - Downloads static binaries of modern CLI tools (no compilation required!).

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
- **`install.sh`** - Interactive installer with static binary downloads

## Installation Options

The installer offers three modes:
1. **Full installation** - Configs + download tools (static binaries)
2. **Configs only** - Skip tool downloads (faster)
3. **Tools only** - Download tools, skip configs

### Downloading Static Binaries

The installer downloads static musl binaries for these modern CLI tools:
- **fd** - Fast file finder (essential)
- **zoxide** - Smarter cd command (essential)
- **ripgrep** - Fast text search (essential)
- **bat** - Better cat with syntax highlighting (optional)
- **eza** - Modern ls replacement (optional)

**Why static binaries?**
- ✅ **No compilation** - Installs in seconds, not minutes
- ✅ **No Rust/build tools needed** - Just curl and tar
- ✅ **Portable** - Works across different Linux distributions
- ✅ **No dependencies** - Statically linked musl binaries

This is ideal for RHEL 9/CentOS/Enterprise Linux where:
- Homebrew isn't feasible
- DNF/YUM repos have outdated versions
- You need modern tools without admin privileges
- Building from source is too slow or complex

### Prerequisites

Minimal dependencies (usually already installed):

```bash
# Just need curl and tar (typically pre-installed)
# If missing on RHEL/CentOS:
sudo dnf install curl tar gzip
```

## Tools Overview

**Auto-installed:**
- **fzf** - Fuzzy finder (auto-installed by configs)

**Downloaded as static binaries (via installer):**
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

### Quick Server Setup

For RHEL 9/CentOS/Rocky Linux servers:

```bash
# 1. Clone the repo
git clone https://github.com/aseyedia/terminal_configs.git ~/terminal_configs
cd ~/terminal_configs

# 2. Run installer (curl and tar are typically pre-installed)
./install.sh

# 3. Choose option 1 (full installation) to download fd, zoxide, and ripgrep
# 4. Restart your shell or: source ~/.bashrc
```

Tools will be installed to `~/.local/bin` (already in PATH via the .bashrc).

**Installation time:** ~30 seconds (vs 15+ minutes building from source!)

## Customization

Machine-specific configs: `~/.zshrc.local` or `~/.bashrc.local`  
Backups saved to: `~/.config_backups/terminal_configs_YYYYMMDD_HHMMSS/`

## Credits

- [nvim-starter-kit](https://github.com/bcampolo/nvim-starter-kit) - Neovim config
- [tmux.conf guide](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/) - Ham Vocke
- [Browser-like tmux](https://www.seanh.cc/2020/12/30/how-to-make-tmux's-windows-behave-like-browser-tabs/) - Sean Hammond
- [iTerm2 beautification](https://medium.com/airfrance-klm/beautify-your-iterm2-and-prompt-40f148761a49) - Terminal styling
