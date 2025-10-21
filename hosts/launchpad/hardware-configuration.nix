# Hardware configuration for launchpad
# This is a placeholder - generate the actual configuration with:
# nixos-generate-config --show-hardware-config > hardware-configuration.nix
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Placeholder configurations - replace with actual hardware detection output
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"]; # or "kvm-amd" for AMD processors
  boot.extraModulePackages = [];

  # File systems are managed by disko-config.nix
  # This file will be replaced during installation with actual hardware detection
  # Generated via: nixos-generate-config --no-filesystems --root /mnt

  # Filesystem declarations are in disko-config.nix - do not duplicate here
  # The --no-filesystems flag prevents nixos-generate-config from adding them

  # Swap is configured in configuration.nix for hibernation support

  # CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # For AMD: hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Graphics drivers
  # hardware.graphics.enable = true;

  # Networking hardware
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
