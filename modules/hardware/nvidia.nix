{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.hardware.nvidia;
in {
  options.modules.hardware.nvidia = {
    enable = mkEnableOption "NVIDIA GPU support";
    open = mkOption {
      type = types.bool;
      default = true;
      description = "Use NVIDIA open-source kernel modules (Turing+).";
    };
    powerManagement = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA power management (useful for laptops).";
    };
  };

  config = mkIf cfg.enable {
    # Enable graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # NVIDIA driver
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = cfg.open;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement = {
        enable = cfg.powerManagement;
        finegrained = false;
      };
    };

    # Wayland / Niri environment variables
    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      NVD_BACKEND = "direct";
    };

    # VA-API for video acceleration
    environment.systemPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };
}
