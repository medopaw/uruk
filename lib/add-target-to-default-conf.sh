#!/bin/bash

# Add a single target to default.conf with description
# Usage: add-target-to-default-conf.sh <target_name> <target_type>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TARGETS_DIR="$ROOT_DIR/targets"
DEFAULT_CONF="$ROOT_DIR/default.conf"

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <target_name> <target_type>"
    echo "target_type: brewtarget, casktarget, mastarget, cargotarget, misetarget, custom"
    exit 1
fi

TARGET_NAME="$1"
TARGET_TYPE="$2"

# Function to get description for a target
get_target_description() {
    local name="$1"
    local type="$2"
    local description=""
    
    case "$type" in
        brewtarget)
            if command -v brew >/dev/null 2>&1; then
                description=$(brew desc "$name" 2>/dev/null | sed 's/^[^:]*: //' || echo "")
            fi
            if [[ -z "$description" ]]; then
                description="Homebrew package"
            fi
            ;;
        casktarget)
            if command -v brew >/dev/null 2>&1; then
                description=$(brew desc --cask "$name" 2>/dev/null | sed 's/^[^:]*: //' || echo "")
            fi
            if [[ -z "$description" ]]; then
                description="Homebrew cask application"
            fi
            ;;
        mastarget)
            if command -v mas >/dev/null 2>&1; then
                local mas_id_file="$TARGETS_DIR/$name.mastarget"
                if [[ -r "$mas_id_file" ]]; then
                    local mas_id=$(cat "$mas_id_file" | tr -d ' \n\r')
                    if [[ -n "$mas_id" ]]; then
                        description=$(mas info "$mas_id" 2>/dev/null | head -n1 | sed 's/ \[[^]]*\]$//' | sed "s/^[^ ]* //" || echo "")
                    fi
                fi
            fi
            if [[ -z "$description" ]]; then
                description="Mac App Store application"
            fi
            ;;
        cargotarget)
            if command -v cargo >/dev/null 2>&1; then
                description=$(cargo search "$name" 2>/dev/null | head -n1 | sed 's/^[^#]*# //' || echo "")
            fi
            if [[ -z "$description" ]]; then
                description="Rust cargo package"
            fi
            ;;
        misetarget)
            description="Mise package"
            ;;
        custom)
            description="Custom installation script"
            ;;
        *)
            description="Unknown target type"
            ;;
    esac
    
    echo "$description"
}

# Function to get category with user interaction using select
get_category() {
    local name="$1"
    local type="$2"
    
    case "$type" in
        brewtarget)
            echo "Where should '$name' ($type) be categorized?"
            local options=("Essential Tools (Homebrew)" "Development Tools (Homebrew)")
            local PS3="Select category: "
            
            select choice in "${options[@]}"; do
                case $REPLY in
                    1) 
                        echo "Essential Tools (Homebrew)"
                        break
                        ;;
                    2) 
                        echo "Development Tools (Homebrew)"
                        break
                        ;;
                    *) 
                        echo "Invalid choice, please try again."
                        ;;
                esac
            done
            ;;
        casktarget)
            echo "Applications (Homebrew Cask)"
            ;;
        mastarget)
            echo "Mac App Store Apps"
            ;;
        cargotarget)
            echo "Cargo Packages"
            ;;
        misetarget)
            echo "Mise Packages"
            ;;
        custom)
            echo "Where should '$name' ($type) be categorized?"
            local options=("Essential Tools (Custom)" "Custom Installation Scripts")
            local PS3="Select category: "
            
            select choice in "${options[@]}"; do
                case $REPLY in
                    1) 
                        echo "Essential Tools (Custom)"
                        break
                        ;;
                    2) 
                        echo "Custom Installation Scripts"
                        break
                        ;;
                    *) 
                        echo "Invalid choice, please try again."
                        ;;
                esac
            done
            ;;
        *)
            echo "Other"
            ;;
    esac
}

# Function that handles category selection and adds target in one step
get_category_and_add_target() {
    local name="$1"
    local type="$2"
    local target_line="$3"
    local category=""
    
    case "$type" in
        brewtarget)
            echo "Where should '$name' ($type) be categorized?"
            local options=("Essential Tools (Homebrew)" "Development Tools (Homebrew)")
            PS3="Select category: "
            
            select choice in "${options[@]}"; do
                case $REPLY in
                    1) 
                        category="Essential Tools (Homebrew)"
                        break
                        ;;
                    2) 
                        category="Development Tools (Homebrew)"
                        break
                        ;;
                    *) 
                        echo "Invalid choice, please try again."
                        ;;
                esac
            done
            ;;
        casktarget)
            category="Applications (Homebrew Cask)"
            ;;
        mastarget)
            category="Mac App Store Apps"
            ;;
        cargotarget)
            category="Cargo Packages"
            ;;
        misetarget)
            category="Mise Packages"
            ;;
        custom)
            echo "Where should '$name' ($type) be categorized?"
            local options=("Essential Tools (Custom)" "Custom Installation Scripts")
            PS3="Select category: "
            
            select choice in "${options[@]}"; do
                case $REPLY in
                    1) 
                        category="Essential Tools (Custom)"
                        break
                        ;;
                    2) 
                        category="Custom Installation Scripts"
                        break
                        ;;
                    *) 
                        echo "Invalid choice, please try again."
                        ;;
                esac
            done
            ;;
        *)
            category="Other"
            ;;
    esac
    
    # Now add the target to the determined category
    add_target_to_section "$category" "$target_line"
}

# Simple function to add target to appropriate section
add_target_to_section() {
    local temp_file=$(mktemp)
    local section_header="# === $1 ==="
    local target_line="$2"
    local section_found=false
    local target_added=false
    
    # Read through file and find the right section
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "$section_header" ]]; then
            section_found=true
            echo "$line" >> "$temp_file"
            
            # Copy all existing targets in this section, inserting alphabetically
            while IFS= read -r next_line || [[ -n "$next_line" ]]; do
                # If this is another section header or we hit EOF
                if [[ "$next_line" =~ ^#\ ===.*===$ ]] || [[ -z "$next_line" && -z "$line" ]]; then
                    # Add target if not yet added
                    if [[ "$target_added" == false ]]; then
                        echo "$target_line" >> "$temp_file"
                    fi
                    echo "$next_line" >> "$temp_file"
                    break
                # If this is a target line
                elif [[ "$next_line" =~ ^#\ [a-zA-Z0-9_-]+\ +#.*$ ]]; then
                    local existing_target=$(echo "$next_line" | sed 's/^# \([a-zA-Z0-9_-]*\) .*/\1/')
                    # Insert target alphabetically
                    if [[ "$target_added" == false && "$TARGET_NAME" < "$existing_target" ]]; then
                        echo "$target_line" >> "$temp_file"
                        target_added=true
                    fi
                    echo "$next_line" >> "$temp_file"
                else
                    echo "$next_line" >> "$temp_file"
                fi
            done
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$DEFAULT_CONF"
    
    # If section wasn't found, add it at the end
    if [[ "$section_found" == false ]]; then
        echo "" >> "$temp_file"
        echo "$section_header" >> "$temp_file"
        echo "$target_line" >> "$temp_file"
        echo "" >> "$temp_file"
    fi
    
    mv "$temp_file" "$DEFAULT_CONF"
}

# Main function
main() {
    # Validate target type
    case "$TARGET_TYPE" in
        brewtarget|casktarget|mastarget|cargotarget|misetarget|custom)
            ;;
        *)
            echo "Error: Invalid target type '$TARGET_TYPE'"
            echo "Valid types: brewtarget, casktarget, mastarget, cargotarget, misetarget, custom"
            exit 1
            ;;
    esac
    
    # Check if target already exists
    if grep -q "^# $TARGET_NAME " "$DEFAULT_CONF" 2>/dev/null; then
        echo "Target '$TARGET_NAME' already exists in default.conf"
        return 0
    fi
    
    # Get target info
    local description=$(get_target_description "$TARGET_NAME" "$TARGET_TYPE")
    local target_line="# $(printf "%-15s" "$TARGET_NAME") # $description"
    
    # Get category and add target in one step to avoid command substitution
    get_category_and_add_target "$TARGET_NAME" "$TARGET_TYPE" "$target_line"
    
    echo "✅ Added '$TARGET_NAME' to default.conf"
}

# Run main function
main