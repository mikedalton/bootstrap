#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Check if Homebrew is already installed
if command_exists brew; then
    log_success "Homebrew already installed"
    brew update
    exit 0
fi

log_info "Installing Homebrew..."

# Download and run Homebrew installer
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH if needed (for Apple Silicon)
if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

log_success "Homebrew installed"
