#!/bin/sh

install_if_needed brew
brew install pyenv
append_to_profile_if_needed "eval \"\$(pyenv init -)\""
source_profile