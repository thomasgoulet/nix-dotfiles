{ den, ... }:
{
  den.aspects.docker = {

    user = { extraGroups = [ "docker" ]; };

    nixos = {
      virtualisation.oci-containers.backend = "docker";
      virtualisation.docker = {
        enable = true;
        daemon.settings.userland-proxy = false;
      };
    };

  };
}
