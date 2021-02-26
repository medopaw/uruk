#!/bin/sh

if is_installed pyenv
then
    command -v python | grep -q .pyenv
    return
else
    false
    return
fi