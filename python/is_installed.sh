#!/bin/sh

if is_installed pyenv
then
    pyenv version | grep -q .pyenv
    return
else
    false
    return
fi