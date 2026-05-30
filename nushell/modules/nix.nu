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

    export alias "nix diff" = nh os test --dry --diff always --hostname $env.NH_HOST;
    export alias "nix switch" = nh os switch --diff always --hostname $env.NH_HOST;
    export alias "nix update" = nh os switch --update --diff always --hostname $env.NH_HOST;
    export alias "nix gc" = nh clean all;

    ### Commands

    # List all available generations
    export def "nix generations" [] {
        nu-complete nix generations
        | rename ID DATE VERSION CURRENT;
    }

    # Rollback to a specific generation or the previous one
    export def "nix rollback" [
        generation?: int@"nu-complete nix generations"  # Optional: generation ID to rollback to
    ] {
        if ($generation == null) {
            nh os rollback --diff always;
        } else {
            # Switch to specific generation
            nh os rollback --to $generation --diff always;
        }
    }

    # Open Nix REPL with flake loaded
    export def "nix flake-repl" [] {
        nix repl --expr $"builtins.getFlake \"($env.NH_FLAKE)\"";
    }

    # Launch a nix shell with the specified packages installed
    export def "nix install" [
        ...packages  # Packages to temporarily install
    ] {
        nix-shell --command $"ESCAPE_MODE=\"($packages)\" nu" -p ...$packages;
    }
}
