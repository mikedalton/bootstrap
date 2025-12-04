#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install Rectangle via Homebrew
log_info "Installing Rectangle..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install rectangle

log_success "Rectangle installed"
