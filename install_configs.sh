#!/bin/bash

# Set up variables
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
SOURCE_DIR="$(pwd)"

# Function to backup and replace a configuration
backup_and_replace() {
    local app=$1
    local config_path="$CONFIG_DIR/$app"
    local backup_path="$BACKUP_DIR/$app"
    local source_path="$SOURCE_DIR/$app"

    if [ -e "$config_path" ]; then
        echo "Backing up existing $app configuration..."
        mkdir -p "$(dirname "$backup_path")"
        mv "$config_path" "$backup_path"
    fi

    if [ -e "$source_path" ]; then
        echo "Replacing $app configuration..."
        mkdir -p "$(dirname "$config_path")"
        cp -r "$source_path" "$(dirname "$config_path")"
    fi
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup and replace configurations
backup_and_replace "alacritty"
backup_and_replace "nvim"

# Handle tmux.conf specially (it's a file, not a directory)
if [ -f "$CONFIG_DIR/tmux.conf" ]; then
    echo "Backing up existing tmux.conf..."
    mv "$CONFIG_DIR/tmux.conf" "$BACKUP_DIR/tmux.conf"
fi
if [ -f "$SOURCE_DIR/tmux/tmux.conf" ]; then
    echo "Replacing tmux.conf..."
    mkdir -p "$CONFIG_DIR/tmux"
    cp "$SOURCE_DIR/tmux/tmux.conf" "$CONFIG_DIR/tmux.conf"
fi

echo "Configuration backup and replacement complete."
echo "Backups are stored in $BACKUP_DIR"
echo "New configurations have been placed in $CONFIG_DIR"
