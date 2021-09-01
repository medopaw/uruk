#!/bin/sh

install_cask_with_brew p4v
git config --global diff.tool p4merge
git config --global merge.tool p4merge