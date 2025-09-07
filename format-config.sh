#!/bin/bash

# Format config functionality: replace custom.conf with default.conf and uncomment original targets
# Usage: format-config.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_CONF="$SCRIPT_DIR/custom.conf"
DEFAULT_CONF="$SCRIPT_DIR/default.conf"

# Function to extract target names from custom.conf
extract_targets_from_custom() {
    if [[ ! -f "$CUSTOM_CONF" ]]; then
        echo "Error: custom.conf not found"
        exit 1
    fi
    
    # Extract target names (only uncommented ones)
    # Skip empty lines, section headers (# === ... ===), and commented lines
    # Match both formats: "target" and "target # description"
    grep -E "^[[:space:]]*[a-zA-Z0-9_-]+([[:space:]].*)?$" "$CUSTOM_CONF" | \
        sed 's/[[:space:]]*#.*//' | \
        sed 's/^[[:space:]]*//' | \
        sed 's/[[:space:]]*$//'
}

# Function to validate targets against default.conf
validate_targets() {
    local targets=("$@")
    local invalid_targets=()
    
    for target in "${targets[@]}"; do
        if ! grep -q "^# $target " "$DEFAULT_CONF"; then
            invalid_targets+=("$target")
        fi
    done
    
    if [[ ${#invalid_targets[@]} -gt 0 ]]; then
        echo "Error: The following targets are not recognized:"
        printf '  %s\n' "${invalid_targets[@]}"
        echo ""
        echo "Available targets can be found in default.conf"
        return 1
    fi
    
    return 0
}

# Function to replace custom.conf with default.conf and uncomment specified targets
format_config() {
    local targets=("$@")
    
    # Create a backup of custom.conf
    cp "$CUSTOM_CONF" "${CUSTOM_CONF%.conf}.backup.conf"
    
    # Copy default.conf to custom.conf
    cp "$DEFAULT_CONF" "$CUSTOM_CONF"
    
    # Uncomment the specified targets
    for target in "${targets[@]}"; do
        # Use sed to uncomment the specific target line, handling variable spacing
        sed -i.tmp "s/^# \($target\)[[:space:]]*# /\1 # /" "$CUSTOM_CONF"
    done
    
    # Clean up temporary file
    rm -f "$CUSTOM_CONF.tmp"
    
    echo "✅ Successfully formatted custom.conf"
    echo "   Backup saved as custom.backup.conf"
}

# Main function
main() {
    echo "🔧 Formatting custom.conf..."
    
    # Extract targets from custom.conf
    targets=()
    while IFS= read -r target; do
        [[ -n "$target" ]] && targets+=("$target")
    done < <(extract_targets_from_custom)
    
    if [[ ${#targets[@]} -eq 0 ]]; then
        echo "No targets found in custom.conf"
        return 0
    fi
    
    echo "Found ${#targets[@]} targets in custom.conf:"
    printf '  - %s\n' "${targets[@]}"
    echo ""
    
    # Validate targets against default.conf
    echo "🔍 Validating targets..."
    if ! validate_targets "${targets[@]}"; then
        echo "❌ Validation failed. No files were modified."
        exit 1
    fi
    
    echo "✅ All targets are valid"
    echo ""
    
    # Format the configuration
    format_config "${targets[@]}"
}

# Run main function
main "$@"
