{ den, ... }:
{
  den.aspects.privacy = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.searxng
        ];

        services.searx = {
          enable = true;
          settings = {
            server = {
              port = 8888;
              bind_address = "127.0.0.1";
            };
          };
        };
      };
  };
}
