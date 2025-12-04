#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

MODULE_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Install Ghostty via Homebrew
log_info "Installing Ghostty..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install ghostty


# Standardized config variable: system destinations for the module's config files
# Repo files expected at: ${MODULE_DIR}/<basename>
CONFIG_FILES=(
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
)

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

log_success "Ghostty installed"
