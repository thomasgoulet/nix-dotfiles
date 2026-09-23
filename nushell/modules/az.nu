export module mod {

    def "nu-complete azurecli subscriptions" [] {
        cache hit az.subscriptions 60 {
            az account list
            | from json
            | select name id
            | update name {"\"" + $in + "\""}
            | rename value description
        };
    }

    # Changes azure-cli subscription
    export def sub [
        subscription: string@"nu-complete azurecli subscriptions"  # Subscription to switch to
    ] {
        az account set -s $subscription;
    }
}
