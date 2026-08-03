def format-pull-requests []: string -> any {

    const pr_fields = {
        id: $.pullRequestId
        repo: $.repository.name
        created_by: $.createdBy.uniqueName
        title: $.title
        branch: $.sourceRefName
        date: $.creationDate
        description: $.description
        work_items: $.workItemRefs?.id?
    }

    $in
    | from json
    | select -o ...($pr_fields | values)
    | rename ...($pr_fields | columns)
}

export def format-comments []: string -> any {

    const comment_fields = {
        type: $.comments.commentType
        content: $.comments.content
        author: $.comments.author.uniqueName
        status: $.status
        date: $.publishedDate
        file: $.filePath
        start: $.rightFileStart
        end: $.rightFileEnd
    }

    $in
    | from json
    | get value
    | flatten
    | select -o ...($comment_fields | values)
    | rename ...($comment_fields | columns)
    | sort-by $.date
}

# Lists all active pull requests
export def pull-request-list-active [
    project: string  # DevOps project name
] {
    az repos pr list --project $project --status active -o json
    | format-pull-requests
}

# Lists all pull requests updated since a given date
export def pull-request-list-recently-updated [
    project: string  # DevOps project name
    date: datetime  # Will list pull request created or closed after this date
] {
    let date_string = $date | format date "%Y-%m-%d";
    let query = $"[?creationDate > '($date_string)' || closedDate > '($date_string)']"

    az repos pr list --project $project --status all --query $query -o json
    | format-pull-requests
}

# Get pull request details
export def pull-request-details [
    id: string  # ID of the pull request
    include_comments: bool = true  # Fetch and include comment threads
] {
    let pr = (az repos pr show --id $id -o json);

    if not $include_comments {
        return ($pr | format-pull-requests)
    }

    let project_param = $"project=($pr |from json | get repository.project.name)"
    let repository_param = $"repositoryId=($pr | from json | get repository.id)"
    let pr_param = $"pullRequestId=($id)"

    let comments = (az devops invoke --area git --resource pullRequestThreads --route-parameters $project_param $repository_param $pr_param --api-version 7.1)

    $pr
    | format-pull-requests
    | upsert comments ($comments | format-comments)
}
