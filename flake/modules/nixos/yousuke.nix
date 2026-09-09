{ den, inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  den.default.includes = [
    den.batteries.inputs' # injects inputs' into all nixos/homeManager modules
    den.batteries.self' # injects self' (flake packages) into all modules
    den.batteries.hostname
  ];

  den.hosts.x86_64-linux.yousuke = {
    users.thomas = {
      classes = [
        "homeManager"
        "user"
      ];
    };
  };

  den.aspects.yousuke = {
    nixos =
      { config, host, lib, modulesPath, pkgs, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        system.stateVersion = "26.05";
        nixpkgs.config.allowUnfree = true;

        nix.settings = {
          auto-optimise-store = true;
          experimental-features = [
            "pipe-operators"
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "thomas"
          ];
        };

        nix.gc = {
          automatic = true;
          persistent = true;
          dates = "Fri *-*-* 06:00:00";
          options = "--delete-older-than 7d";
        };

        environment.systemPackages = [
          pkgs.nh
        ];

        environment.variables = {
          NH_FLAKE = "/home/thomas/.config/flake";
          NH_HOST = host.name;
        };

        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;

        # Use the systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.hostName = "yousuke";

        # Configure network connections interactively with nmcli or nmtui.
        networking.networkmanager.enable = true;

        # Set your time zone.
        time.timeZone = "Canada/Eastern";

        # Enable the X11 windowing system.
        services.xserver.enable = true;

        # Enable touchpad support (enabled default in most desktopManager).
        services.libinput.enable = true;

        # Enable the OpenSSH daemon.
        services.openssh.enable = true;

        boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" =
          { device = "/dev/disk/by-label/root";
            fsType = "ext4";
          };

        fileSystems."/boot" =
          { device = "/dev/disk/by-label/boot";
            fsType = "vfat";
            options = [ "fmask=0022" "dmask=0022" ];
          };

        swapDevices = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      };
  };
}

