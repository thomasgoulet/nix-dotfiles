{
  description = "Home Manager configuration for Fedora / WSL";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  nixConfig = {

    extra-substituters = "https://nixpkgs-terraform.cachix.org";
    extra-trusted-public-keys = "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw=";

  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, ... }:
    let

      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ ]; };
      pkgs-stable = import nixpkgs-stable { inherit system; overlays = [ ]; };

    in {

      homeConfigurations."thomas" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit pkgs-stable; };
        modules = [ ./home.nix ];
      };

    };
}
