#!/bin/sh

add_execution_permission() {
    chmod +x "$1"
}

source_profile() {
    if [ -f "$HOME/.zshrc" ]
    then
        . "$HOME/.zshrc"
        return
    fi
    if [ -f "$HOME/.bash_profile" ]
    then
        . "$HOME/.bash_profile"
        return
    fi
    if [ -f "$HOME/.bashrc" ]
    then
        . "$HOME/.bashrc"
        return
    fi
}

is_installed() {
    if command -v "$1" >/dev/null 2>&1
    then
        true
        return
    else
        false
        return
    fi
}

install_if_needed() {
    if is_installed "$1"
    then
        echo "$1" already installed.
    else
        install_one "$1"
    fi
}

install_all() {
    all_targets=$*
    if [ -z "$all_targets" ] # 没有参数
    then
        if [ -f "$current_dir/custom.conf" ]
        then # 读取 custom.conf
            all_targets=$(cat "$current_dir/custom.conf")
        else
            if [ -f "$current_dir/default.conf" ]
            then # 读取 default.conf
                all_targets=$(cat "$current_dir/default.conf")
            fi
        fi
    fi
    if [ -z "$all_targets" ] # 仍然没有参数
    then
        echo "Please specify target(s) to install."
        return
    fi
    for target in $all_targets
    do
        install_if_needed "$target"
    done
}

install_one() {
    if [ -z "$1" ]
    then
        echo Nothing to install.
        return
    fi
    if [ -f "$current_dir/$1.sh" ]
    then
        echo Installing "$1"...
        add_execution_permission "$1.sh"
        . "$current_dir/$1.sh"
        return
    fi
    if [ -f "$current_dir/$1/install.sh" ]
    then
        echo Installing "$1"...
        add_execution_permission "$1.sh"
        . "$current_dir/$1.sh"
        return
    fi
}

current_dir=$PWD
install_all "$@"

