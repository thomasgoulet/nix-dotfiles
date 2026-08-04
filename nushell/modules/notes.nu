use ../tools/tasks/todo_format.nu *

module notes {

    export alias n = zk;
    export alias t = tuxedo;
    export alias notebook = zellij action new-tab --cwd $env.ZK_NOTEBOOK_DIR -n notebook;

    export def "t edit" [] {
        let task_lines = (
            open $env.TODO_FILE
            | from todo
            | each {|line|
                (ansi yellow_bold) + ($line.task) + (ansi reset) + (char tab) + (ansi grey) + ( $line | to todo | str replace ($line.task + ' ') "" ) + (ansi reset)
            }
            | to text
        );

        let picked = (
             $task_lines
            | fzf --delimiter (char tab) --ansi --nth 1 --accept-nth 1 --layout reverse --height 100%
        );

        let existing_note = (
            zk list -f json
            | from json
            | where title == $picked
            | first
        );

        if ($existing_note | is-not-empty) {
            zk edit $existing_note.path;
        } else {
            zk new tasks -t $picked;
        }
    }
}
