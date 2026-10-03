{
  den,
  inputs,
  ...
}:
{
  den.aspects.infra = {

    includes = [
      (den.batteries.unfree [ "azure-cli" ])
    ];

    homeManager =
      { pkgs, ... }:
      {
        imports = [
          (inputs.import-tree ./infra)
        ];

        home.packages = [
          pkgs.argocd
          pkgs.dyff
          pkgs.hl-log-viewer
          pkgs.kubecolor
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
