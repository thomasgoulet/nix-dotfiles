{ pkgs, ... }:
{
  home.packages = with pkgs; [
    argocd
    dyff
    hl-log-viewer
    k9s
    kubectl
    kubelogin
    kustomize
    tenv
  ];
}
