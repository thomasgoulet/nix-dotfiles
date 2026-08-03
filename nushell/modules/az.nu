use ../tools/devops/pull_request.nu *

module az {

    export def "nu-complete azurecli subscriptions" [] {
        cache hit az.subscriptions 60 {
            az account list
            | from json
            | select name id
            | update name {"\"" + $in + "\""}
            | rename value description
        };
    }

    # Changes your subscription for you
    export def "az subscription" [
        subscription: string@"nu-complete azurecli subscriptions"  # Subscription to switch to
    ] {
        az account set -s $subscription;
    }

    export def "az pr list" [
        project: string  # DevOps project to list PR for
    ] {
        pull-request-list-active $project
    }
}
