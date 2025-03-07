#!/bin/sh

source_script() { # Returns true or false
    . "$1"
}

source_profile() {
    . "$shell_profile"
}

append_to_profile_if_needed() {
    if [ -r "$shell_profile" ]; then
        if ! grep -q "$1" "$shell_profile"; then
            echo "$1" >> "$shell_profile"
        fi
    else
        echo "$1" >> "$shell_profile"
    fi
}

add_execution_permission() {
    chmod +x "$1"
}

exists_in_application_folder() {
    if [ -d "/Applications/$1.app" ]; then
        true
    else
        false
    fi
}

get_mas_id() {
    local target_file="$current_dir/targets/$1.mastarget"
    [ -r "$target_file" ] && cat "$target_file" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' || echo ""
}

is_brew_target() {
    if [ -r "$current_dir/targets/$1.brewtarget" ]; then
        true
    else
        false
    fi
}

is_cask_target() {
    if [ -r "$current_dir/targets/$1.casktarget" ]; then
        true
    else
        false
    fi
}

is_mas_target() {
    if [ -r "$current_dir/targets/$1.mastarget" ]; then
        true
    else
        false
    fi
}

is_installed_by_brew() {
    install_if_needed brew
    brew list "$1" &>/dev/null
}

is_cask_installed_by_brew() {
    install_if_needed brew
    brew list --cask "$1" &>/dev/null
}

is_installed_by_mas() {
    install_if_needed mas
    local mas_id=$(get_mas_id "$1")
    if [ -z "$mas_id" ]; then
        echo "Error: No MAS ID found for $1" >&2
        exit 1
    fi
    # 从 mas list 中查找以 $mas_id 开头的行
    mas list | grep -q "^$mas_id"
}

install_with_brew() {
    install_if_needed brew
    brew install "$1"
}

install_cask_with_brew() {
    install_if_needed brew
    brew install --cask "$1"
}

install_with_mas() {
    install_if_needed mas
    local mas_id=$(get_mas_id "$1")
    if [ -z "$mas_id" ]; then
        echo "Error: No MAS ID found for $1" >&2
        exit 1
    fi
    echo "mas id: $mas_id"
    mas install "$mas_id"
}

is_installed() {
    # Check if `is_installed.sh` exists
    local script_path="$current_dir/targets/$1/is_installed.sh"
    if [ -r "$script_path" ]; then
        add_execution_permission "$script_path"
        source_script "$script_path"
        return
    fi
    # Check if is brew target
    if is_brew_target "$1"; then
        is_installed_by_brew "$1"
        return
    fi
    # Check if is cask target
    if is_cask_target "$1"; then
        is_cask_installed_by_brew "$1"
        return
    fi
    # Check if is mas target
    if is_mas_target "$1"; then
        is_installed_by_mas "$1"
        return
    fi
    # Check if command exists
    command -v "$1" >/dev/null 2>&1
}

install_if_needed() {
    if is_installed "$1"; then
        if ! $silent_if_possible; then
            echo "$1" already installed.
        fi
    else
        install_one "$1"
        if [ $? -eq 0 ]; then
            anything_installed=true
        fi
    fi
}

install_all() {
    all_targets=$*
    if [ -z "$all_targets" ]; then # No arguments
        if [ -r "$current_dir/custom.conf" ]; then # Read custom.conf
            all_targets=$(cat "$current_dir/custom.conf")
        else
            if [ -r "$current_dir/default.conf" ]; then # Read default.conf
                all_targets=$(cat "$current_dir/default.conf")
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

install_one() {
    if [ -z "$1" ]; then
        echo "Error: Nothing to install." >&2
        return 1
    fi
    local script_path=''
    if [ -r "$current_dir/targets/$1/install.sh" ]; then
        script_path="$current_dir/targets/$1/install.sh"
        echo Installing "$1"...
        add_execution_permission "$script_path"
        source_script "$script_path" || exit # Exit on installation error
        return
    fi
    if [ -r "$current_dir/targets/$1.sh" ]; then
        script_path="$current_dir/targets/$1.sh"
        echo Installing "$1"...
        add_execution_permission "$script_path"
        source_script "$script_path" || exit # Exit on installation error
        return
    fi
    # Check if is brew target
    if is_brew_target "$1"; then
        echo Installing "$1"...
        install_with_brew "$1" || exit # Exit on installation error
        return
    fi
    # Check if is cask target
    if is_cask_target "$1"; then
        echo Installing "$1"...
        install_cask_with_brew "$1" || exit # Exit on installation error
        return
    fi
    # Check if is mas target
    if is_mas_target "$1"; then
        echo Installing "$1"...
        install_with_mas "$1" || exit # Exit on installation error
        return
    fi
    cat <<EOS
Error: You need to specify the way to install target $1

You can do any of the following:
1. Create $current_dir/targets/$1/install.sh and write installation code.
2. Create $current_dir/targets/$1.sh and write installation code.
3. Create $current_dir/targets/$1.brewtarget with empty content if it's a brew command line tool.
4. Create $current_dir/targets/$1.casktarget with empty content if it's a brew cask app.
5. Create $current_dir/targets/$1.mastarget with Mac App Store ID if it's a MAS app.
EOS
    return 1 # Can't install. Need to stop.
}

current_dir=$PWD
case "$SHELL" in
*/bash*)
    shell_profile="$HOME/.bash_profile"
    ;;
*/zsh*)
    shell_profile="$HOME/.zshrc"
    ;;
*)
    if [[ -r "$HOME/.bash_profile" ]]; then
        shell_profile="$HOME/.bash_profile"
    else
        shell_profile="$HOME/.profile"
    fi
    ;;
esac
needs_source_profile=false
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
