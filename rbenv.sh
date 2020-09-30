#!/bin/sh

install_if_needed brew
brew install rbenv
rbenv init
source_profile
