#!/bin/sh

# Source shared functions
SCRIPT_DIR=$(dirname "$(realpath "$0")")
if [ ! -r "$SCRIPT_DIR/functions.sh" ]; then
    echo "Error: functions.sh not found. Please run from the Uruk directory." >&2
    exit 1
fi

# Set variables needed by functions.sh
root_dir="$SCRIPT_DIR"

# Source the shared functions
. "$SCRIPT_DIR/functions.sh"

install_all() {
    all_targets=$*
    if [ -z "$all_targets" ]; then # No arguments
        if [ -r "$root_dir/custom.conf" ]; then # Read custom.conf
            # Extract clean target list from config file (remove comments and empty lines)
            all_targets=$(grep -v "^#" "$root_dir/custom.conf" | grep -v "^$" | sed 's/#.*$//' | sed 's/[[:space:]]*$//' | tr '\n' ' ')
        else
            if [ -r "$root_dir/default.conf" ]; then # Read default.conf
                # Extract clean target list from config file (remove comments and empty lines)
                all_targets=$(grep -v "^#" "$root_dir/default.conf" | grep -v "^$" | sed 's/#.*$//' | sed 's/[[:space:]]*$//' | tr '\n' ' ')
            fi
        fi
    fi
    if [ -z "$all_targets" ]; then # Still no arguments
        echo "Error: Please specify target(s) to install." >&2
        return 1
    fi
    for target in $all_targets
    do
        install_if_needed "$target"
    done
}

# Initialize variables for this script
anything_installed=false
silent_if_possible=false
cli_params=()
# 遍历所有参数，过滤出 --silent-if-possible 参数
for arg in "$@"; do
    if [[ "$arg" == "--silent-if-possible" ]]; then
        silent_if_possible=true
    else
        cli_params+=("$arg")
    fi
done
install_all "${cli_params[@]}"
if [ $? -eq 0 ]; then
    if $anything_installed; then
        if ! $silent_if_possible; then
            echo "Installation complete."
        fi
    fi
    if $needs_source_profile; then
        echo
        echo "Please type following commands into terminal and press Enter:"
        echo "source $shell_profile"
    fi
fi
