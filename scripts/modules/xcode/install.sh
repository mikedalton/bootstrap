#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/utils.sh"

# Check if Xcode Command Line Tools are already installed
if command_exists xcode-select && [[ -d "$(xcode-select -p)" ]]; then
    log_success "Xcode Command Line Tools already installed"
    exit 0
fi

log_info "Installing Xcode Command Line Tools..."
xcode-select --install

# Wait for installation to complete
log_info "Waiting for Xcode installation to complete..."
until command_exists xcode-select && [[ -d "$(xcode-select -p)" ]]; do
    sleep 5
done

log_success "Xcode Command Line Tools installed"
