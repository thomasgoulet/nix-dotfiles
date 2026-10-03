# ExcaliDash containers.
{
  pkgs,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    excalidash-backend = {
      image = "zimengxiong/excalidash-backend@sha256:f37cd418bcad543add138c16cdb5e6301c3065b77344125458ab462adde99f15";
      environment = {
        DATABASE_URL = "file:/app/prisma/dev.db";
        PORT = "6768";
        NODE_ENV = "production";
        AUTH_MODE = "local";
        TRUST_PROXY = "false";
        FRONTEND_URL = "http://localhost:6767,http://0.0.0.0:6767";
      };
      volumes = [ "/var/lib/excalidash:/app/prisma" ];
      extraOptions = [
        "--network=excalidash"
        "--network-alias=backend"
      ];
    };
    excalidash-frontend = {
      image = "zimengxiong/excalidash-frontend@sha256:de12bee592b2db0bcdee1b7066283297696a3e9e3a309798f78ca6c9d6caff9c";
      environment = {
        BACKEND_URL = "backend:6768";
      };
      ports = [ "6767:80" ];
      dependsOn = [ "excalidash-backend" ];
      extraOptions = [ "--network=excalidash" ];
    };
  };
}
