use pull_request.nu *
use work_items.nu *

# This module defines the shell-facing API for Azure DevOps commands
export module mod {

    export def get-project [] {
        git remote get-url origin
        | parse "git@{url}:v{version}/{org}/{project}/{repo}"
        | get project
        | str replace --all "%20" " "
        | first
    }

    def "nu-complete devops pr" [
        context: string
    ] {
        let project = (get-project);
        cache hit $"devops.pr.($project)" 120 {
            pull-request-list-active $project
            | select id title
            | rename value description
        };
    }

    export def "backlog" [
        id: string  # ID of the work item
        --hierarchy (-h)  # Show work item hierarchy
    ] {
        work-item-details $id (if ($hierarchy) { 3 } else { 0 });
    }

    export def "pr" [
        id?: string@"nu-complete devops pr"  # ID of the PR
    ] {
        if ($id == null) {
            return (pull-request-list-active (get-project));
        }
        pull-request-details $id;
    }

}
