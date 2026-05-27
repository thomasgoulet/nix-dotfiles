module argo {

    def "nu-complete argocd applications" [] {
        cache hit argo.apps 15 {
            argocd app list --grpc-web
            | from ssv -a
            | select NAME PATH
            | rename value description
        };
    }

    # List apps
    export def "argo apps" [] {
        let list = (
            argocd app list --grpc-web
            | from ssv -a
        );
        let kube_config = (
            open ~/.kube/config
            | from yaml
        );
        let kube_context = (
            $kube_config
            | get current-context
        );
        let kube_ns = (
            $kube_config
            | get contexts
            | where name == $kube_context
            | get context.namespace.0
        );
        return (
            $list
            | where NAMESPACE =~ $kube_ns
            | select NAME PROJECT STATUS HEALTH PATH
        );
    }

    # List and change context
    export def "argo con" [
        context?: string  # Context (fuzzy)
    ] {
        if ($context == null) {
            return (
                argocd ctx
                | from ssv -a
            );
        }
        let match = (
            argocd ctx
            | from ssv -a
            | where NAME =~ $context
        );

        if ($match | length) != 1 {
          error make -u { msg: "No matching context." };
        }
        argocd ctx ($match | get NAME | first);
    }

    # Login to a ArgoCD server
    export def "argo login" [
        url: string  # ArgoCD web url to login to
    ] {
        argocd login $url --sso;
    }

    # Diff applications quickly
    export def "argo diff" [
        app: string@"nu-complete argocd applications"
    ] {
        let apps = (
            argocd app list --grpc-web
            | from ssv -a
        );
        let app_match = (
            $apps
            | where NAME =~ $app
        );
        if ($app_match | length) == 0 {
            error make -u { msg: "No matching application." };
        }
        if (not (
            $app_match
            | get PATH
            | first
            | path exists
        )) {
            error make -u { msg: "No matching path for this application. Make sure you at the root of the right repository." };
        }
        argocd app diff --grpc-web ($app_match | get NAME | first) --local ($app_match | get PATH | first) --local-repo-root .;
    }

    # Sync applications quickly
    export def "argo sync" [
        app: string@"nu-complete argocd applications"
    ] {
        argocd app sync $app -o json | from json | get status.operationState;
    }
}
