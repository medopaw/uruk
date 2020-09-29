#!/bin/sh

install_if_needed pyenv
install_if_needed fzf
latest_python_version=`pyenv install -l | fzf`
pyenv install "$latest_python_version"
pyenv global "$latest_python_version"
