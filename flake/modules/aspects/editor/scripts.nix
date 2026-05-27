{ pkgs }:
{
  brootShell = pkgs.writeShellScript "broot-shell" ''
    nu -e "
      \$env.PROMPT_EXTRA = 'f';
      \$env.config.keybindings = (\$env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });
    "
  '';

  editorWrapper = pkgs.writeShellScript "editor-wrapper" ''
    file="$1"
    tab_id=$(zellij action list-tabs -j | jq -r '.[] | select(.active) | .tab_id')
    editor_pane=$(zellij action list-panes -j -c -t  | jq -r --argjson tid "$tab_id" --arg editor "$EDITOR" '.[] | select(.tab_id == $tid and (.pane_command // "" | endswith($editor))) | .id')
    if [ -z "$tab_id" ] || [ -z "$editor_pane" ]; then
      exec $EDITOR "$file"
    fi
    zellij action write-chars -p "$editor_pane" ":o $file"
    zellij action send-keys -p "$editor_pane" "Enter"
  '';
}
