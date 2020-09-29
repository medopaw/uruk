#!/bin/sh

add_execution_permission() {
    chmod +x "$1"
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
    # 暂时不考虑子目录递归，因为子目录下改变 target 之后，is_installed 就无效了
    # if [ -d "$current_dir/$1" ]
    # then
        # original_dir=$current_dir
        # current_dir=$current_dir/$1
        # install_all $1
        # current_dir=$original_dir
    # fi
}

current_dir=$PWD
install_all "$@"

