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
    script_path=$current_dir/$1/is_installed.sh
    if [ -r "$script_path" ]; then
        add_execution_permission "$script_path"
        if source_script "$script_path"; then
            true
            return
        else
            false
            return
        fi
    else
        if command -v "$1" >/dev/null 2>&1; then
            true
            return
        else
            false
            return
        fi
    fi
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
    if [ -r "$current_dir/$1/install.sh" ]; then
        script_path=$current_dir/$1/install.sh
    else
        if [ -r "$current_dir/$1.sh" ]; then
            script_path=$current_dir/$1.sh
        else
            echo "Can't locate $current_dir/$1/install.sh or $current_dir/$1.sh"
            return
        fi
    fi
    echo Installing "$1"...
    add_execution_permission "$script_path"
    source_script "$script_path" || exit $? # Exit on installation error
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