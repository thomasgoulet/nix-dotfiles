#!/bin/sh

file="$1"

tab_id=$(zellij action list-tabs -a \
    | awk 'NR>1 && $4=="true" {print $1; exit}')

editor_pane=$(zellij action list-panes -a \
    | awk -v editor="$EDITOR" -v tid="$tab_id" \
        'NR>1 && $1==tid && $7==editor {print $4; exit}')

zellij action write-chars -p "$editor_pane" ":o $file"
zellij action send-keys -p "$editor_pane" "Enter"
