#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install Keka via Homebrew
log_info "Installing Keka..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install --cask keka

log_success "Keka installed"
