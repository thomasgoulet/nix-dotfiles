{ den, inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  den.default.includes = [
    den.batteries.inputs' # injects inputs' into all nixos/homeManager modules
    den.batteries.self' # injects self' (flake packages) into all modules
  ];

  den.hosts.x86_64-linux.oric = {
    isWSL = true;
    users.thomas = {
      classes = [ "homeManager" "user" ];
    };
  };

  den.aspects.oric = {
    nixos =
      { host, ... }:
      {
        imports = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ./oric/wsl.nix
          ./oric/docker.nix
          ./oric/nix-settings.nix
        ];

        environment.variables = {
          NH_FLAKE = "/home/thomas/.config/flake";
          NH_HOST = host.name;
        };

        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
      };
  };
}
