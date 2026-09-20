{ den, inputs, ... }:
{
  den.aspects.niri = {

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.niri.nixosModules.niri
        ];

        hardware.graphics.enable = true;

        programs.niri = {
          enable = true;
          package = inputs.niri.packages.${pkgs.system}.niri-unstable;
        };

        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-gtk
          ];
        };

        security.polkit.enable = true;

        environment.sessionVariables = {
          NIXOS_OZONE_WL = 1;
        };

        environment.systemPackages = [
          # TODO Remove these once config is improved
          pkgs.alacritty
          pkgs.firefox

          pkgs.fuzzel

          pkgs.noctalia-shell
          pkgs.xwayland-satellite
        ];

      };

    homeManager = {
      programs.niri.config = builtins.readFile ./_niri/config.kdl;
    };

  };
}
