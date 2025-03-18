#!/bin/sh

install_if_needed brew
install_if_needed git

brew install git-lfs
git lfs install
