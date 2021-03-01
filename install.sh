#!/bin/sh

source_script() { # Returns true or false
    . "$1"
    if [ $? -eq 0 ]; then
        true
        return
    else
        false
        return
    fi
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
        return
    else
        false
        return
    fi
}

is_brew_target() {
    if [ -r "$current_dir/targets/$1.brewtarget" ]; then
        true
        return
    else
        false
        return
    fi
}

is_cask_target() {
    if [ -r "$current_dir/targets/$1.casktarget" ]; then
        true
        return
    else
        false
        return
    fi
}

is_installed_by_brew() {
    install_if_needed brew
    brew list "$1" &>/dev/null
    return
}

is_cask_installed_by_brew() {
    install_if_needed brew
    brew list --cask "$1" &>/dev/null
    return
}

install_with_brew() {
    install_if_needed brew
    brew install "$1"
}

is_installed() {
    # Check if `is_installed.sh` exists
    script_path="$current_dir/targets/$1/is_installed.sh"
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
    # Check if command exists
    command -v "$1" >/dev/null 2>&1
    return
}

install_if_needed() {
    if is_installed "$1"; then
        echo "$1" already installed.
    else
        install_one "$1"
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
        echo "Please specify target(s) to install."
        return
    fi
    for target in $all_targets
    do
        install_if_needed "$target"
    done
}

install_one() {
    if [ -z "$1" ]; then
        echo Nothing to install.
        return
    fi
    # `python/install.sh` > `python.sh`
    if [ -r "$current_dir/targets/$1/install.sh" ]; then
        script_path=$current_dir/$1/install.sh
    else
        if [ -r "$current_dir/targets/$1.sh" ]; then
            script_path=$current_dir/$1.sh
        fi
    fi
    if [ -z "$script_path" ]; then # Execute script if found
        echo Installing "$1"...
        add_execution_permission "$script_path"
        source_script "$script_path" || exit $? # Exit on installation error
        return
    fi
    # Check if is brew target
    if is_brew_target "$1"; then
        echo Installing "$1"...
        install_with_brew "$1"
        return
    fi
    # Check if is cask target
    if is_cask_target "$1"; then
        install_with_brew "$1"
        return
    fi
    cat <<EOS
Error: You need to specify the way to install target $1
You can do any of the following:
1. Create $current_dir/targets/$1/install.sh and write installation code.
2. Create $current_dir/targets/$1.sh and write installation code.
3. Create $current_dir/targets/$1.brewtarget with empty content if it's a brew command line tool.
4. Create $current_dir/targets/$1.casktarget with empty content if it's a brew cask app.
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
install_all "$@"
if [ $? -eq 0 ]; then
    echo "Installation complete."
    if $needs_source_profile; then
        echo
        echo "Please type following commands into terminal and press Enter:"
        echo "source $shell_profile"
    fi
fi