{ den, ... }:
{
  den.aspects.infra = {

    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.argocd
        pkgs.argonaut
        pkgs.dyff
        pkgs.hl-log-viewer
        pkgs.k9s
        pkgs.kubectl
        pkgs.kubelogin
        pkgs.kustomize
        pkgs.tenv

        (pkgs.azure-cli.withExtensions [
          pkgs.azure-cli.extensions.ssh
          pkgs.azure-cli.extensions.azure-devops
        ])
      ];

      home.sessionVariables = {
        KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code";
      };
    };
  };
}
