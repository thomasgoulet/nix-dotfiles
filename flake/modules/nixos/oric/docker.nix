{ ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings.userland-proxy = false;
  };
}
