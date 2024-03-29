# Do not modify this file!  It was generated by ‘nixos-generate-config’ and may
# be overwritten by future invocations. Please make changes to
# /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = ["${modulesPath}/installer/scan/not-detected.nix"];

  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = ["nvme" "sd_mod" "usb_storage" "xhci_pci"];
      kernelModules = [];
    };

    kernelModules = ["kvm-amd"];
  };

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
