{ den, inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  den.default.includes = [
    den.batteries.inputs' # injects inputs' into all nixos/homeManager modules
    den.batteries.self' # injects self' (flake packages) into all modules
    den.batteries.hostname
  ];

  den.hosts.x86_64-linux.oric = {
    wsl.enable = true;
    users.thomas = {
      classes = [ "homeManager" "user" ];
    };
  };

  den.aspects.oric = {
    nixos =
      { host, pkgs, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];

        system.stateVersion = "25.11";
        nixpkgs.config.allowUnfree = true;

        nix.settings = {
          auto-optimise-store = true;
          experimental-features = [ "pipe-operators" "nix-command" "flakes" ];
          trusted-users = [ "root" "thomas" ];
        };

        nix.gc = {
          automatic = true;
          persistent = true;
          dates = "Fri *-*-* 06:00:00";
          options = "--delete-older-than 7d";
        };

        environment.systemPackages = [
          pkgs.nh
          pkgs.wsl-open
        ];

        environment.variables = {
          BROWSER = "wsl-open";
          NH_FLAKE = "/home/thomas/.config/flake";
          NH_HOST = host.name;
        };

        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;

        wsl.useWindowsDriver = true;
        wsl.startMenuLaunchers = true;
      };
  };
}
