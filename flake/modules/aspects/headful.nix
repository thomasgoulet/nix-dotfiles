{ den, inputs, ... }:
{
  den.aspects.headful = {

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.niri.nixosModules.niri
        ];

        hardware.graphics.enable = true;
        security.polkit.enable = true;

        programs.niri = {
          enable = true;
          package = inputs.niri.packages.${pkgs.system}.niri-unstable;
        };

        services.displayManager.noctalia-greeter = {
          enable = true;
          settings = {
            cursor.size = 24;
            keyboard.layout = "us";
          };
          cursorTheme = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
          };
        };

        environment.sessionVariables = {
          NIXOS_OZONE_WL = 1;
        };

        environment.systemPackages = [
          # TODO Remove these once config is improved
          pkgs.alacritty

          pkgs.bibata-cursors
          pkgs.noctalia
          pkgs.xwayland-satellite

          inputs.zen-browser.packages.${pkgs.system}.default
        ];

      };

    homeManager =
      { pkgs, ... }:
      let
        spicetify-pkg = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        spicetify-module = inputs.spicetify-nix.homeManagerModules.spicetify;
      in
      {
        imports = [
          (inputs.import-tree ./_headful)
          spicetify-module
        ];

        programs.spicetify = {
          enable = true;
          theme = spicetify-pkg.themes.catppuccin;
          colorScheme = "mocha";
          wayland = true;
        };
      };
  };
}
