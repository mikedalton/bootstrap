#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

PKG_NAME="keka"
PKG_TYPE="cask"

# Install via Homebrew
log_info "Installing $PKG_NAME..."
if ! command_exists brew; then
    die "Homebrew is required but not installed"
fi


if is_brew_package_installed "$PKG_NAME" "$PKG_TYPE"; then
    log_info "$PKG_NAME is already installed; skipping install"
    log_success "$PKG_NAME installed"
    exit 0
fi

brew install --cask "$PKG_NAME"

log_success "$PKG_NAME installed"
