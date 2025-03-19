#!/bin/sh

install_if_needed git
install_if_needed emacs
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install
