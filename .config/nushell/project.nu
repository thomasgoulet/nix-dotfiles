module project {

    const projectfile = "~/.projects.json" | path expand;

    def "nu-complete projects" [] {
        open $projectfile
        | select path key
        | rename value description
    }

    def get-projects [] {
        try {
            return (open $projectfile | sort-by weight --reverse);
        } catch {
            |err|
            print $err
            [] | save $projectfile
            return [];
        }
    }

    #  Add a project to the project list
    export def "project add" [
        path: path
        key: string
        weight: int
    ] {
        get-projects
        | append {key: $key, path: $path, weight: $weight}
        | sort-by weight --reverse
        | save $projectfile -f
    }

    #  Directly edit the project JSON file with the configured editor
    export def "project edit" [] {
        run-external $env.EDITOR $projectfile
    }

    #  List the available projects, their keys and their weights
    export def "project list" [] {
        return (get-projects);
    }

    # Open a project using the configured ZelliJ, the available projects can be listed using `project list`
    export def work [
        ...hints: string@"nu-complete projects"
    ] {
        let open = {
            |path|
            zellij action new-tab -c $path -n (basename $path) -l ~/.config/zellij/layouts/edit.kdl
        };

        if ($hints == []) {
            do $open (get-projects | first | get path)
            return;
        }

        if ($hints == ["."]) {
            do $open $env.PWD;
            return;
        }

        mut projects = get-projects
        mut remaining_hints = $hints
        while ($remaining_hints != []) {
            let hint = ($remaining_hints | first);
            $projects = ($projects | where key =~ $hint);
            $remaining_hints = ($remaining_hints | skip 1);
        }
        if ($projects | is-not-empty) {
            do $open ($projects | first | get path);
            return;
        }

        return (get-projects);
    }

}
