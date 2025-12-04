#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install Obsidian via Homebrew
log_info "Installing Obsidian..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install obsidian

log_success "Obsidian installed"
