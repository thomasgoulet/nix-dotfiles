{ inputs, withSystem, ... }:
{
  flake.nixosConfigurations = {

    oric = withSystem "x86_64-linux" ({ config, inputs', system, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs inputs';
          custom-bins = config.packages;
        };

        modules = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          # Split NixOS feature modules
          ./_host/wsl.nix
          ./_host/docker.nix
          ./_host/nix-settings.nix
          ./_host/users.nix

          {
            environment.variables = {
              NH_FLAKE = "/home/thomas/.config/flake";
              NH_HOST = "oric";
            };

            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;

            home-manager.extraSpecialArgs = {
              pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
              custom-bins = config.packages;
              nu-mcp = inputs'.nu-mcp.packages.default;
            };

            home-manager.users.thomas = { ... }: {
              imports = [ inputs.self.homes.thomas ];
            };
          }
        ];
      }
    );

  };
}
