module zellij {

    export def "nu-complete paths" [] {
        zoxide query --list
        | lines
        | each { {value: ($in | path basename) description: ($in | str replace $env.HOME '~')} }
        | uniq-by value
    }

    # Open a project in a new ZelliJ tab.
    # The available projects can be listed using `project list`.
    export def edit [
        ...hints: string@"nu-complete paths"
    ] {
        mut path = (zoxide query ...$hints);
        if ($hints == []) { $path = $env.PWD }
        zellij action new-tab -c $path -n ($path | path basename) -- $env.EDITOR o> (null-device);
    }

    export def session [
        ...hints: string@"nu-complete paths"
    ] {
        mut path = (zoxide query ...$hints);
        if ($hints == []) { $path = $env.PWD }

        cd $path;
        try { zellij attach -b ($path | path basename) o+e> (null-device) };
        zellij action switch-session ($path | path basename) --cwd $path;
    }

}
