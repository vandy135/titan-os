# Hardware configuration for fob-titan
# This is a template - replace with actual hardware configuration
# Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
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

  # Boot configuration - CUSTOMIZE FOR YOUR HARDWARE
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"]; # Use "kvm-amd" for AMD CPUs
  boot.extraModulePackages = [];

  # Filesystem configuration - CUSTOMIZE FOR YOUR SYSTEM
  # Replace with your actual partition layout
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-BOOT-UUID";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # Swap configuration - uncomment if you have swap
  # swapDevices = [
  #   {device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-SWAP-UUID";}
  # ];

  # CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # For AMD: hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Networking hardware
  networking.useDHCP = lib.mkDefault true;

  # Graphics - uncomment and configure as needed
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  # };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
