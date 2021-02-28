#!/bin/sh

install_if_needed brew
brew install rbenv
append_to_profile_if_needed "if command -v rbenv 1>/dev/null 2>&1; then eval \"\$(rbenv init -)\"; fi"
source_profile