{ pkgs, ... }:
{
  home.packages = [
    (pkgs.azure-cli.withExtensions [
      pkgs.azure-cli.extensions.ssh
      pkgs.azure-cli.extensions.azure-devops
    ])
  ];
}
