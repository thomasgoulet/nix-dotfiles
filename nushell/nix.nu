module nix {

    ### Completions

    def "nu-complete nix generations" [] {
        nixos-rebuild list-generations
        | from ssv -a
        | select Generation "Build-date" "NixOS version" Current
        | rename value description version current
        | update description { into datetime }
        | update current { into bool };
    };

    ### Alias

    export alias "os build" = nh os switch --diff always;
    export alias "os update" = nh os switch --update --diff always;

    export alias "os diff" = nh os test --dry --diff always;
    export alias "os gc" = nh clean all;

    ### Commands

    # List all available generations
    export def "os generations" [] {
        nu-complete nix generations
        | rename ID DATE VERSION CURRENT;
    }

    # Rollback to a specific generation or the previous one
    export def "os rollback" [
        generation?: int@"nu-complete nix generations"  # Optional: generation ID to rollback to
    ] {
        if ($generation == null) {
            nh os rollback --diff always
        } else {
            # Switch to specific generation
            nh os rollback --to $generation --diff always
        }
    }

    # Open Nix REPL with flake loaded
    export def "os repl" [] {
        nix repl --expr $"builtins.getFlake \"($env.NH_FLAKE)\""
    }

    # Launch a nix shell with the specified packages installed
    export def "os try" [
        ...packages  # Packages to temporarily install
    ] {
        nix-shell --command "nu -e '$env.config.keybindings = ($env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });'" -p ...$packages;
    }
}
