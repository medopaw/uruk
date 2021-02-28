#!/bin/sh

install_if_needed pyenv
install_if_needed fzf
echo "Please choose python version to install. Press ENTER to continue:"
read
python_version=`pyenv install -l | fzf | tr -d ' '`
echo "Installing python $python_version now..."
pyenv install "$python_version"
pyenv global "$python_version"
source_profile