#!/bin/sh

zellij ac move-focus right
zellij ac write-chars ":o $1"
zellij ac write 13
zellij ac move-focus left
