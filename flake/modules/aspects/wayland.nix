{ den, ... }:
{
  den.aspects.wayland = {

    nixos =
      { pkgs, ... }:
      {
        hardware.graphics.enable = true;

        programs.niri.enable = true;

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

          pkgs.xwayland-satellite
        ];

      };

  };
}
