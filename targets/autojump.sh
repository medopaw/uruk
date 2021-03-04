#!/bin/sh

install_with_brew autojump
append_to_profile_if_needed "[ -f \$(brew --prefix)/etc/profile.d/autojump.sh ] && . \$(brew --prefix)/etc/profile.d/autojump.sh"