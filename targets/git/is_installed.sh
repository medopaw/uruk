#!/bin/sh

if [[ $(command -v git) = /usr/local/bin/git ]]; then
    true
else
    false
fi