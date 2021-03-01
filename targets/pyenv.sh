#!/bin/sh

install_with_brew pyenv
append_to_profile_if_needed "if command -v pyenv 1>/dev/null 2>&1; then eval \"\$(pyenv init -)\"; fi"
source_profile