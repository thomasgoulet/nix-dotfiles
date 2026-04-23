{
  description = "Configuration for NixOs / WSL";

   inputs = {
     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
     nixpkgs-stable.url = "github:nixos/nixpkgs/25.11";

     nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
     flake-parts.url = "github:hercules-ci/flake-parts";
     home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
     };

     backlog-md = {
       url = "github:MrLesk/Backlog.md";
       inputs.nixpkgs.follows = "nixpkgs";
     };

     nu-mcp = {
       url = "github:ck3mp3r/nu-mcp";
       inputs.nixpkgs.follows = "nixpkgs";
     };

   };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      # Import all module files
      imports = [
        ./modules/custom-bins.nix
        ./modules/shells.nix
        ./modules/packages.nix
        ./modules/wsl.nix
      ];

    };
}
