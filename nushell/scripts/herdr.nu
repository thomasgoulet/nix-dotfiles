#!/usr/bin/env nu
def main [
    subcommand: string@["edit" "run"]
    ...args: string
] {
    match $subcommand {
        "edit" => {herdr-edit ($args | first)}
        "run" => {herdr-run ($args.0) ($args.1 | into float) ($args | slice 2..-1)}
    }
    return
}

# Opens the given file in $EDITOR giving priority to current tab, workspace, than within pane.
export def herdr-edit [
    file: string
] {
    if ("HERDR_ENV" not-in $env) {
        run-external $env.EDITOR $file;
        return;
    }

    let panes = (herdr pane list --workspace $env.HERDR_WORKSPACE_ID | from json | get result.panes);
    let editor_filter = { $in | where scroll.max_offset_from_bottom == 0 and terminal_title =~ $env.EDITOR }

    let editor_in_tab = ($panes | where tab_id == $env.HERDR_TAB_ID | do $editor_filter);
    if ($editor_in_tab | length) > 0 {
        let pane_id = ($editor_in_tab | first | get pane_id);
        herdr-edit-send-file $pane_id $file;
        return;
    }

    let editor_in_workspace = ($panes | do $editor_filter);
    if ($editor_in_workspace | length) > 0 {
        let pane_id = ($editor_in_workspace | first | get pane_id);
        let tab_id = ($editor_in_workspace | first | get tab_id);
        herdr-edit-send-file $pane_id $file;
        herdr tab focus $tab_id;
        return;
    }

    run-external $env.EDITOR $file;
    return;
}

export def herdr-run [
    location: string@["pane" "tab"]
    ratio: float
    args: list<string>
] {
    if ("HERDR_ENV" not-in $env) {
        run-external ...$args
        return;
    }

    if ($location == "pane") {
        herdr pane split --current --direction right --focus --ratio $ratio
        | from json
        | get result.pane.pane_id
        | herdr pane run $in ...$args;
    }

    if ($location == "tab") {
        herdr tab create --label ($args | str join ' ') --focus
        | from json
        | get result.root_pane.pane_id
        | herdr pane run $in ...$args;
    }
}

# Sends ":o $file" to the given herdr pane
def herdr-edit-send-file [
    pane_id: string
    file: string
] {
    let file_keys = (
        ":o " + $file
        | split chars
        | str replace " " "space"
        | append "enter"
    );

    herdr pane send-keys $pane_id ...$file_keys;
}
