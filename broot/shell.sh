#!/bin/sh
nu -e '
    $env.PROMPT_EXTRA = "br";
    $env.config.keybindings = ($env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });
'
