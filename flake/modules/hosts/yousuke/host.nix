{
  config,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = [
    pkgs.cascadia-code
    pkgs.nh
  ];

  environment.variables = {
    NH_FLAKE = "/home/thom/.config/flake";
    NH_HOST = config.networking.hostName;
  };

  nix.settings.trusted-users = [
    "root"
    "thom"
  ];

  time.timeZone = "Canada/Eastern";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
}
