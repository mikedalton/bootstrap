#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

MODULE_DIR="$(dirname "${BASH_SOURCE[0]}")"

CONFIG_FILES=(
    "$HOME/.zsh_plugins.txt"
)

# Package metadata
PKG_NAME="antidote"
PKG_TYPE="formula"

log_info "Installing $PKG_NAME..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

# Check if already installed
if is_brew_package_installed "$PKG_NAME" "$PKG_TYPE"; then
    log_info "$PKG_NAME is already installed"
    if [[ ${#CONFIG_FILES[@]} -gt 0 ]]; then
        if prompt_yes_no "Copy config files from repo to system for $PKG_NAME?"; then
            for cfg in "${CONFIG_FILES[@]}"; do
                repo_file="$MODULE_DIR/$(basename "$cfg")"
                if [[ -f "$repo_file" ]]; then
                    mkdir -p "$(dirname "$cfg")"
                    log_info "Copying $(basename "$repo_file") to $cfg"
                    cp "$repo_file" "$cfg"
                    log_success "Copied $(basename "$repo_file") to $cfg"
                else
                    log_warning "No $(basename "$repo_file") found in module directory. Skipping copy."
                fi
            done
        else
            log_info "Skipping config copy for $PKG_NAME"
        fi
    fi
    log_success "$PKG_NAME is already installed"
    exit 0
fi

    # Install and copy configs
    if [[ "$PKG_TYPE" == "cask" ]]; then
        brew install --cask "$PKG_NAME"
    else
        brew install "$PKG_NAME"
    fi

for cfg in "${CONFIG_FILES[@]}"; do
    repo_file="$MODULE_DIR/$(basename "$cfg")"
    if [[ -f "$repo_file" ]]; then
        mkdir -p "$(dirname "$cfg")"
        log_info "Copying $(basename "$repo_file") to $cfg"
        cp "$repo_file" "$cfg"
        log_success "Copied $(basename "$repo_file") to $cfg"
    else
        log_warning "No $(basename "$repo_file") found in module directory. Skipping copy."
    fi
done

log_success "$PKG_NAME installed"
