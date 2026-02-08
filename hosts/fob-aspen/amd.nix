# AMD-specific configuration for fob-aspen (Ryzen HX 370)
{
  config,
  lib,
  pkgs,
  ...
}: {
  # AMD CPU
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # AMD P-State driver for better power/performance scaling
  boot.kernelParams = [
    "amd_pstate=active"
  ];
}
