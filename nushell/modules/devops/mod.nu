use pull_request.nu *
use work_items.nu *

# This module defines the shell-facing API for Azure DevOps commands
export module mod {

    export def "backlog get" [
        id: string  # ID of the work item
        --hierarchy (-h)  # Show work item hierarchy
    ] {
        work-item-details $id (if ($hierarchy) { 3 } else { 0 });
    }

    export def "pr" [
        project: string  # Name of the DevOps project
        id?: string  # ID of the PR
    ] {
        if ($id == null) {
            return (pull-request-list-active $project);
        }
        pull-request-details $id;
    }

}
