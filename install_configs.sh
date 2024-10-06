#!/bin/bash

git submodule update --init --recursive

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

backup_and_replace "nvim"

tmux source tmux.conf

echo "Configuration backup and replacement complete."
echo "Backups are stored in $BACKUP_DIR"
echo "New configurations have been placed in $CONFIG_DIR"
