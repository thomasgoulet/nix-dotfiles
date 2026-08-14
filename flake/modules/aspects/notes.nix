{ den, ... }:
{
  den.aspects.notes = { ... }: {

    includes = [
      den.aspects.terminal
      den.aspects.helix
    ];

    homeManager =
      { config, lib, pkgs, ... }:
      let
        zk = pkgs.buildGoModule {
          pname = "zk";
          version = "0.15.6";
          src = pkgs.fetchFromGitHub {
            owner = "zk-org";
            repo = "zk";
            rev = "v0.15.6";
            hash = "sha256-owHbrQwoQS+SbfZ6EQO/ii10zX73MmUpohuIIltlnw8=";
          };
          vendorHash = "sha256-Y5KI3o4HYWyqQl/RnOetyIKOI+CbYWSgrbkGkpAKsX4=";
          doCheck = false;
          env.CGO_ENABLED = 1;
          tags = [ "fts5" ];
          ldflags = [
            "-s" "-w"
            "-X=main.Build=unstable"
            "-X=main.Version=unstable"
          ];
        };
      in
      {
        config.helix.notes.enable = true;

        config = {
          home.packages = [
            pkgs.tuxedo
            zk
          ];

          home.sessionVariables = {
            TODO_DIR = "${config.home.homeDirectory}/notebook";
            TODO_FILE = "${config.home.homeDirectory}/notebook/tasks.txt";
            ZK_NOTEBOOK_DIR = "${config.home.homeDirectory}/notebook";
            ZK_SHELL = "/bin/bash";
          };
        };

      };

    nixos = { config, ... }:
      {
        virtualisation.oci-containers.backend = "docker";

        systemd.services.init-excalidash-network = {
          description = "Create the docker network shared by ExcaliDash containers";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          path = [ config.virtualisation.docker.package ];
          script = ''
            docker network inspect excalidash >/dev/null 2>&1 || docker network create excalidash
          '';
        };

        systemd.services.docker-excalidash-backend = {
          after = [ "init-excalidash-network.service" ];
          requires = [ "init-excalidash-network.service" ];
        };
        systemd.services.docker-excalidash-frontend = {
          after = [ "init-excalidash-network.service" ];
          requires = [ "init-excalidash-network.service" ];
        };

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
            extraOptions = [ "--network=excalidash" "--network-alias=backend" ];
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
      };
  };
}
