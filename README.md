# Terminal Configurations

Optimized shell and terminal configurations for Zsh, Bash, and Tmux.

## Quick Install

```bash
git clone https://github.com/aseyedia/terminal_configs.git
cd terminal_configs
./install.sh
```

Preview changes first: `./install.sh --dry-run`

## What's Included

- **`.zshrc`** - Pure prompt, FZF, smart plugins, auto-completion
- **`.bashrc`** - Git-aware prompt, FZF, lazy-loaded NVM, extensive aliases
- **`tmux.conf`** - Browser-like tabs, mouse support, custom keybindings
- **`install.sh`** - Interactive installer with backups and dry-run mode

## Installation Options

```bash
./install.sh              # Interactive mode
./install.sh --dry-run    # Preview changes
./install.sh --zsh-only   # Install only .zshrc
./install.sh --bash-only  # Install only .bashrc
./install.sh --tmux-only  # Install only tmux.conf
./install.sh --help       # All options
```

## Recommended Tools

```bash
brew install fd zoxide ripgrep bat eza neovim
```

- **fzf** - Fuzzy finder (auto-installed)
- **fd** - Fast file finder
- **zoxide** - Smarter cd
- **ripgrep** - Fast text search
- **bat** - Better cat
- **eza** - Modern ls
- **neovim** - Modern vim

## Features

**FZF** - Auto-install, respects `.gitignore`, custom keybindings  
**Shell** - Lazy-loaded NVM, smart history, git prompts, auto-correction  
**Tmux** - Ctrl+T (new window), Ctrl+PgUp/PgDn (navigate), Alt+1-9 (jump to window)

## Customization

Machine-specific configs: `~/.zshrc.local` or `~/.bashrc.local`  
Backups saved to: `~/.config_backups/terminal_configs_YYYYMMDD_HHMMSS/`

## Credits

- [nvim-starter-kit](https://github.com/bcampolo/nvim-starter-kit) - Neovim config
- [tmux.conf guide](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/) - Ham Vocke
- [Browser-like tmux](https://www.seanh.cc/2020/12/30/how-to-make-tmux's-windows-behave-like-browser-tabs/) - Sean Hammond
- [iTerm2 beautification](https://medium.com/airfrance-klm/beautify-your-iterm2-and-prompt-40f148761a49) - Terminal styling
