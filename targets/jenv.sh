#!/bin/sh

# Untested

install_with_brew jenv
jenv enable-plugin export
append_to_profile_if_needed "export PATH=\"$HOME/.jenv/bin:$PATH\""
append_to_profile_if_needed "eval "$(jenv init -)"
source_profile