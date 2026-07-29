
use utils.nu *

use pull_request.nu *
use work_items.nu *

def main [] {
    help main
}

def "main list-tools" [] {
    [
        {
            name: "list_active_prs"
            description: "Lists all active pull requests"
            input_schema: {
                type: "object"
                properties: {
                    projectName: {
                        type: "string"
                        description: "Name of the DevOps project to list PRs for."
                    }
                }
                required: ["projectName"]
                additionalProperties: false
            }
        }
        {
            name: "list_recent_prs"
            description: "Lists all recently created or closed pull requests"
            input_schema: {
                type: "object"
                properties: {
                    projectName: {
                        type: "string"
                        description: "Name of the DevOps project to list PRs for."
                    }
                    date: {
                        type: "string"
                        description: "Refines the query for pull requests created or closed after a certain date. The format is `YYYY-mm-dd`. Defaults to last business day"
                        pattern: "^\\d{4}-\\d{2}-\\d{2}$"
                        examples: ["2024-01-01"]
                    }
                }
                required: ["projectName"]
                additionalProperties: false
            }
        }
        {
            name: "get_pull_request"
            description: "Gets a pull request from its ID. Includes information about the comments"
            input_schema: {
                type: "object"
                properties: {
                    pullRequestId: {
                        type: "string"
                        description: "ID of the pull request. The format is a string of numbers with no preceding characters"
                        pattern: "^\\d+$"
                    }
                    includeComments: {
                        type: "boolean"
                        description: "Whether to include the pull request's comments in the result."
                        default: true
                    }
                }
                required: ["pullRequestId"]
                additionalProperties: false
            }
        }
        {
            name: "get_work_item"
            description: "Gets a work item from its ID. Does not include information about related items."
            input_schema: {
                type: "object"
                properties: {
                    workItemId: {
                        type: "string"
                        description: "ID of the work item. The format is a string of numbers with no preceding characters"
                        pattern: "^\\d+$"
                    }
                }
                required: ["workItemId"]
                additionalProperties: false
            }
        }
        {
            name: "get_work_item_with_context"
            description: "Gets a work item from its ID. Resolves all parents and child items including their description. Is used to provide full context surrounding a work item. Prefer `get_work_item` unless the context is required."
            input_schema: {
                type: "object"
                properties: {
                    workItemId: {
                        type: "string"
                        description: "ID of the work item. The format is a string of numbers with no preceding characters"
                        pattern: "^\\d+$"
                    }
                }
                required: ["workItemId"]
                additionalProperties: false
            }
        }
    ] | to json
}

def "main call-tool" [
    tool_name: string  # Name of the tool to call
    args: string = "{}"  # Arguments for the tool in JSON format
] {

    let parsed_args = $args | from json
    match $tool_name {
        "list_active_prs" => {
            list-active-pull-requests ($parsed_args | get projectName) | to json
        }
        "list_recent_prs" => {
            list-recent-pull-requests ($parsed_args | get projectName) ($parsed_args | get -o date) | to json
        }
        "get_pull_request" => {
            get-pull-request ($parsed_args | get pullRequestId) ($parsed_args | get -o includeComments | default true) | to json
        }
        "get_work_item" => {
            get-work-item ($parsed_args | get workItemId) | to json
        }
        "get_work_item_with_context" => {
            get-work-item-with-context ($parsed_args | get workItemId) | to json
        }
        _ => {
            error make {msg: $"Unknown tool: ($tool_name)"}
        }
    }
}

def list-active-pull-requests [
    project_name: string
] {
    pull-request-list-active $project_name
}

def list-recent-pull-requests [
    project_name: string
    date?: string
] {
    let parsed_date = parse-date-or-last-business-day $date;
    pull-request-list-recently-updated $project_name $parsed_date
}

def get-pull-request [
    id: string
    include_comments: bool = true
] {
    pull-request-details $id $include_comments
}

def get-work-item [
    id: string
] {
    work-item-details $id
}

def get-work-item-with-context [
    id: string
] {
    work-item-details $id 3
}

export def team-activity [
    users: list<string>
    project_names: list<string>
    date?: string
] {
    let parsed_date = parse-date-or-last-business-day $date;
    
    let work_items = (
        $project_names
        | each {|project| work-item-list-recent $project $parsed_date}
        | flatten
    ) | where createdby in $users or changedby in $users
    let pull_requests = (
        $project_names
        | each {|project| pull-request-list-recently-updated $project $parsed_date}
        | flatten
    ) | where createdby in $users;

    {
        pullrequests: $pull_requests
        workitems: $work_items
    }
}
