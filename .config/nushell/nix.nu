module nix {

    export alias dotfiles-git = git --git-dir=/home/thomas/.dotfiles/ --work-tree=/home/thomas;
    export alias dotfiles = zellij action new-tab -c /home/thomas/ -n dotfiles -l ~/.config/zellij/layouts/dotfiles.kdl;

    def "nu-complete nix generations" [] {
        home-manager generations
        | lines
        | each {|l| $l |
            parse "{description} -> {value}"
        }
        | flatten;
    };

    export alias "nx switch" = home-manager switch --flake ~/.config/home-manager/;  # Build and switch to a new derivation
  
    # Garbage collect the local nix store
    export def "nx gc" [
        timestamp = "-7 days"  # Timestamp or duration before which generations will be removed ("-7 days" or "2024-01-01"). Default is "-7 days"
    ] {
        home-manager expire-generations $timestamp;
        nix store gc;
    }
  
    # List all available generations
    export def "nx generations" [] {
        home-manager generations
        | lines
        | each {|l| $l |
            parse "{date} : id {id} -> {path}"
        }
        | flatten;
    }
  
    # Rollback to an earlier generation
    export def "nx rollback" [
        generation: path@"nu-complete nix generations"
    ] {
        cd $generation;
        ./activate;
    }

    # Update channels and switch configuration
    export def "nx upgrade" [] {
        nix-channel --update;
        home-manager switch --flake ~/.config/home-manager/;
    }

    # Launch a  nix shell with the specified packages installed
    export def "nx try" [
        ...packages  # Packages to temporarily install
    ] {
        nix-shell --command "nu -e '$env.config.keybindings = ($env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });'" -p ...$packages;
    }
}
