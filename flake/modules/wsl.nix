{ inputs, withSystem, ... }:
{
  flake.nixosConfigurations = {
    
    nixos = withSystem "x86_64-linux" ({ config, inputs', system, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        
        specialArgs = {
          inherit inputs;
          custom-bins = config.packages;
        };
        
        modules = [
          inputs.nixos-wsl.nixosModules.default
          
          # WSL & OS Configuration
          {
            system.stateVersion = "25.11";
            
            wsl.enable = true;
            wsl.defaultUser = "thomas";

            wsl.wslConf = {
              wsl2.networkingMode = "mirrored";
            };
            
            # Allow unfree packages globally
            nixpkgs.config.allowUnfree = true;
            
            users.users.thomas = {
              shell = inputs'.nixpkgs.legacyPackages.nushell;
            };
            
            nix.settings = {
              auto-optimise-store = true;
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "root" "thomas" ];
            };
            
            environment.systemPackages = with inputs'.nixpkgs.legacyPackages; [
              nh
              wsl-open
            ];
            
            # nh looks at this variable to determine the flake location
            environment.variables = {
              NH_FLAKE = "/home/thomas/.config/flake";
            };
          }
          
          # Home-Manager Configuration
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            
            home-manager.extraSpecialArgs = { 
              pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
              custom-bins = config.packages;
            };
            
            # Import the home-manager module from the flake
            home-manager.users.thomas = { pkgs, ... }: {
              imports = [ inputs.self.homes.thomas ];
            };
          }
        ];
      }
    );
    
  };
}
