module az {

    def "nu-complete azurecli subscriptions" [] {
        cache hit az.subscriptions 60 {
            az account list
            | from json
            | get name
            | each {|x| "\"" + $x + "\""}
        };
    }

    def "nu-complete azurecli pullrequests active" [] {
        pr list
        | rename --column {id: value}
        | upsert description {|pr| $"($pr.title) by ($pr.creator) \(($pr.branch)\)"}
    }

    def "nu-parse azurecli pullrequests" []: binary -> any {
        const pr_fields = {
            id: $.pullRequestId
            repo: $.repository.name
            creator: $.createdBy.displayName
            title: $.title
            branch: $.sourceRefName
            date: $.creationDate
            description: $.description
            workitems: $.workItemRefs?.id?
        }
        $in
        | from json
        | select -o ...($pr_fields | values)
        | rename ...($pr_fields | columns)
    }

    const queries = [
        {value: "sprint", id: "7cb19a8a-1035-431c-9507-749ed35cc69e"}
        {value: "client-requests", id: "7cb19a8a-1035-431c-9507-749ed35cc69e"}
    ];

    def "nu-complete azurecli board queries" [] {
        $queries
    }

    def "nu-parse azurecli workitems" []: binary -> any {
        const workitem_fields = {
            id: $.id
            title: $.fields."System.Title"
            created: $.fields."System.CreatedDate"
            type: $.fields."System.WorkItemType"
            state: $.fields."System.State"
            description: $.fields."System.Description"
            acceptancecriteria: $.fields."Microsoft.VSTS.Common.AcceptanceCriteria"
            iteration: $.fields."System.IterationPath"
            parent: $.fields."System.Parent"
            relations: $.relations
        };
        $in
        | from json
        | select -o ...($workitem_fields | values)
        | rename ...($workitem_fields | columns)
    }

    # Logs you into azure-cli after checking if your token is expired
    export def azl [
        --silent (-s)  # Silent version of the command
    ] {
        let status = (do -i { az account show } | complete);
        if $status.exit_code != 0 {
            az login;
        } else if (not $silent) {
            "Already logged in"
        }
    }

    # Changes your subscription for you
    export def azs [
        subscription: string@"nu-complete azurecli subscriptions"  # Subscription to switch to
    ] {
        az account set -s $subscription;
    }

    export def "backlog list" [
        query: string@"nu-complete azurecli board queries"
    ] {
        let query_id = (
            $queries
            | where value == $query
            | first
            | get id
        );
        az boards query --id $query_id
        | nu-parse azurecli workitems
        | reject description acceptancecriteria iteration
    }

    # Describes a specific work item
    export def "backlog get" [
        id: string
    ] {
        az boards work-item show --id $id
        | nu-parse azurecli workitems
        | upsert relations {|item|
            $item.relations
            | where {|relation| $relation.attributes.name? in [Child Parent]}
            | each {|relation|
                {
                    type: $relation.attributes.name
                    id: ($relation.url | split row "/" | last)
                }
            }
        }
    }

    # Lists all active PRs which are not automated
    export def "pr list" [] {
        return (
            az repos pr list --status active -o json
            | nu-parse azurecli pullrequests
            | reject description workitems
            | where creator !~ "Automation|Build|Project|Service"
        );
    }

    # Describes a specific PR
    export def "pr get" [
        id: string@"nu-complete azurecli pullrequests active"
    ] {
        return (
            az repos pr show --id $id -o json
            | nu-parse azurecli pullrequests
            | upsert workitems { |pr|
                $pr.workitems | each {|workitem| backlog get $workitem}
            }
        );
    }
}
