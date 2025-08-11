#!/bin/bash

set -e

REPO_URL="https://github.com/medopaw/uruk.git"
TEMP_DIR="/tmp/uruk-remote-$(date +%s)"
URUK_DIR="$TEMP_DIR/uruk"

log() {
    echo "🔄 $1"
}

error() {
    echo "❌ Error: $1" >&2
    cleanup
    exit 1
}

success() {
    echo "✅ $1"
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        log "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "This script only works on macOS"
    fi
}

check_dependencies() {
    local missing_deps=()
    
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}. Please install them first."
    fi
}

discover_targets() {
    local targets_dir="$1"
    local all_targets=()
    
    # Discover all target types with safe globbing
    shopt -s nullglob  # Enable nullglob to handle empty matches
    
    # Process each target type separately to avoid glob expansion issues
    for file in "$targets_dir"/*.brewtarget; do
        [ -f "$file" ] && all_targets+=("$(basename "$file" .brewtarget)")
    done
    
    for file in "$targets_dir"/*.casktarget; do
        [ -f "$file" ] && all_targets+=("$(basename "$file" .casktarget)")
    done
    
    for file in "$targets_dir"/*.mastarget; do
        [ -f "$file" ] && all_targets+=("$(basename "$file" .mastarget)")
    done
    
    for file in "$targets_dir"/*.cargotarget; do
        [ -f "$file" ] && all_targets+=("$(basename "$file" .cargotarget)")
    done
    
    for file in "$targets_dir"/*.sh; do
        [ -f "$file" ] && all_targets+=("$(basename "$file" .sh)")
    done
    
    for dir in "$targets_dir"/*/; do
        if [ -d "$dir" ]; then
            local dirname=$(basename "$dir")
            all_targets+=("$dirname")
        fi
    done
    
    shopt -u nullglob  # Disable nullglob
    
    # Remove duplicates and sort
    printf "%s\n" "${all_targets[@]}" | sort -u
}

get_target_type() {
    local target="$1"
    local targets_dir="$2"
    
    if [ -f "$targets_dir/$target.brewtarget" ]; then
        echo "brew"
    elif [ -f "$targets_dir/$target.casktarget" ]; then
        echo "cask"
    elif [ -f "$targets_dir/$target.mastarget" ]; then
        echo "mas"
    elif [ -f "$targets_dir/$target.cargotarget" ]; then
        echo "cargo"
    elif [ -f "$targets_dir/$target.sh" ] || [ -d "$targets_dir/$target" ]; then
        echo "script"
    else
        echo "unknown"
    fi
}

get_target_description() {
    local target="$1"
    local type="$2"
    
    case "$target" in
        git) echo "Version control system" ;;
        oh-my-zsh) echo "Zsh configuration framework" ;;
        rust) echo "Systems programming language" ;;
        python) echo "Programming language" ;;
        ruby) echo "Programming language" ;;
        node) echo "JavaScript runtime" ;;
        docker) echo "Containerization platform" ;;
        firefox) echo "Mozilla web browser" ;;
        google-chrome) echo "Google web browser" ;;
        iterm2) echo "Terminal emulator" ;;
        visual-studio-code) echo "Code editor" ;;
        gh) echo "GitHub CLI tool" ;;
        bat) echo "Cat clone with syntax highlighting" ;;
        fzf) echo "Fuzzy finder" ;;
        tldr) echo "Simplified man pages" ;;
        tig) echo "Text interface for Git" ;;
        mas) echo "Mac App Store command line interface" ;;
        brew) echo "Package manager for macOS" ;;
        jenv) echo "Java version manager" ;;
        rbenv) echo "Ruby version manager" ;;
        pyenv) echo "Python version manager" ;;
        *) 
            # Fallback: convert hyphens to spaces and capitalize words
            echo "$target" | sed 's/-/ /g; s/\b\w/\u&/g' 2>/dev/null || echo "$target"
            ;;
    esac
}

generate_config() {
    local targets_dir="$1"
    local config_file="$2"
    
    # Check if targets directory exists
    if [ ! -d "$targets_dir" ]; then
        error "Targets directory not found: $targets_dir"
    fi
    
    local all_targets
    all_targets=($(discover_targets "$targets_dir"))
    
    if [ ${#all_targets[@]} -eq 0 ]; then
        error "No installation targets found in $targets_dir"
    fi
    
    # Categorize targets
    local brew_targets=()
    local cask_targets=()
    local mas_targets=()
    local cargo_targets=()
    local script_targets=()
    
    for target in "${all_targets[@]}"; do
        case "$(get_target_type "$target" "$targets_dir")" in
            brew) brew_targets+=("$target") ;;
            cask) cask_targets+=("$target") ;;
            mas) mas_targets+=("$target") ;;
            cargo) cargo_targets+=("$target") ;;
            script) script_targets+=("$target") ;;
        esac
    done
    
    # Generate config file header
    cat > "$config_file" << 'EOF'
# Uruk Remote Installation Configuration
# Remove the # to enable installation for each tool
# 
# Usage: Remove the # symbol at the beginning of lines for tools you want to install
# Example: Change "# git" to "git" to install git

# === Essential Tools (Required) ===
EOF
    
    # Add git only if it exists as a target
    local has_git=false
    for target in "${all_targets[@]}"; do
        if [ "$target" = "git" ]; then
            has_git=true
            break
        fi
    done
    
    if [ "$has_git" = true ]; then
        echo "git          # Version control system" >> "$config_file"
    else
        echo "# git        # Version control system (not available in this repository)" >> "$config_file"
    fi
    
    # Add oh-my-zsh only if it exists as a target
    local has_oh_my_zsh=false
    for target in "${all_targets[@]}"; do
        if [ "$target" = "oh-my-zsh" ]; then
            has_oh_my_zsh=true
            break
        fi
    done
    
    if [ "$has_oh_my_zsh" = true ]; then
        echo "oh-my-zsh    # Zsh configuration framework" >> "$config_file"
    fi
    
    echo >> "$config_file"

    # Add development tools (brew)
    if [ ${#brew_targets[@]} -gt 0 ]; then
        echo "# === Development Tools (Homebrew) ===" >> "$config_file"
        # Safe array processing - filter out git and oh-my-zsh, then sort
        local filtered_brew=()
        for target in "${brew_targets[@]}"; do
            if [ "$target" != "git" ] && [ "$target" != "oh-my-zsh" ]; then
                filtered_brew+=("$target")
            fi
        done
        
        # Sort the filtered array
        if [ ${#filtered_brew[@]} -gt 0 ]; then
            IFS=$'\n' sorted_brew=($(printf "%s\n" "${filtered_brew[@]}" | sort))
            unset IFS
            
            for target in "${sorted_brew[@]}"; do
                printf "# %-12s # %s\n" "$target" "$(get_target_description "$target" "brew")" >> "$config_file"
            done
        fi
        echo >> "$config_file"
    fi
    
    # Add applications (cask)
    if [ ${#cask_targets[@]} -gt 0 ]; then
        echo "# === Applications (Homebrew Cask) ===" >> "$config_file"
        IFS=$'\n' sorted_cask=($(printf "%s\n" "${cask_targets[@]}" | sort))
        unset IFS
        
        for target in "${sorted_cask[@]}"; do
            printf "# %-12s # %s\n" "$target" "$(get_target_description "$target" "cask")" >> "$config_file"
        done
        echo >> "$config_file"
    fi
    
    # Add Mac App Store apps
    if [ ${#mas_targets[@]} -gt 0 ]; then
        echo "# === Mac App Store Apps ===" >> "$config_file"
        IFS=$'\n' sorted_mas=($(printf "%s\n" "${mas_targets[@]}" | sort))
        unset IFS
        
        for target in "${sorted_mas[@]}"; do
            local mas_id=""
            if [ -f "$targets_dir/$target.mastarget" ]; then
                mas_id=" (MAS ID: $(tr -d '\n\r' < "$targets_dir/$target.mastarget" 2>/dev/null || echo "unknown"))"
            fi
            printf "# %-12s # %s%s\n" "$target" "$(get_target_description "$target" "mas")" "$mas_id" >> "$config_file"
        done
        echo >> "$config_file"
    fi
    
    # Add cargo packages
    if [ ${#cargo_targets[@]} -gt 0 ]; then
        echo "# === Cargo Packages ===" >> "$config_file"
        IFS=$'\n' sorted_cargo=($(printf "%s\n" "${cargo_targets[@]}" | sort))
        unset IFS
        
        for target in "${sorted_cargo[@]}"; do
            printf "# %-12s # %s\n" "$target" "$(get_target_description "$target" "cargo")" >> "$config_file"
        done
        echo >> "$config_file"
    fi
    
    # Add custom scripts
    if [ ${#script_targets[@]} -gt 0 ]; then
        echo "# === Custom Installation Scripts ===" >> "$config_file"
        # Safe array processing - filter out git and oh-my-zsh, then sort
        local filtered_script=()
        for target in "${script_targets[@]}"; do
            if [ "$target" != "git" ] && [ "$target" != "oh-my-zsh" ]; then
                filtered_script+=("$target")
            fi
        done
        
        # Sort the filtered array
        if [ ${#filtered_script[@]} -gt 0 ]; then
            IFS=$'\n' sorted_script=($(printf "%s\n" "${filtered_script[@]}" | sort))
            unset IFS
            
            for target in "${sorted_script[@]}"; do
                printf "# %-12s # %s\n" "$target" "$(get_target_description "$target" "script")" >> "$config_file"
            done
        fi
        echo >> "$config_file"
    fi
}

open_editor() {
    local file="$1"
    local uruk_dir="$2"  # Pass the uruk directory as parameter
    local editor="${EDITOR:-}"
    local original_pwd="$(pwd)"
    
    # Determine the best available editor
    if [ -z "$editor" ]; then
        local available_editors=()
        local editor_names=()
        
        if command -v nano >/dev/null 2>&1; then
            available_editors+=("nano")
            editor_names+=("nano (user-friendly)")
        fi
        
        if command -v vi >/dev/null 2>&1; then
            available_editors+=("vi")
            editor_names+=("vi (minimal)")
        fi
        
        if [ ${#available_editors[@]} -eq 0 ]; then
            error "No text editor found. Please set EDITOR environment variable or install nano/vi."
        elif [ ${#available_editors[@]} -eq 1 ]; then
            editor="${available_editors[0]}"
            log "Using ${editor} editor"
        else
            echo "🔧 Multiple editors available. Please choose:"
            for i in "${!editor_names[@]}"; do
                echo "  $((i+1)). ${editor_names[i]}"
            done
            echo ""
            
            while true; do
                read -p "Select editor (1-${#available_editors[@]}): " -r choice
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#available_editors[@]} ]; then
                    editor="${available_editors[$((choice-1))]}"
                    break
                else
                    echo "❌ Invalid choice. Please enter a number between 1 and ${#available_editors[@]}."
                fi
            done
        fi
    fi
    
    log "Opening $editor to edit configuration..."
    echo "📝 Please edit the configuration file to select which tools to install."
    echo "💡 Tip: Remove the # symbol from lines for tools you want to install"
    echo "⚠️  Essential tools are already enabled by default"
    echo ""
    
    # Change to uruk directory before opening editor
    cd "$uruk_dir" || error "Failed to enter Uruk directory before editing"
    
    # Handle different execution environments
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        # Running in non-interactive mode (e.g., piped from curl)
        echo "🚨 Detected non-interactive mode (piped from curl)"
        echo "📋 Configuration preview:"
        echo "========================"
        head -10 "$file" 2>/dev/null || echo "Unable to preview configuration"
        echo "... (showing first 10 lines)"
        echo ""
        echo "🔧 Attempting to open editor with terminal access..."
        
        # Open editor with TTY redirection but don't use exec (which replaces the process)
        if [ -e /dev/tty ]; then
            "$editor" "$file" < /dev/tty > /dev/tty 2>&1 || {
                echo "⚠️ Editor exited with non-zero status, but continuing..."
            }
        else
            "$editor" "$file" || {
                echo "⚠️ Editor exited with non-zero status, but continuing..."
            }
        fi
    else
        read -p "Press Enter to open the editor..." -r
        # Open the editor normally
        "$editor" "$file" || {
            echo "⚠️ Editor exited with non-zero status, but continuing..."
        }
    fi
    
    # Verify the editor was used (file was modified)
    if [ ! -s "$file" ]; then
        cd "$original_pwd"  # Restore original directory
        error "Configuration file is empty. Installation cancelled."
    fi
    
    echo ""
    echo "✅ Configuration saved. Proceeding with installation..."
    echo "🔍 Debug: Current directory is $(pwd)"
    echo "🔍 Debug: Config file path is $file"
    echo "🔍 Debug: Config file exists: $([ -f "$file" ] && echo "yes" || echo "no")"
    if [ -f "$file" ]; then
        echo "🔍 Debug: Config file size: $(wc -l < "$file") lines"
    fi
    # Stay in uruk directory for the installation
}

main() {
    echo "🚀 Uruk Remote Installation Script"
    echo "=================================="
    
    # Only cleanup on interrupt/termination, not on normal exit
    trap cleanup INT TERM
    
    # Check environment
    check_macos
    check_dependencies
    
    # Create temporary directory
    log "Creating temporary directory..."
    if ! mkdir -p "$TEMP_DIR" 2>/dev/null; then
        error "Failed to create temporary directory: $TEMP_DIR"
    fi
    
    # Clone repository
    log "Cloning Uruk repository..."
    if ! git clone "$REPO_URL" "$URUK_DIR" 2>&1; then
        error "Failed to clone repository. Please check your internet connection and verify the repository URL."
    fi
    
    success "Repository cloned successfully"
    
    # Generate configuration
    log "Scanning available installation targets..."
    local config_file="$URUK_DIR/custom.conf"
    generate_config "$URUK_DIR/targets" "$config_file"
    
    success "Found $(wc -l < "$config_file" | tr -d ' ') configuration options"
    
    # Let user edit configuration
    open_editor "$config_file" "$URUK_DIR"
    
    echo "🔍 Debug: Returned from open_editor function"
    echo "🔍 Debug: Current directory after editor: $(pwd)"
    
    # Ensure we're in the correct directory for installation
    if ! cd "$URUK_DIR" 2>/dev/null; then
        error "Failed to change to Uruk directory: $URUK_DIR"
    fi
    
    echo "🔍 Debug: Changed to directory: $(pwd)"
    
    # Verify configuration
    echo "🔍 Debug: About to check configuration file: $config_file"
    if [ ! -f "$config_file" ]; then
        error "Configuration file not found: $config_file"
    fi
    
    local enabled_count=$(grep -v "^#" "$config_file" | grep -v "^$" | wc -l | tr -d ' ')
    echo "🔍 Debug: Enabled count: '$enabled_count'"
    
    if [ "$enabled_count" -eq 0 ]; then
        error "No tools selected for installation. Aborting."
    fi
    
    log "Selected $enabled_count tools for installation"
    
    # Show selected tools
    echo "📋 Selected tools:"
    grep -v "^#" "$config_file" | grep -v "^$" | sed 's/^/  - /'
    echo ""
    
    # Confirm installation
    read -p "🤔 Do you want to proceed with installation? (y/N): " -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log "Installation cancelled by user"
        exit 0
    fi
    
    # Run installation (we should already be in URUK_DIR after open_editor)
    log "Starting installation..."
    
    # Verify we're in the right directory
    if [ ! -f "install.sh" ] || [ ! -d "targets" ]; then
        # If not, try to change to the correct directory
        if ! cd "$URUK_DIR" 2>/dev/null; then
            error "Failed to enter Uruk directory: $URUK_DIR"
        fi
    fi
    
    if [ ! -f "install.sh" ]; then
        error "install.sh not found in the cloned repository"
    fi
    
    chmod +x install.sh || error "Failed to make install.sh executable"
    
    if ./install.sh; then
        success "Installation completed successfully!"
        echo ""
        echo "🎉 Welcome to your newly configured development environment!"
        echo "💡 You may need to restart your terminal or run 'source ~/.zshrc' to apply changes."
        echo ""
        echo "📁 Uruk directory: $URUK_DIR"
        echo "🔧 To install more tools:"
        echo "   cd $URUK_DIR"
        echo "   nano custom.conf  # Edit configuration"
        echo "   ./install.sh      # Run installation again"
        echo ""
        echo "🗑️  The temporary directory will be cleaned up automatically by the system."
    else
        error "Installation failed. Please check the output above for details."
    fi
}

main "$@"
