#!/bin/bash

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
LIB_DIR="${SCRIPT_DIR}/lib"

# Source utility functions
source "${LIB_DIR}/utils.sh"

declare -a MODULES=(
# Dynamically build modules list from the modules directory
readarray -t MODULES < <(get_modules)

if [[ ${#MODULES[@]} -eq 0 ]]; then
    log_warning "No modules found in the modules directory"
fi

main() {
    log_info "macOS Bootstrap Script"
    log_info "====================="
    
    # Check if running on macOS
    if ! is_macos; then
        die "This script is designed to run on macOS only"
    fi
    
    log_info "Starting bootstrap process..."
    echo ""
    
    # Run each module's install script
    for module in "${MODULES[@]}"; do
        local module_script="${MODULES_DIR}/${module}/install.sh"
        
        if [[ ! -f "$module_script" ]]; then
            log_warning "Module script not found: $module_script"
            continue
        fi
        
        log_info "Running module: $module"
        if bash "$module_script"; then
            log_success "Module '$module' completed successfully"
        else
            log_error "Module '$module' failed"
            if ! prompt_yes_no "Continue with next module?"; then
                die "Bootstrap aborted"
            fi
        fi
        echo ""
    done
    
    log_success "Bootstrap process completed!"
}

main "$@"
