# WiFi hardware module — MediaTek MT7925 (Filogic 360, Wi-Fi 7 / 802.11be, mt7925e)
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
      description = "WiFi backend — iwd or wpa_supplicant (both work with MT7925)";
    };
  };

  config = mkIf cfg.enable {
    # Redistributable firmware — ships mediatek/mt7925/* (Wi-Fi + BT) via linux-firmware
    hardware.enableRedistributableFirmware = true;

    # NetworkManager WiFi settings
    networking.networkmanager.wifi = {
      powersave = cfg.powersave;
      backend = cfg.backend;
    };

    # iwd service when using iwd backend
    networking.wireless.iwd.enable = cfg.backend == "iwd";

    # Ensure saved WiFi connections have autoconnect enabled
    # Run once after NM starts — idempotent, no-ops if already set
    systemd.services.wifi-autoconnect-setup = mkIf (cfg.autoConnect != null) {
      description = "Ensure WiFi '${cfg.autoConnect}' has autoconnect enabled";
      after = [ "NetworkManager.service" ];
      wants = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.networkmanager ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Wait for NM to be ready
        for i in $(seq 1 15); do
          nmcli general status &>/dev/null && break
          sleep 2
        done

        # If connection profile exists, set autoconnect + priority
        if nmcli connection show '${cfg.autoConnect}' &>/dev/null; then
          nmcli connection modify '${cfg.autoConnect}' \
            connection.autoconnect yes \
            connection.autoconnect-priority 100
          echo "Set autoconnect on '${cfg.autoConnect}'"
        else
          echo "Connection '${cfg.autoConnect}' not found yet — connect manually once, then it will auto-reconnect"
        fi
      '';
    };
  };
}
