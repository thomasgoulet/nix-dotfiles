{ pkgs, ... }:
{
  system.stateVersion = "25.11";

  wsl.useWindowsDriver = true;
  wsl.startMenuLaunchers = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nh
    wsl-open
  ];

  environment.variables = {
    BROWSER = "wsl-open"; # `sudo ln -s (which wsl-open | get path.0) /usr/local/bin/xdg-open` to make app requiring xdg-open work
  };
}
