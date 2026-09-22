{ config, lib, ... }: {

  boot = {

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.bluetooth.enable = true;

  networking.networkmanager.enable = true;

  services.libinput.enable = true;

}
