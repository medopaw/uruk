#!/bin/sh

install_if_needed rbenv
install_if_needed fzf
echo "Please choose ruby version to install. Press ENTER to continue:"
read
ruby_version=`rbenv install -l | fzf | tr -d ' '`
echo "Installing ruby $ruby_version now..."
rbenv install "$ruby_version"
rbenv global "$ruby_version"
source_profile