# WSL specific settings. Everything shared with other hosts lives in
# ../defaults.nix.
{ config, pkgs, ... }:
{
  wsl = {
    useWindowsDriver = true;
    startMenuLaunchers = true;
    wslConf.automount.options = "metadata,noatime,uid=1000,gid=100";
  };

  environment.systemPackages = [
    pkgs.nh
    pkgs.wsl-open
  ];

  environment.variables = {
    BROWSER = "wsl-open";
    NH_FLAKE = "/home/thomas/.config/flake";
    NH_HOST = config.networking.hostName;
  };

  nix.settings.trusted-users = [
    "root"
    "thomas"
  ];
}
