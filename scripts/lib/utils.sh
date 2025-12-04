#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Return a newline-separated list of module directory names that contain an install.sh
get_modules() {
    local modules_dir
    modules_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../modules" && pwd)"

    if [[ ! -d "$modules_dir" ]]; then
        return 0
    fi

    local entry
    for entry in "$modules_dir"/*; do
        if [[ -d "$entry" && -f "$entry/install.sh" ]]; then
            basename "$entry"
        fi
    done
}

# Prompt user for yes/no
prompt_yes_no() {
    local prompt="$1"
    local response
    read -p "$prompt (y/n) " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Exit with error
die() {
    log_error "$1"
    exit 1
}
