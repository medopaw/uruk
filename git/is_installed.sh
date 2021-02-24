#!/bin/sh

if [[ $(command -v git) = /usr/local/bin/git ]]
then
    true
    return
else
    false
    return
fi