module git {

    def "nu-complete git tags" [] {
        git tag -l | lines | reverse 
    }

    # List all commits since a specific tag or commit
    export def "git changelog" [
        tag_or_commit: string@"nu-complete git tags"  # Tag from which to start listing commits
    ] {
        git log --oneline $"($tag_or_commit)..HEAD";
    }

    # Pull all repos under the current folder recursively
    export def "git pull-subdirectories" [
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
            git pull-subdirectories;
        }
        return;
    }

    export def "git push-bundle" [
        branch: string  # Branch name to create the bundle from
    ] {
        let bundle = (git remote get-url origin);
        git bundle create $bundle $branch
    }

}
