#!/bin/bash

# List all installed targets by checking their installation status
# Usage: ./list-installed.sh [--simple|-s]
# --simple: Output only target names, one per line (for scripts)
# Default: Show installed targets with checkmarks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 [--simple|-s]"
    echo ""
    echo "List all installed targets by checking their installation status."
    echo ""
    echo "Options:"
    echo "  --simple, -s    Output only target names, one per line (for scripts)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Default mode shows installed targets with checkmarks."
}

# Source the shared functions
if [[ ! -r "$SCRIPT_DIR/functions.sh" ]]; then
    echo "Error: functions.sh not found. Please run from the Uruk directory." >&2
    exit 1
fi

# Set variables needed by functions.sh
root_dir="$SCRIPT_DIR"
anything_installed=false
silent_if_possible=true  # We don't want installation messages during checks

source "$SCRIPT_DIR/functions.sh"

# Main function
main() {
    local simple_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --simple|-s)
                simple_mode=true
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                usage >&2
                exit 1
                ;;
        esac
    done
    
    # Get all targets
    local all_targets
    if ! all_targets=$("$SCRIPT_DIR/list-targets.sh" --simple); then
        echo "Error: Failed to get target list" >&2
        exit 1
    fi
    
    local count=0
    local first_output=true
    
    if ! $simple_mode; then
        echo "Checking installation status..."
        echo ""
        echo "Installed targets:"
        echo ""
    fi
    
    # Check each target and output immediately
    while IFS= read -r target; do
        if [[ -n "$target" ]]; then
            if is_installed "$target" >/dev/null 2>&1; then
                if $simple_mode; then
                    echo "$target"
                else
                    echo "  ✓ $target"
                fi
                ((count++))
            fi
        fi
    done <<< "$all_targets"
    
    if ! $simple_mode; then
        echo ""
        if [[ $count -eq 0 ]]; then
            echo "No targets are currently installed."
        else
            echo "Total: $count installed targets"
        fi
        echo ""
        echo "Use 'make list-installed ARGS=\"--simple\"' to get a plain list for scripts."
    fi
}

main "$@"