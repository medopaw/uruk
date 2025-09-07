#!/bin/bash

set -e

TARGET_TYPES=("brewtarget" "casktarget" "mastarget" "cargotarget" "custom")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS_DIR="$SCRIPT_DIR/targets"
README_FILE="$SCRIPT_DIR/README.md"

usage() {
    echo "Usage: make add-target [name]"
    echo ""
    echo "Examples:"
    echo "  make add-target          # Interactive mode - choose type and enter name"
    echo "  make add-target vim      # Semi-interactive - choose type for 'vim'"
    echo ""
    echo "Target types:"
    echo "  brewtarget  - Homebrew package"
    echo "  casktarget  - Homebrew cask application" 
    echo "  mastarget   - Mac App Store application (requires MAS ID)"
    echo "  cargotarget - Rust cargo package"
    echo "  custom      - Custom installation script"
}

semi_interactive_mode() {
    local name="$1"
    echo "=== Add Target: $name ==="
    echo ""
    
    validate_target_name "$name"
    check_existing_target "$name"
    
    echo "Available target types:"
    for i in "${!TARGET_TYPES[@]}"; do
        case "${TARGET_TYPES[$i]}" in
            brewtarget) desc="Homebrew package" ;;
            casktarget) desc="Homebrew cask application" ;;
            mastarget) desc="Mac App Store application" ;;
            cargotarget) desc="Rust cargo package" ;;
            custom) desc="Custom installation script" ;;
        esac
        echo "  $((i+1)). ${TARGET_TYPES[$i]} - $desc"
    done
    echo ""
    
    # Get target type
    local type=""
    local PS3="Select target type: "
    
    select choice in "${TARGET_TYPES[@]}"; do
        case $REPLY in
            [1-5])
                if [[ "$REPLY" -le "${#TARGET_TYPES[@]}" ]]; then
                    type="${TARGET_TYPES[$((REPLY-1))]}"
                    break
                else
                    echo "Invalid choice, please try again."
                fi
                ;;
            *)
                echo "Invalid choice, please try again."
                ;;
        esac
    done
    
    # Get additional info if needed
    local content=""
    case "$type" in
        mastarget)
            while true; do
                echo "Enter Mac App Store ID:"
                read mas_id
                if [[ "$mas_id" =~ ^[0-9]+$ ]]; then
                    content="$mas_id"
                    break
                else
                    echo "Invalid MAS ID. Please enter a numeric ID."
                fi
            done
            ;;
    esac
    
    echo ""
    echo "Creating target: $name ($type)"
    create_target_file "$type" "$name" "$content"
    update_readme "$name"
    update_default_conf "$name" "$type"
    echo "✅ Target '$name' added successfully!"
}

validate_target_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
        echo "Error: Target name '$name' is invalid. Use only letters, numbers, hyphens, and underscores. Must start with letter or number."
        exit 1
    fi
}

check_existing_target() {
    local name="$1"
    
    # Check all possible target file formats
    for ext in brewtarget casktarget mastarget cargotarget sh; do
        if [[ -f "$TARGETS_DIR/$name.$ext" ]]; then
            echo "Error: Target '$name' already exists as $name.$ext"
            exit 1
        fi
    done
    
    # Check for directory-based targets
    if [[ -d "$TARGETS_DIR/$name" ]]; then
        echo "Error: Target directory '$name' already exists"
        exit 1
    fi
}

create_target_file() {
    local type="$1"
    local name="$2"
    local content="$3"
    
    case "$type" in
        brewtarget|casktarget|cargotarget)
            # Create empty marker file
            touch "$TARGETS_DIR/$name.$type"
            ;;
        mastarget)
            if [[ -z "$content" ]]; then
                echo "Error: MAS ID is required for mastarget"
                exit 1
            fi
            echo "$content" > "$TARGETS_DIR/$name.$type"
            ;;
        custom)
            echo '#!/bin/sh' > "$TARGETS_DIR/$name.sh"
            echo '' >> "$TARGETS_DIR/$name.sh"
            echo "# Custom installation script for $name" >> "$TARGETS_DIR/$name.sh"
            echo "# Add your installation commands here" >> "$TARGETS_DIR/$name.sh"
            chmod +x "$TARGETS_DIR/$name.sh"
            ;;
    esac
}

update_readme() {
    # Get all targets from filesystem using list-targets.sh
    local targets
    if ! targets=$("$SCRIPT_DIR/list-targets.sh" --simple); then
        echo "Error: Failed to get target list from filesystem"
        exit 1
    fi
    
    # Convert to array and ensure it's sorted
    local targets_array=()
    while IFS= read -r target; do
        if [[ -n "$target" ]]; then
            targets_array+=("$target")
        fi
    done <<< "$targets"
    
    # Use a simpler approach: split file into before/after sections
    local temp_file=$(mktemp)
    local in_targets_section=false
    local targets_written=false
    
    while IFS= read -r line; do
        if [[ "$line" == "## Supported Installation Targets" ]]; then
            # Found the section header
            echo "$line" >> "$temp_file"
            echo "" >> "$temp_file"
            
            # Write all targets with proper numbering
            for i in "${!targets_array[@]}"; do
                echo "$((i + 1)). ${targets_array[$i]}" >> "$temp_file"
            done
            echo "" >> "$temp_file"
            
            in_targets_section=true
            targets_written=true
        elif $in_targets_section; then
            # Skip lines until we find a non-numbered line
            if [[ ! "$line" =~ ^[0-9]+\.\  ]] && [[ "$line" != "" ]]; then
                # Found the end of targets section
                echo "$line" >> "$temp_file"
                in_targets_section=false
            elif [[ "$line" != "" ]] && [[ ! "$line" =~ ^[0-9]+\.\  ]]; then
                # This is the end of targets section
                echo "$line" >> "$temp_file"
                in_targets_section=false
            fi
            # Skip numbered lines and empty lines in targets section
        else
            # Normal line outside targets section
            echo "$line" >> "$temp_file"
        fi
    done < "$README_FILE"
    
    mv "$temp_file" "$README_FILE"
}

interactive_mode() {
    echo "=== Add New Target ==="
    echo ""
    echo "Available target types:"
    for i in "${!TARGET_TYPES[@]}"; do
        case "${TARGET_TYPES[$i]}" in
            brewtarget) desc="Homebrew package" ;;
            casktarget) desc="Homebrew cask application" ;;
            mastarget) desc="Mac App Store application" ;;
            cargotarget) desc="Rust cargo package" ;;
            custom) desc="Custom installation script" ;;
        esac
        echo "  $((i+1)). ${TARGET_TYPES[$i]} - $desc"
    done
    echo ""
    
    # Get target type
    local PS3="Select target type: "
    
    select choice in "${TARGET_TYPES[@]}"; do
        case $REPLY in
            [1-5])
                if [[ "$REPLY" -le "${#TARGET_TYPES[@]}" ]]; then
                    type="${TARGET_TYPES[$((REPLY-1))]}"
                    break
                else
                    echo "Invalid choice, please try again."
                fi
                ;;
            *)
                echo "Invalid choice, please try again."
                ;;
        esac
    done
    
    # Get target name
    while true; do
        echo "Enter target name:"
        read name
        if [[ -n "$name" ]]; then
            validate_target_name "$name"
            check_existing_target "$name"
            break
        else
            echo "Target name cannot be empty."
        fi
    done
    
    # Get additional info if needed
    content=""
    case "$type" in
        mastarget)
            while true; do
                echo "Enter Mac App Store ID:"
                read mas_id
                if [[ "$mas_id" =~ ^[0-9]+$ ]]; then
                    content="$mas_id"
                    break
                else
                    echo "Invalid MAS ID. Please enter a numeric ID."
                fi
            done
            ;;
    esac
    
    echo ""
    echo "Creating target: $name ($type)"
    create_target_file "$type" "$name" "$content"
    update_readme "$name"
    update_default_conf "$name" "$type"
    echo "✅ Target '$name' added successfully!"
}

update_default_conf() {
    local target_name="$1"
    local target_type="$2"
    echo "Adding '$target_name' to default.conf..."
    if [[ -x "$SCRIPT_DIR/lib/add-target-to-default-conf.sh" ]]; then
        "$SCRIPT_DIR/lib/add-target-to-default-conf.sh" "$target_name" "$target_type"
    else
        echo "⚠️  Warning: lib/add-target-to-default-conf.sh not found or not executable"
    fi
}

main() {
    # Create targets directory if it doesn't exist
    mkdir -p "$TARGETS_DIR"
    
    if [[ $# -eq 0 ]]; then
        # No arguments - fully interactive mode
        interactive_mode
    elif [[ $# -eq 1 ]]; then
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            usage
        else
            # One argument - semi-interactive mode with target name provided
            semi_interactive_mode "$1"
        fi
    else
        echo "Error: Too many arguments. Use 'make add-target [name]'"
        echo ""
        usage
        exit 1
    fi
}

main "$@"