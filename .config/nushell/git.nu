module git {

    # Git alias
    export alias g = git

    def "nu-complete git branches" [] {
        ^git branch
        | lines
        | where $it !~ "HEAD"
        | each {|line|
            $line
            | str replace '[\*\+] ' ''
            | str trim
        };
    }

    def "nu-complete git remote branches" [] {
        ^git branch -a
        | lines
        | where $it !~ "HEAD"
        | where $it !~ \*
        | each {|line|
            $line
            | str replace '[\*\+] ' ''
            | str trim
            | str replace 'remotes/' ''
            | str replace 'origin/' ''
        }
        | uniq;
    }

    def "nu-complete git tags" [] {
        git tag -l | lines | reverse 
    }

    # Show git logs
    export def gl [] {
        let commit = (
            git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"
            | fzf --ansi --no-sort -m --height 100% --reverse --bind 'tab:down' --bind 'shift-tab:up' --preview 'git show --color=always (echo {} | str substring 2..9)' --preview-window=right:61%
        );
        if ($commit != "") {
            git show --color=always ($commit | str substring 2..9);
        }
    }

    # Pull all repos under the current folder recursively
    export def gpla [
        branch = "master"  # Default branch name to use
    ] {
        if (".git" | path exists) {
            print $"Pulling (pwd)";
            git switch $branch o> (null-device);
            git pull --prune o> (null-device);
            return
        }
        ls -a
        | where type == dir
        | par-each {|s|
            cd $s.name;
            gpla;
        }
        return;
    }

    # List all commits since a specific tag
    export def "git changelog" [
        tag: string@"nu-complete git tags"  # Tag from which to start listing commits
    ] {
        git log --oneline $"($tag)..HEAD";
    }
}
