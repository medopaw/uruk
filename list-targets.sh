#!/bin/bash

# List all available installation targets by scanning the filesystem
# Usage: ./list-targets.sh [--simple|-s]
# --simple: Output only target names, one per line (for scripts)
# Default: Show target names with types and descriptions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS_DIR="$SCRIPT_DIR/targets"

usage() {
    echo "Usage: $0 [--simple|-s]"
    echo ""
    echo "List all available installation targets by scanning the filesystem."
    echo ""
    echo "Options:"
    echo "  --simple, -s    Output only target names, one per line (for scripts)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Default mode shows target names with types and descriptions."
}

# Function to determine target type based on files present
# Returns the highest priority type for a target
get_target_type() {
    local name="$1"
    
    # Priority order based on install.sh logic:
    # 1. targets/name/install.sh (custom directory)
    # 2. targets/name.sh (custom script)
    # 3. targets/name.brewtarget
    # 4. targets/name.casktarget
    # 5. targets/name.mastarget
    # 6. targets/name.cargotarget
    # 7. targets/name.misetarget

    if [[ -r "$TARGETS_DIR/$name/install.sh" ]]; then
        echo "custom"
    elif [[ -r "$TARGETS_DIR/$name.sh" ]]; then
        echo "custom"
    elif [[ -r "$TARGETS_DIR/$name.brewtarget" ]]; then
        echo "brewtarget"
    elif [[ -r "$TARGETS_DIR/$name.casktarget" ]]; then
        echo "casktarget"
    elif [[ -r "$TARGETS_DIR/$name.mastarget" ]]; then
        echo "mastarget"
    elif [[ -r "$TARGETS_DIR/$name.cargotarget" ]]; then
        echo "cargotarget"
    elif [[ -r "$TARGETS_DIR/$name.misetarget" ]]; then
        echo "misetarget"
    else
        echo "unknown"
    fi
}

# Function to get type description
get_type_description() {
    local type="$1"
    case "$type" in
        brewtarget) echo "Homebrew package" ;;
        casktarget) echo "Homebrew cask application" ;;
        mastarget) echo "Mac App Store application" ;;
        cargotarget) echo "Rust cargo package" ;;
        misetarget) echo "Mise package" ;;
        custom) echo "Custom installation script" ;;
        *) echo "Unknown type" ;;
    esac
}

# Scan filesystem for all targets
scan_targets() {
    local targets=()
    local seen_targets=()
    
    # Check if targets directory exists
    if [[ ! -d "$TARGETS_DIR" ]]; then
        echo "Error: Targets directory not found: $TARGETS_DIR" >&2
        exit 1
    fi
    
    # Scan directory-based targets (targets/name/install.sh)
    for install_script in "$TARGETS_DIR"/*/install.sh; do
        if [[ -r "$install_script" ]]; then
            local target_name=$(basename "$(dirname "$install_script")")
            targets+=("$target_name")
        fi
    done
    
    # Scan file-based targets
    for target_file in "$TARGETS_DIR"/*.{brewtarget,casktarget,mastarget,cargotarget,misetarget,sh}; do
        if [[ -r "$target_file" ]]; then
            local filename=$(basename "$target_file")
            local target_name="${filename%.*}"  # Remove extension
            targets+=("$target_name")
        fi
    done
    
    # Remove duplicates and sort
    printf '%s\n' "${targets[@]}" | sort -u
}

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
    
    if $simple_mode; then
        # Simple mode: just output target names
        scan_targets
    else
        # Detailed mode: show targets with types and descriptions
        echo "Available installation targets:"
        echo ""
        
        local count=0
        while IFS= read -r target; do
            if [[ -n "$target" ]]; then
                local type=$(get_target_type "$target")
                local description=$(get_type_description "$type")
                printf "  %-25s (%s)\n" "$target" "$description"
                ((count++))
            fi
        done < <(scan_targets)
        
        echo ""
        echo "Total: $count targets"
        echo ""
        echo "Use 'make list-targets ARGS=\"--simple\"' to get a plain list for scripts."
    fi
}

main "$@"