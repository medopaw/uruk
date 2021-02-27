#!/bin/sh

install_if_needed brew
brew install rbenv
append_to_profile_if_needed "eval \"\$(rbenv init -)\""
source_profile