{ ... }:
{
  flake.homes.thomas = { pkgs, ... }: {
    home.packages = with pkgs; [
      argocd
      dyff
      k9s
      kubectl
      kubelogin
      kustomize
      tenv
    ];
  };
}
