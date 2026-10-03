# The two containers talk over the `excalidash` network, which docker does not
# create on its own, so it is created once before both units start.
{
  config,
  lib,
  ...
}:
{
  systemd.services.init-excalidash-network = {
    description = "Create the docker network shared by ExcaliDash containers";
    wants = lib.mkForce [ ];
    after = lib.mkForce [
      "docker.service"
      "docker.socket"
    ];
    requires = [ "docker.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    path = [ config.virtualisation.docker.package ];
    script = ''
      docker network inspect excalidash >/dev/null 2>&1 || docker network create excalidash
    '';
  };
}
