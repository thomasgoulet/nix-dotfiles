#!/bin/sh

zellij ac toggle-floating-panes
zellij ac write-chars ":o $1${2:+:$2}"
zellij ac write 13
zellij ac toggle-floating-panes
