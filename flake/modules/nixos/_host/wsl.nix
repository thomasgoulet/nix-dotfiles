{ inputs', ... }:
{
  system.stateVersion = "25.11";

  wsl.enable = true;
  wsl.defaultUser = "thomas";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with inputs'.nixpkgs.legacyPackages; [
    nh
    wsl-open
  ];


}
