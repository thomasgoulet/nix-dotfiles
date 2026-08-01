const HEADER_RE = "^((?<done>x)\\s)?(\\((?<priority>[A-C]{1})\\)\\s)?((?<completed_at>\\d{4}-\\d{2}-\\d{2})\\s)?((?<created_at>\\d{4}-\\d{2}-\\d{2})\\s)?(?<rest>.*)";
const PROJECTS_RE = "\\+[^\\s]*";
const CONTEXTS_RE = "\\@[^\\s]*";
const TAGS_RE = "(?<key>[^\\s]*):(?<value>[^\\s]*)";

# Parses a todo.txt file
export def "from todo" []: string -> any {
    $in | lines | each { |line|
        let header = ($line | parse --regex $HEADER_RE)
        let body = ($header | get rest | split row " ")

        let projects = ($body | find --no-highlight --regex $PROJECTS_RE)
        let contexts = ($body | find --no-highlight --regex $CONTEXTS_RE)
        let tags = ($body | find --no-highlight --regex $TAGS_RE)
        let tags_object = ($tags | parse --regex $TAGS_RE | reduce -f {} {|row, acc| $acc | upsert $row.key $row.value })

        let task = ($body | where {|word| ($word not-in $projects) and ($word not-in $contexts) and ($word not-in $tags)} | str join " ")

        {
            done: ($header | get -o done | $in != [null])
            priority: ($header | get priority | first)
            completed_at: ($header | get -o completed_at | first)
            created_at: ($header | get -o created_at | first)
            projects: ($projects | default -e null)
            contexts: ($contexts | default -e null)
            tags: ($tags_object | default -e null)
            task: $task
        }
    }
}

export def "to todo" []: any -> string {
    $in | each { |line|
        $line.task
        | prepend ($line.created_at?)
        | prepend ($line.completed_at?)
        | prepend (if ($line.priority | is-not-empty) { $"\(($line.priority)\)" } else { null })
        | prepend (if ($line.done) { "x" } else { null })
        | append ( $line.projects | default [""] | str join " ")
        | append ( $line.contexts | default [""] | str join " ")
        | append ( $line.tags | default {} | transpose | each { $"($in.column0):($in.column1)" })
        | str join " "
        | str replace -a -r "\\s+" " "
    } | to text
}
