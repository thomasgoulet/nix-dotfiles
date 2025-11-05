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

    def "recursive-paths" [
        resource: any,
        prefix = ""
    ] {
        let prefix_with_dot = if ($prefix | is-empty) { $prefix } else { $prefix + "." }

        if ($resource | describe | str starts-with record) {
            return (
                $resource
                | columns
                | each { |inside| let i = $inside; recursive-paths ($resource | get $i) $"($prefix_with_dot)($i)" }
                | flatten
                | prepend { value: $prefix, description: ($resource | to json) }
            );
        } else if ($resource | describe | str starts-with table) or ($resource | describe | str starts-with list) {
            return (
                0..(($resource | length) - 1)
                | each { |inside| let i = $inside; recursive-paths ($resource | get ($i | into cell-path)) $"($prefix_with_dot)($i)" }
                | flatten
                | prepend { value: $prefix, description: ($resource | to json) }
            );
        }

        return { value: $prefix, description: $resource }
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

    # Completes the possible paths for k
    export def "nu-complete kubectl kind instance paths" [
        context: string
    ] {
        let ctx = argparse $context
        let kind = $ctx.args.0;
        let instance = $ctx.args.1;

        let resource = cache hit $"kube.($kind).($instance)" 30 {
            kubectl get $kind $instance ...$ctx.flags -o yaml | from yaml
        };

        return (
            recursive-paths $resource
        );
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
        instance?: string@"nu-complete kubectl kind instances"  # Name
        path?: string@"nu-complete kubectl kind instance paths"  # Path to filter
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

        let namespace_flags = (
            if $all { ["-A"] } else if ($namespace != null) { ["-n", $namespace] } else { [] }
        );

        # These can only execute if a name is specified
        if ($instance != null) {

            # Restart a resource
            if ($restart) {
                return (kubectl rollout restart $"($kind)/($instance)" ...$namespace_flags);
            }

            # Port-forward a resource
            if ($port_forward != null) {
                if ($kind in [po pod pods]) {
                    kubectl port-forward $instance $"($port_forward):($port_forward)" ...$namespace_flags;
                } else {
                    kubectl port-forward $"($kind)/($instance)" $"($port_forward):($port_forward)" ...$namespace_flags;
                }
                return;
            }

            # Outputs the logs for a resource
            if ($logs or $logs_previous) {
                let log_flags = if $logs_previous { ['-p'] | append $namespace_flags } else { $namespace_flags }

                if ($kind in [po pod pods]) {
                    kubectl logs $instance ...$log_flags | bat;
                } else {
                    kubectl logs $"($kind)/($instance)" ...$log_flags | bat;
                }
                return;
            }

            # Deletes a resource
            if ($delete) {
                return (kubectl delete $kind $instance ...$namespace_flags);
            }

        }

        # Edit a resource or a list of resource
        if ($edit) {
            if ($instance == null) {
                kubectl edit $kind ...$namespace_flags;
            } else {
                kubectl edit $kind $instance ...$namespace_flags;
            }
            return;
        }

        # Get the full definition
        if ($get) {
            return (
                if ($instance != null) {
                    cache hit $"kube.($kind).($instance)" 30 {
                        kubectl get $kind $instance ...$namespace_flags -o yaml
                        | from yaml
                    };
                } else {
                    cache hit $"kube.items.($kind)" 30 {
                        kubectl get $kind ...$namespace_flags -o yaml
                        | from yaml
                        | get items
                    };
                }
            );
        }

        if ($path | is-not-empty) {
            return (
                cache hit $"kube.($kind).($instance)" 30 {
                    kubectl get $kind $instance ...$namespace_flags -o yaml
                    | from yaml
                }
                | get (
                    $path
                    | split row '.'
                    | each { |in| let i = $in; try {$i | into int} catch {$i} }
                    | into cell-path
                )
            );
        }

        # List the resources
        let output = (
            kubectl get $kind ...$namespace_flags
            | from ssv
        );

        if ($instance == null) {
            return $output
        }

        return (
            $output
            | where NAME =~ $instance
        );

    }

    # List and change context
    export def kc [
        context: string@"nu-complete kubectl contexts"  # Context (fuzzy)
        namespace?: string@"nu-complete kubectl namespaces"  # Namespace
    ] {
        cache invalidate

        let contexts = (kubectl config get-contexts | from ssv -a)
        mut match = ($contexts | where NAME == $context)
        if ($match | is-empty) {
            $match = ($contexts | where NAME =~ $context)
        }

        if ($match | length) == 0 {
            error make -u { msg: "No matching context found." }
        } else if ($match | length) > 1 {
            let names = ($match | get NAME | str join ", ")
            error make -u { msg: $"Multiple contexts found: ($names)." }
        }

        let final_context = ($match | first | get NAME | to text)
        kubectl config use-context $final_context o+e> (null-device);

        if ($namespace != null) {
            kubectl config set-context $final_context --namespace $namespace o+e> (null-device);
        }

        return null;
    }

    # Open a floating k9s pane
    export def kt [
        context?: string@"nu-complete kubectl contexts"  # Context (fuzzy)
        namespace?: string@"nu-complete kubectl namespaces"  # Namespace
    ] {

        if ($context == null) {
            zellij run -f -c -n "k9s" -- k9s -c pods;
            return;
        }

        let contexts = (kubectl config get-contexts | from ssv -a)
        mut match = ($contexts | where NAME == $context)
        if ($match | is-empty) {
            $match = ($contexts | where NAME =~ $context)
        }

        if ($match | length) == 0 {
            error make -u { msg: "No matching context found." }
        } else if ($match | length) > 1 {
            let names = ($match | get NAME | str join ", ")
            error make -u { msg: $"Multiple contexts found: ($names)." }
        }

        let final_context = ($match | first | get NAME | to text)

        if ($namespace == null) {
            zellij run -f -c -n $"k9s ($context)" -- k9s --context $context -c pods;
            return;
        }

        zellij run -f -c -n $"k9s ($context) ($namespace)" -- k9s --context $context --namespace $namespace -c pods;

        return;
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
        error make -u { msg: $"No resource called ($name). Specify '-n' to launch a new pod with that name." }
    }
}
