module task {

    const notes_path = "/home/thomas/notes";

    export def "nu-complete tasks" [] {
        task export nu-completion
        | from json
        | each {|task|
            let id = if ($task.id == 0) {$task.uuid} else {$task.id};
            {value: $id, description: $task.description}
        }
    }

    export def "nu-complete task reports" [] {
        task reports
        | from ssv -a -m 1
        | skip 1
        | drop 1
        | get Report;
    }

    export alias t = task

    # List tasks based on a pre-defined report, ignoring the report's columns
    export def tl [
        report = "list":string@"nu-complete task reports"  # The report from which the filter will be used
        search = "":string  #  Filters common text fields
    ] {
        task export $report 
        | from json
        | select id? project? description? due? status? entry? file? tags? urgency?
        | where project =~ $search or description =~ $search or status =~ $search
        | each { |task|
            let task = $task;
            {
                ID: $task.id,
                PROJECT: $task.project,
                TASK: $task.description,
                DUE: (if ($task.due != null) {$task.due | into datetime} else {null}),
                STATUS: ($task.status | str substring 0..3 | str upcase),
                ENTRY: ($task.entry | into datetime),
                NOTE: ($task.file != null),
                TAGS: ($task.tags | str join ' ')
            }
        }
    }

    # Take a note related to a task
    export def tn [
        id:string@"nu-complete tasks"  # The task ID/UUID
    ] {
        cd $notes_path;

        let file = task _get $"($id).file";
        let project = task _get $"($id).project";
        let name = (
            task _get $"($id).description"
            | split words
            | str join '-'
        );
        let path = (
            (if ($project != "") {$"($project)/"} else {""})
            + $name
            + ".md"
        );

        mkdir $project;

        if ($file == "") {
            task $id modify $"file:($path)";
            hx $path;
            return;
        }

        if ($file != $path and $file != "" and $path != "") {
            mv $file $path;
        }

        task $id modify $"file:($path)";
        hx $path;
    }

}
