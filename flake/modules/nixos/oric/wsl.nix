{ pkgs, ... }:
{
  system.stateVersion = "25.11";

  wsl.enable = true;
  wsl.defaultUser = "thomas";
  wsl.useWindowsDriver = true;
  wsl.startMenuLaunchers = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nh
    wsl-open
  ];
}
