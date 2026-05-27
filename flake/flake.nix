{
  description = "configuration for nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/25.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    den.url = "github:denful/den";

    nu-mcp = {
      url = "github:ck3mp3r/nu-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, den, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        den.flakeModule
        ./modules/nixos/oric.nix
        ./modules/aspects/shell.nix
        ./modules/aspects/editor.nix
        ./modules/aspects/developer.nix
        ./modules/aspects/azure.nix
        ./modules/aspects/infra.nix
        ./modules/thomas.nix
      ];
    };
}
