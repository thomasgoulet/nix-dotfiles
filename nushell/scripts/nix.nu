#!/usr/bin/env nu
def main [
    subcommand: string@["diff-symlink" "toggle-symlink"]
    ...args: string
] {
    match $subcommand {
        "diff-symlink" => {nix-diff-symlink ($args | first)}
        "toggle-symlink" => {nix-toggle-symlink ($args | first)}
    }
    return
}

export def nix-diff-symlink [
    file: path
] {
    difft ($file | nix-backup) $file;
}

export def nix-toggle-symlink [
    file: path
] {
    let backup = ($file | nix-backup);
    if ($backup | path exists) {
        mv ($backup) $file;
        return;
    }
    mv $file ($backup);
    cat $backup o> $file
}

def nix-backup []: path -> string {
    $in
    | append ".symlink"
    | str join
}
