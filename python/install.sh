#!/bin/sh

install_if_needed pyenv
install_if_needed brew
brew update && brew upgrade pyenv
install_if_needed fzf
echo "Please choose python version to install. Press ENTER to continue:"
read
python_version=`pyenv install -l | fzf | sed -e 's/^\s*//'`
echo "Installing python $python_version now..."
pyenv install "$python_version"
pyenv global "$python_version"