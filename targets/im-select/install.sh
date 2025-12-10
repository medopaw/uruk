#!/bin/sh

# im-select requires tapping daipeihust/tap first
install_if_needed brew
brew tap daipeihust/tap
install_with_brew im-select
