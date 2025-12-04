#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install fastfetch via Homebrew
log_info "Installing fastfetch..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install fastfetch

log_success "fastfetch installed"
