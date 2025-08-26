#!/bin/bash

set -e

# Install git-delta via brew
brew install git-delta

# Configure git to use delta as pager and diff filter
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

echo "git-delta installed and configured successfully"