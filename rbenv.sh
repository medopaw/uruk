#!/bin/sh

install_with_brew rbenv
append_to_profile_if_needed "if command -v rbenv 1>/dev/null 2>&1; then eval \"\$(rbenv init -)\"; fi"
source_profile