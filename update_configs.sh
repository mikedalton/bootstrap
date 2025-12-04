#!/bin/bash

set -euo pipefail

# Located at repository root. Use `scripts/lib` and `scripts/modules` for resources.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/scripts/lib"
MODULES_DIR="${SCRIPT_DIR}/scripts/modules"

source "${LIB_DIR}/utils.sh"

log_info "Updating repo config files from system files..."

MODULES=()
while IFS= read -r _module; do
    MODULES+=("${_module}")
done < <(get_modules)

for module in "${MODULES[@]}"; do
    module_dir="${MODULES_DIR}/${module}"
    install_sh="${module_dir}/install.sh"
    log_info "Processing module: $module"

    if [[ ! -f "$install_sh" ]]; then
        log_warning "No install.sh for module $module; skipping"
        continue
    fi

    # Try to parse CONFIG_FILES array from the install script
    config_block=$(sed -n '/^\s*CONFIG_FILES\s*=\s*(/,/)\s*/p' "$install_sh" | tr '\n' ' ')
    CONFIG_PATHS=()

    if [[ -n "$config_block" ]]; then
        # Extract the RHS including parentheses: e.g. ("$HOME/.config/foo")
        content=${config_block#*=}
        # Build a small bash snippet to evaluate the array and print entries
        cmd="CONFIG_FILES=$content; for v in \"\${CONFIG_FILES[@]}\"; do printf '%s\\n' \"\$v\"; done"
        # Execute in a clean bash to expand variables like $HOME
        CONFIG_PATHS=()
        while IFS= read -r _cfg; do
            CONFIG_PATHS+=("${_cfg}")
        done < <(bash -c "$cmd")
    else
        # Fallback to single CONFIG_FILE assignment for backward compatibility
        config_line=$(grep -m1 -E '^\s*CONFIG_FILE\s*=' "$install_sh" || true)
        if [[ -n "$config_line" ]]; then
            config_value=${config_line#*=}
            config_value="$(echo "$config_value" | sed -E 's/^\s+//; s/\s+$//')"
            eval "EXPANDED_CONFIG_FILE=$config_value"
            if [[ -n "$EXPANDED_CONFIG_FILE" ]]; then
                CONFIG_PATHS=("$EXPANDED_CONFIG_FILE")
            fi
        fi
    fi

    if [[ ${#CONFIG_PATHS[@]} -eq 0 ]]; then
        log_warning "No CONFIG_FILES or CONFIG_FILE found in $install_sh; skipping"
        continue
    fi

    for EXPANDED_CONFIG_FILE in "${CONFIG_PATHS[@]}"; do
        if [[ -f "$EXPANDED_CONFIG_FILE" ]]; then
            dest_path="$module_dir/$(basename "$EXPANDED_CONFIG_FILE")"
            mkdir -p "$(dirname "$dest_path")"
            cp -f "$EXPANDED_CONFIG_FILE" "$dest_path"
            log_success "Updated $module/$(basename "$dest_path") from $EXPANDED_CONFIG_FILE"
        else
            log_warning "System file does not exist: $EXPANDED_CONFIG_FILE; skipping"
        fi
    done
done

log_success "Repo configuration update complete"
