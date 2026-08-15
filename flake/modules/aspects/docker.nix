{ den, ... }:
{
  den.aspects.docker = {

    nixos = {
      virtualisation.oci-containers.backend = "docker";
      virtualisation.docker = {
        enable = true;
        daemon.settings.userland-proxy = false;
      };
    };

    user = { extraGroups = [ "docker" ]; };

  };
}
