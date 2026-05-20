{ pkgs }:
{
  brootShell = pkgs.writeShellScript "broot-shell" ''
    nu -e "
      \$env.PROMPT_EXTRA = 'f';
      \$env.config.keybindings = (\$env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });
    "
  '';

  zellijEditorOpen = pkgs.writeShellScript "zellij-editor-open" ''
    file="$1"
    tab_id=$(zellij action list-tabs -a \
        | awk 'NR>1 && $4=="true" {print $1; exit}')
    editor_pane=$(zellij action list-panes -a \
        | awk -v tid="$tab_id" \
            'NR>1 && $1==tid && $6=="EDITOR" {print $4; exit}')
    zellij action write-chars -p "$editor_pane" ":o $file"
    zellij action send-keys -p "$editor_pane" "Enter"
  '';
}
