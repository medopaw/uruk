#!/bin/sh

cat <<EOS
Notice: oh-my-zsh installation will execute "zsh" thus targets after oh-my-zsh will not be installed.

You need to run following command manually after oh-my-zsh installation to install targets after oh-my-zsh:
    make install

To migrate shell profile, please run following command after oh-my-zsh installation:
    cat "$shell_profile" >> "$HOME/.zshrc"

Press Enter to install oh-my-zsh:
EOS
read

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if ! is_installed oh-my-zsh; then
    sh targets/oh-my-zsh/oh-my-zsh.sh
fi