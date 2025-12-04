#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install karabiner-elements via Homebrew
log_info "Installing karabiner-elements..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install --cask karabiner-elements

log_success "karabiner-elements installed"
