#!/bin/bash

# List all uninstalled targets by checking their installation status
# Usage: ./list-uninstalled.sh [--simple|-s]
# --simple: Output only target names, one per line (for scripts)
# Default: Show uninstalled targets with X marks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 [--simple|-s]"
    echo ""
    echo "List all uninstalled targets by checking their installation status."
    echo ""
    echo "Options:"
    echo "  --simple, -s    Output only target names, one per line (for scripts)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Default mode shows uninstalled targets with X marks."
}

# Source the shared functions
if [[ ! -r "$SCRIPT_DIR/lib/functions.sh" ]]; then
    echo "Error: lib/functions.sh not found. Please run from the Uruk directory." >&2
    exit 1
fi

# Set variables needed by functions.sh
root_dir="$SCRIPT_DIR"
anything_installed=false
silent_if_possible=true  # We don't want installation messages during checks

source "$SCRIPT_DIR/lib/functions.sh"

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
    
    if ! $simple_mode; then
        echo "Checking installation status..."
        echo ""
        echo "Uninstalled targets:"
        echo ""
    fi
    
    # Check each target and output immediately
    while IFS= read -r target; do
        if [[ -n "$target" ]]; then
            if ! is_installed "$target" >/dev/null 2>&1; then
                if $simple_mode; then
                    echo "$target"
                else
                    echo "  ✗ $target"
                fi
                ((count++))
            fi
        fi
    done <<< "$all_targets"
    
    if ! $simple_mode; then
        echo ""
        if [[ $count -eq 0 ]]; then
            echo "All targets are currently installed."
        else
            echo "Total: $count uninstalled targets"
        fi
        echo ""
        echo "Use 'make list-uninstalled ARGS=\"--simple\"' to get a plain list for scripts."
    fi
}

main "$@"