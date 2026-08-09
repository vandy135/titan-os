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

  # AMD P-State driver for better power/performance scaling.
  # (active/EPP is already the default on Strix Point + CPPC; explicit for clarity.)
  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # AMD iGPU (Radeon 890M, RDNA 3.5) — drives the internal eDP display.
  # radeonsi (VA-API) and RADV (Vulkan) ship with mesa; add tooling + early KMS.
  # hardware.graphics.enable/enable32Bit come from the nvidia module.
  hardware.graphics.extraPackages = with pkgs; [
    libva-utils   # `vainfo` — verify radeonsi VA-API on the panel
    vulkan-tools  # `vulkaninfo`
  ];
  hardware.amdgpu.initrd.enable = true;  # load amdgpu in stage 1 for a clean eDP at boot

  # System VA-API must target the AMD iGPU that owns the panel (not the dGPU).
  environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";
}
