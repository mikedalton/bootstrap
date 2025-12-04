#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Install wget via Homebrew
log_info "Installing wget..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi

brew install wget

log_success "wget installed"
