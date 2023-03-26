{
  description = "Home Manager configuration for Fedora / WSL";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, home-manager, ... }:
    let

      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ ]; };

    in {

      homeConfigurations."thomas" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { };
        modules = [ ./home.nix ];
      };

    };
}
