#!/bin/sh

if is_installed rbenv; then
    command -v ruby | grep -q .rbenv
    return
else
    false
    return
fi