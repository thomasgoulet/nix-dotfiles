module nix {

    ### GIT

    export alias dotfiles-git = git --git-dir=/home/thomas/.dotfiles/ --work-tree=/home/thomas;
    export alias dotfiles = zellij action new-tab -c /home/thomas/ -n dotfiles -l ~/.config/zellij/layouts/dotfiles.kdl;

    ### Completions

    def "nu-complete nix generations" [] {
        home-manager generations
        | lines
        | each {|l| $l |
            parse "{description} : id {value} -> {path}"
            | {
                description: ($in.description | get 0 | into datetime),
                value: ($in.value | get 0 | into int),
                path: ($in.path | get 0),
            }
        };
    };

    ### Utils

    def package-diff [
        closure: closure  # Package altering closure. Should not expect any arguments
    ] {
        let before_path = (mktemp -t --suffix .packages)
        let after_path = (mktemp -t --suffix .packages)

        home-manager packages
        | save -f ($before_path);

        do $closure

        home-manager packages
        | save -f ($after_path);

        delta ($before_path) ($after_path) --pager never;
    }

    ### Commands

    # Garbage collect the local nix store
    export def "nx gc" [
        timestamp = "-14 days"  # Timestamp or duration before which generations will be removed ("-14 days" or "2024-01-01"). Default is "-7 days"
    ] {
        home-manager expire-generations $timestamp;
        nix store gc;
    }
  
    # List all available generations
    export def "nx generations" [] {
        nu-complete nix generations
        | rename DATE ID PATH;
    }

    # Info about installed packages and flake
    export def "nx info" [] {
        let packages = (
            home-manager packages
            | column -x -c (term size | get columns)
        );

        print $"(ansi light_gray)Packages:(ansi reset)";
        print -n ($packages)
        print (nix flake metadata ~/.config/home-manager/);
    }
  
    # Rollback to an earlier generation
    export def "nx rollback" [
        generation: int@"nu-complete nix generations"
    ] {
        package-diff {
            cd (
                nu-complete nix generations
                | where value == $generation
                | first
                | get path
            );
            ./activate;
        };
    }

    # Build and switch to a new genration
    export def "nx switch" [] {
        package-diff {
            home-manager switch --flake ~/.config/home-manager/;
        }
    }


    # Update channels and switch configuration
    export def "nx upgrade" [] {
        package-diff {
            nix flake update --flake ~/.config/home-manager/;
            home-manager switch --flake ~/.config/home-manager/;
        };
    }

    # Launch a nix shell with the specified packages installed
    export def "nx try" [
        ...packages  # Packages to temporarily install
    ] {
        nix-shell --command "nu -e '$env.config.keybindings = ($env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });'" -p ...$packages;
    }

    # Launch a nix shell with the specified packages installed as well as numpy and pandas
    export def "nx try-py" [
        ...extrapackages  # Python packages to temporarily install
    ] {
        let version = python --version | parse "Python {major}.{minor}.{patch}"
        let prefix = $"python($version.major | first)($version.minor | first)Packages"
        let packages = ["numpy", "pandas"] | append $extrapackages | each {|p| $"($prefix).($p)"}
        $packages
        nix-shell --command "nu -e '$env.config.keybindings = ($env.config.keybindings | append {name: exit modifier: none keycode: esc mode: [emacs] event: {send: ctrld} });'" -p ...$packages;
    }
}
