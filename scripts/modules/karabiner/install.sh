#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install Karabiner Elements via Homebrew
log_info "Installing Karabiner Elements..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install karabiner-elements

log_success "Karabiner Elements installed"
