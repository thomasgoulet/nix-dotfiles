module kubernetes {

    ### Aliases

    export alias kube = kubectl;

    ### Utility

    def argparse [
        context: string  # Context string passed to completer function
    ] {
        mut args = (
            $context
            | split row ' '
        );

        mut flags = [];

        let namespace_position = (
            $args
            | iter find-index {|s|
                $s == "-n" or $s == "--namespace"
            }
        );

        if ($namespace_position != -1) {
            $flags = [
                "-n"
                ($args | get ($namespace_position + 1))
            ];
            $args = (
                $args
                | drop nth $namespace_position
                | drop nth $namespace_position
            );
        }

        let all_position = (
            $args
            | iter find-index {|s|
                $s == "-A" or $s == "-a" or $s == "--all"
            }
        );

        if ($all_position != -1) {
            $flags = ["-A"];
            $args = (
                $args
                | drop nth $all_position
            )
        }

        return {command: ($args.0), args: ($args | skip 1), flags: $flags, flag_id: ($flags | str join ".")}
    }

    ### Completions

    def "nu-complete kubectl contexts" [] {
        cache hit kube.contexts 60 {
            kubectl config get-contexts
            | from ssv -a
            | iter filter-map {|c|
                {value: ($c.NAME), description: $"($c.CLUSTER | fill -w 15) namespace ($c.NAMESPACE | fill -w 15)"}
            }
        };
    }

    def "nu-complete kubectl namespaces" [] {
        cache hit kube.namespaces 60 {
            kubectl get namespaces
            | from ssv
            | where NAME != "default"
            | get NAME
            | prepend NONE
        };
    }

    def "nu-complete kubectl kinds" [] {
        cache hit kube.kinds 60 {
            kubectl api-resources
            | from ssv
            | select SHORTNAMES NAME
            | insert len { $in.NAME | str length }
            | sort-by len
            | get NAME SHORTNAMES
            | flatten
            | uniq
        };
    }

    def "nu-complete kubectl kind instances" [
        context: string
    ] {
        let ctx = argparse $context
        cache hit $"kube.kind.($ctx.args.0).($ctx.flag_id)" 15 {
            kubectl get $ctx.args.0 ...$ctx.flags
            | from ssv
            | get NAME
        };
    }

    # Completes the possible paths for kgp
    def "nu-complete kubectl kind instance paths" [
        context: string
    ] {
        let ctx = argparse $context
        let kind = $ctx.args.0;
        let instance = $ctx.args.1;

        let current_path = (
            $ctx.args
            | skip 2
            | drop 1
        );
        let cell_path = (
            $current_path
            | each {|in| let $i = $in; try {$i | into int} catch {$i} }
            | into cell-path
        );

        let resource = cache hit $"kube.($kind).($instance)" 30 {
            kubectl get $kind $instance ...$ctx.flags -o yaml | from yaml
        };
        let yaml = (
            $resource
            | get $cell_path
        );

        if ($yaml | describe | str starts-with record) {
            return (
                $yaml
                | columns
                | each {|in| let i = $in; { value: $i, description: ($yaml | get $i | to text) } }
            );
        }
        if ($yaml | describe | str starts-with table) {
            return (
                0..(($yaml | length) - 1)
                | each {|in| let i = $in; {value: ($i | into string), description: ($yaml | get ($i | into cell-path) | to text)}}
            );
        }
    }

    def "nu-complete kubectl shell" [] {
        cache hit kube.restartable 15 {
            kubectl get pods -o wide
            | from ssv -a
            | select NAME NODE
            | rename value description
            | append (
                kubectl get nodes -o wide
                | from ssv -a
                | select NAME INTERNAL-IP
                | rename value description
            )
        };
    }

    ### Exported Functions

    # With https://github.com/keisku/kubectl-explore renamed to kubectl-explain
    export alias kex = kubectl-explain;

    # Powered-up kubectl
    export def k [
        kind: string@"nu-complete kubectl kinds"  # Kind
        name?: string@"nu-complete kubectl kind instances"  # Name
        ...property: any@"nu-complete kubectl kind instance paths"  # Path to filter
        --namespace (-n): string@"nu-complete kubectl namespaces"  # Namespace to list resources in
        --all (-a)  # Search in all namespaces
        --delete (-D)  # Delete a resource
        --edit (-e)  # Edit a resource
        --get (-g)  # Get a resource's full definition
        --logs (-l)  # Get the logs of a pod
        --logs-previous (-L)  # Get the logs of the previous pod
        --port_forward (-p): int  # Port-forward the resource's port to localhost
        --restart (-r)  # Restart the resources's pods
    ] {

        mut flags = (
            if $all {["-A"]} else if ($namespace != null) {["-n" $namespace]} else {[]}
        );

        # These can only execute if a name is specified
        if ($name != null) {

            # Restart a resource
            if ($restart) {
                return (kubectl rollout restart $"($kind)/($name)" ...$flags);
            }

            # Port-forward a resource
            if ($port_forward != null) {
                if ($kind in [po pod pods]) {
                    kubectl port-forward $name $"($port_forward):($port_forward)" ...$flags;
                } else {
                    kubectl port-forward $"($kind)/($name)" $"($port_forward):($port_forward)" ...$flags;
                }
                return;
            }

            # Outputs the logs for a resource
            if ($logs or $logs_previous) {
                if ($logs_previous) {
                    $flags = ['-p'] | append $flags;
                }


                if ($kind in [po pod pods]) {
                    kubectl logs $name ...$flags | bat;
                } else {
                    kubectl logs $"($kind)/($name)" ...$flags | bat;
                }
                return;
            }

            # Deletes a resource
            if ($delete) {
                return (kubectl delete $kind $name ...$flags);
            }

        }

        # Edit a resource or a list of resource
        if ($edit) {
            if ($name == null) {
                kubectl edit $kind ...$flags;
            } else {
                kubectl edit $kind $name ...$flags;
            }
            return;
        }

        # Get the full YAML of a list or resource
        if ($get or $property != []) {
            let yaml = (
                if ($name != null) {
                    kubectl get $kind $name ...$flags -o yaml
                    | from yaml;
                } else {
                    kubectl get $kind ...$flags -o yaml
                    | from yaml
                    | get items;
                }
            );
            try {
                let output = (
                    $yaml
                    | get ($property | into cell-path)
                );
                return $output;
            } catch {
                return "Path was not valid for the resource";
            }
        }

        # List the resources
        mut $output = (
            kubectl get $kind ...$flags
            | from ssv
        );

        if ($name == null) {
            return $output
        }

        return (
            $output
            | where NAME =~ $name
        );

    }

    # List and change context
    export def kcon [
        context: string@"nu-complete kubectl contexts"  # Context (fuzzy)
        namespace?: string@"nu-complete kubectl namespaces"  # Namespace
    ] {
        cache invalidate

        mut match = [];
        $match = (
            kubectl config get-contexts
            | from ssv -a
            | where NAME == $context
        );
        if ($match == []) {
            $match = (
                kubectl config get-contexts
                | from ssv -a
                | where NAME =~ $context
            );
        }

        if (($match | length) != 1) {
            return "No or multiple matching contexts";
        } else {
            $match = (
                $match
                | first
            );
        }

        kubectl config use-context ($match | get NAME | to text) o+e> (null-device);

        if ($namespace != null) {
            kubectl config set-context ($match | get NAME | to text) --namespace $namespace o+e> (null-device);
        }

        return null;
    }

    # Exec into a pod or a node
    export def ksh [
        name: string@"nu-complete kubectl shell"  # Name of node or pod to exec into
        shell = "/bin/bash"  # Process to launch (when specifying a pod)
        --new (-n)  # Start a new pod with the specified name using an alpine image
    ] {
        if ($new) {
            kubectl run $name --rm -it --image=alpine -- sh;
            return;
        }

        let pods = (
            kubectl get pods
            | from ssv -a
            | get NAME
        );
        if ($name in $pods) {
            kubectl exec --stdin --tty $name -- $shell;
            return;
        }

        try {
            let nodes = (
                kubectl get nodes
                | from ssv -a
                | get NAME
            );
            if ($name in $nodes) {
                kubectl node_shell $name;
                return;
            }
        }
        return $"No resource called ($name). Specify '-n' to launch a new pod with that name"
    }
}
