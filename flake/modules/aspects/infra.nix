{ den, ... }:
{
  den.aspects.infra = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.argocd
        pkgs.dyff
        pkgs.hl-log-viewer
        pkgs.k9s
        pkgs.kubectl
        pkgs.kubelogin
        pkgs.kustomize
        pkgs.tenv
      ];
    };
  };
}
