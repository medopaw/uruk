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
    /bin/bash brew/brew.sh
fi