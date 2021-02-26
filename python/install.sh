#!/bin/sh

install_if_needed pyenv
install_if_needed brew
brew update && brew upgrade pyenv
install_if_needed fzf
echo "Please choose python version to install. Enter to continue:"
read
python_version=`pyenv install -l | fzf`
echo "Installing python $python_version now..."
pyenv install "$python_version"
pyenv global "$python_version"