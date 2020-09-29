#!/bin/sh

install_if_needed rbenv
install_if_needed fzf
latest_ruby_version=`rbenv install -l | fzf`
rbenv install "$latest_ruby_version"
rbenv global "$latest_ruby_version"
