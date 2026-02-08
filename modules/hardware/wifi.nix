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

    autoConnect = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Titan";
      description = "SSID to automatically connect to on boot";
    };

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

    # Auto-connect to specified SSID on boot
    systemd.services.wifi-autoconnect = mkIf (cfg.autoConnect != null) {
      description = "Auto-connect to WiFi SSID: ${cfg.autoConnect}";
      after = [ "NetworkManager.service" ];
      wants = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        ExecStart = "${pkgs.networkmanager}/bin/nmcli device wifi connect '${cfg.autoConnect}'";
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}
