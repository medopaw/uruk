#!/bin/sh

old_shell_profile="$shell_profile"

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if ! is_installed oh-my-zsh; then
    sh targets/oh-my-zsh/oh-my-zsh.sh
fi

if [[ -r "$old_shell_profile" ]] && [ "$old_shell_profile" != "$HOME/.zshrc" ]; then
    cat "$old_shell_profile" >> "$HOME/.zshrc"
fi