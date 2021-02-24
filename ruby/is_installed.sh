#!/bin/sh

if is_installed rbenv
then
    rbenv version | grep -q .rbenv
    return
else
    false
    return
fi