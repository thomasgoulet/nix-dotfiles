# Settings shared by every host and user.
#
# `den.default` is applied to all entity kinds (hosts, users, homes), so
# anything here lands on both machines. Host-specific or user-specific settings
# belong in `aspects/hosts/` and `aspects/users/` instead.
{
  den,
  ...
}:
{
  systems = [ "x86_64-linux" ];

  den.default = {
    includes = [
      den.batteries.define-user
      den.batteries.hostname
      den.batteries.inputs'
      den.batteries.self'
    ];

    nixos =
      { ... }:
      {
        system.stateVersion = "26.05";

        nix.gc = {
          automatic = true;
          persistent = true;
          dates = "Fri *-*-* 06:00:00";
          options = "--delete-older-than 7d";
        };

        nix.settings = {
          auto-optimise-store = true;
          experimental-features = [
            "pipe-operators"
            "nix-command"
            "flakes"
          ];
        };

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
        };
      };

    homeManager =
      { ... }:
      {
        home.stateVersion = "26.05";
      };
  };
}
