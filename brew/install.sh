#!/bin/sh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# If failed, run local pre-downloaded script
if ! is_installed brew
then
    /bin/bash -c brew.sh
fi