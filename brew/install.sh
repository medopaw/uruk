#!/bin/sh

install_if_needed xcode-command-line-tools # Make sure git is available

# Set global user.email, otherwise brew installation would fail
if [ ! $(git config --global user.email) ]
then
    echo "Please input your email for git global config:"
    read email
    git config --global user.email "$email"
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# If failed, run local pre-downloaded script
if ! is_installed brew
then
    # First clone brew-cask from faster source in China to save time
    cask_dir=/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
    mkdir -p "$cask_dir"
    git clone https://mirrors.ustc.edu.cn/homebrew-cask.git "$cask_dir"
    /bin/bash brew/brew.sh
    append_to_profile_if_needed "export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles"
    source_profile
fi