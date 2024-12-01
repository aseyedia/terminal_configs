{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "pi";
  home.homeDirectory = "/home/pi";

  # This value determines the Home Manager release that your configuration is compatible with.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your environment.
  home.packages = [
    pkgs.zsh
    pkgs.tmux
    pkgs.neovim
    pkgs.zoxide
    pkgs.oh-my-zsh
    pkgs.fzf-zsh
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage plain files is through 'home.file'.
  home.file = {
    # Example:
    # ".screenrc".source = ./dotfiles/screenrc;
  };

  # Home Manager can also manage your environment variables through 'home.sessionVariables'.
  home.sessionVariables = {
    # Example:
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Zsh Configuration
  programs.zsh = {
    enable = true;
    shell = pkgs.zsh;
    ohMyZsh = {
      enable = true;
      theme = "powerlevel10k/powerlevel10k";
      plugins = [ "git" "conda-env" "common-aliases" "fzf" "zoxide" ];
    };
    extraConfig = ''
      # Add /home/pi/.local/bin to PATH
      export PATH="$PATH:/home/pi/.local/bin"

      # Initialize Zoxide
      eval "$(zoxide init --cmd cd zsh)"

      # User configuration

      # >>> conda initialize >>>
      # !! Contents within this block are managed by 'conda init' !!
      __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
              . "/opt/miniconda3/etc/profile.d/conda.sh"
          else
              export PATH="/opt/miniconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup
      # <<< conda initialize <<<

      ## Colorize the ls output ##
      alias ls='ls --color=auto'

      ## Use a long listing format ##
      alias ll='ls -la'

      ## Show hidden files ##
      alias l.='ls -d .* --color=auto'

      alias mkdir='mkdir -pv'

      export CLICOLOR=1
      export LSCOLORS="ExGxFxDxBxEgEdxbxgxhxd"
    '';
  };

  # Tmux Configuration
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Your custom tmux.conf content
      set -g base-index 1
      set -g pane-base-index 1
      bind -n C-t new-window
      bind -n C-PgDn next-window
      bind -n C-PgUp previous-window
      bind -n C-S-Left swap-window -t -1\; select-window -t -1
      bind -n C-S-Right swap-window -t +1\; select-window -t +1
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t:$
      bind -n C-M-w kill-window
      bind -n C-M-q confirm -p "Kill this tmux session?" kill-session
      bind -n F11 resize-pane -Z

      set -g status-style "bg=default"
      set -g window-status-current-style "bg=default,reverse"
      set -g window-status-separator ''

      set -g window-status-format "#{?window_start_flag,, }#I:#W#{?window_flags,#F, } "
      set -g window-status-current-format "#{?window_start_flag,, }#I:#W#{?window_flags,#F, } "

      set -g status-left ''
      set -g status-right ''
      set -g mouse on
      set-option -g allow-rename off

      # DESIGN TWEAKS
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      setw -g clock-mode-colour colour1
      setw -g mode-style 'fg=colour1 bg=colour18 bold'
      set -g pane-border-style 'fg=colour1'
      set -g pane-active-border-style 'fg=colour3'

      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'fg=colour1'
      set -g status-left ''
      set -g status-right '%Y-%m-%d %H:%M '
      set -g status-right-length 50
      set -g status-left-length 10

      setw -g window-status-current-style 'fg=colour15 bg=colour1 bold'
      setw -g window-status-current-format ' #I #W #F '

      setw -g window-status-style 'fg=colour1 dim'
      setw -g window-status-format ' #I #[fg=colour7]#W #[fg=colour1]#F '

      setw -g window-status-bell-style 'fg=colour2 bg=colour1 bold'

      set -g message-style 'fg=colour2 bg=colour0 bold'
    '';
  };

  # Neovim Configuration (to be added later)
}
