#!/bin/sh

zellij ac move-focus right
zellij ac write-chars ":o $1${2:+:$2}"
zellij ac write 13
zellij ac move-focus left
