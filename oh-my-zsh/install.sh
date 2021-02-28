#!/bin/sh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if ! is_installed oh-my-zsh; then
    sh oh-my-zsh/oh-my-zsh.sh
fi