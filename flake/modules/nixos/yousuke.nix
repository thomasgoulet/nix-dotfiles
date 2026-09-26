{ den, inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  den.default.includes = [
    den.batteries.inputs' # injects inputs' into all nixos/homeManager modules
    den.batteries.self' # injects self' (flake packages) into all modules
    den.batteries.hostname
  ];

  den.hosts.x86_64-linux.yousuke = {
    users.thom = {
      classes = [
        "homeManager"
        "user"
      ];
    };
  };

  den.aspects.yousuke = {

    includes = [
      den.aspects.niri
    ];

    nixos =
      {
        host,
        lib,
        modulesPath,
        pkgs,
        ...
      }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          (inputs.import-tree ./_yousuke)
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        system.stateVersion = "26.05";
        nixpkgs.config.allowUnfree = true;

        networking.hostName = "yousuke";

        nix = {
          gc = {
            automatic = true;
            persistent = true;
            dates = "Fri *-*-* 06:00:00";
            options = "--delete-older-than 7d";
          };
          settings = {
            auto-optimise-store = true;
            experimental-features = [
              "pipe-operators"
              "nix-command"
              "flakes"
            ];
            trusted-users = [
              "root"
              "thom"
            ];
          };
        };

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

        environment.systemPackages = [
          pkgs.cascadia-code
          pkgs.nh
        ];

        fonts = {
          enableDefaultPackages = true;
          packages = [
            pkgs.inter
            pkgs.lora
            pkgs.nerd-fonts.caskaydia-cove
          ];
          fontconfig = {
            enable = true;
            defaultFonts = {
              monospace = [ "CaskaydiaCove Nerd Font" ];
              sansSerif = [ "Inter" ];
              serif = [ "Lora" ];
            };
          };
        };

        environment.variables = {
          NH_FLAKE = "/home/thom/.config/flake";
          NH_HOST = host.name;
        };

        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;

        time.timeZone = "Canada/Eastern";
        i18n.defaultLocale = "en_US.UTF-8";

        services.displayManager.gdm.enable = true;
        services.xserver.xkb.options = "caps:escape";
        services.xserver.xkb.layout = "ca";
        console.useXkbConfig = true; # use xkb.options in tty.

        services.openssh.enable = true;
        services.upower.enable = true;
      };
  };
}
