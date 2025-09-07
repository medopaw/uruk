#!/usr/bin/env bash

set -euo pipefail

# Global variable for editor
editor=""

# Function to select an editor
select_editor() {
    local editors=()
    
    # Check for available editors
    if command -v nano >/dev/null 2>&1; then
        editors+=("nano")
    fi
    
    if command -v vi >/dev/null 2>&1; then
        editors+=("vi")
    fi
    
    if [ ${#editors[@]} -eq 0 ]; then
        echo "Error: No editor found. Please install nano or vi, or set the EDITOR environment variable."
        exit 1
    elif [ ${#editors[@]} -eq 1 ]; then
        editor="${editors[0]}"
    else
        echo "Multiple editors available. Please select one:"
        select selected_editor in "${editors[@]}"; do
            if [ -n "$selected_editor" ]; then
                editor="$selected_editor"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
    fi
}

# Determine the editor to use
if [ $# -gt 0 ]; then
    # Use the editor specified as command line argument
    editor="$1"
elif [ -n "${EDITOR:-}" ]; then
    editor="$EDITOR"
else
    select_editor
fi

# Check if custom.conf exists, if not copy from default.conf
if [ ! -f "custom.conf" ]; then
    if [ -f "default.conf" ]; then
        echo "Creating custom.conf from default.conf..."
        cp default.conf custom.conf
        echo "custom.conf created successfully."
    else
        echo "Error: default.conf not found. Cannot create custom.conf."
        exit 1
    fi
fi

# Open custom.conf with the selected editor
echo "Opening custom.conf with $editor..."
exec "$editor" custom.conf