module az {

    def "nu-complete azurecli subscriptions" [] {
        cache hit az.subscriptions 60 {
            az account list
            | from json
            | get name
            | each {|x| "\"" + $x + "\""}
        };
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
        let matches = (
            az account list
            | from json
            | where name =~ $subscription
        );

        if (($matches | length) == 0) {
            error make -u { msg: "No matching subscription." };
        } else if (($matches | length) == 1) {
            let match = (
                $matches
                | get 0
                | get name
                | to text
            );
            print $"Switching to subscription ($match)";
            az account set -s $match;
        } else {
            let match = (
                $matches
                | get name
                | input list -f
            );
            print $"Switching to subscription ($match)";
            az account set -s $match;
        }
    }
}
