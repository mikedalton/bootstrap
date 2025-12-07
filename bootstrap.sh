#!/bin/bash

set -euo pipefail

# Located at repository root. Use `scripts/lib` and `scripts/modules` for resources.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/scripts/lib"
MODULES_DIR="${SCRIPT_DIR}/scripts/modules"

source "${LIB_DIR}/utils.sh"

# Dynamically build modules list from the modules directory
MODULES=()
while IFS= read -r _module; do
    MODULES+=("${_module}")
done < <(get_modules)

if [[ ${#MODULES[@]} -eq 0 ]]; then
    log_warning "No modules found in the modules directory"
fi

# Ensure `xcode` runs first and `homebrew` runs second (if present), then the rest
PRIORITY_ORDER=("xcode" "homebrew" "font")
ordered_modules=()

for pri in "${PRIORITY_ORDER[@]}"; do
    for i in "${!MODULES[@]}"; do
        if [[ "${MODULES[$i]}" == "$pri" ]]; then
            ordered_modules+=("${MODULES[$i]}")
            # remove from MODULES by unsetting; we'll rebuild remaining list later
            unset 'MODULES[$i]'
            break
        fi
    done
done

# Append any remaining modules in their original discovery order
for m in "${MODULES[@]}"; do
    # skip empty entries from unset
    [[ -z "$m" ]] && continue
    ordered_modules+=("$m")
done

# Replace MODULES with ordered_modules
MODULES=("${ordered_modules[@]}")

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
