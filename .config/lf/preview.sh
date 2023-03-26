#!/bin/sh
case "$1" in
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *) bat -f --paging=never --style=changes --terminal-width $(($2-5)) "$1" ;;
esac
