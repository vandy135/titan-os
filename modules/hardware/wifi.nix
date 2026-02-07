# WiFi hardware module — MediaTek MT7922 (WiFi 6E) and general improvements
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.modules.hardware.wifi;
in {
  options.modules.hardware.wifi = {
    enable = mkEnableOption "WiFi hardware support";

    powersave = mkOption {
      type = types.bool;
      default = false;
      description = "Enable WiFi power saving (disable for better reliability on MediaTek chips)";
    };

    backend = mkOption {
      type = types.enum [ "wpa_supplicant" "iwd" ];
      default = "iwd";
      description = "WiFi backend — iwd is generally more reliable for WiFi 6E";
    };
  };

  config = mkIf cfg.enable {
    # Redistributable firmware (includes linux-firmware for MT7922/mt7921e)
    hardware.enableRedistributableFirmware = true;

    # NetworkManager WiFi settings
    networking.networkmanager.wifi = {
      powersave = cfg.powersave;
      backend = cfg.backend;
    };

    # iwd service when using iwd backend
    networking.wireless.iwd.enable = cfg.backend == "iwd";
  };
}
