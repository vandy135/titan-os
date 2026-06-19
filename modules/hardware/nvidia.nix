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
    prime = {
      enable = mkEnableOption ''
        PRIME render offload: treat an AMD/Intel iGPU as the primary display GPU
        and the NVIDIA dGPU as an on-demand offload device. Use this on hybrid
        laptops where the iGPU drives the internal panel (Wayland-safe)
      '';
      amdgpuBusId = mkOption {
        type = types.str;
        default = "";
        example = "PCI:197:0:0";
        description = "Decimal PCI bus ID of the AMD iGPU (lspci reports hex).";
      };
      nvidiaBusId = mkOption {
        type = types.str;
        default = "";
        example = "PCI:196:0:0";
        description = "Decimal PCI bus ID of the NVIDIA dGPU.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # NVIDIA driver — loads the kmod and, in prime mode, builds the offload
    # plumbing + `nvidia-offload` script. Despite the xserver namespace this does
    # not force an X session for a Wayland/niri login.
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = cfg.open;
      # nvidia-settings is an X11 GUI — pointless in PRIME-offload/Wayland setups.
      nvidiaSettings = !cfg.prime.enable;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement = {
        enable = cfg.powerManagement;
        # Fine-grained RTD3 lets the dGPU reach D3cold when idle. It requires
        # PRIME offload, so only enable it in prime mode.
        finegrained = cfg.powerManagement && cfg.prime.enable;
      };

      # PRIME render offload (hybrid laptops). The iGPU drives the display; run
      # individual apps on the dGPU via the `nvidia-offload` wrapper.
      prime = mkIf cfg.prime.enable {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = cfg.prime.amdgpuBusId;
        nvidiaBusId = cfg.prime.nvidiaBusId;
      };
    };

    # NVIDIA-as-primary environment. These push the compositor/GLX/VAAPI onto the
    # NVIDIA stack and are ONLY correct when NVIDIA drives the display. In
    # PRIME-offload mode the iGPU owns the panel, so setting these globally would
    # black-screen the session / mis-target system VAAPI — suppress them and rely
    # on the per-app `nvidia-offload` wrapper instead.
    environment.sessionVariables = mkIf (!cfg.prime.enable) {
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
