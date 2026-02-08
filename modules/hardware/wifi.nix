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
      after = [ "NetworkManager-wait-online.service" "network-online.target" ];
      wants = [ "NetworkManager-wait-online.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.networkmanager ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Wait for WiFi device to be ready
        for i in $(seq 1 30); do
          WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | cut -d: -f1 | head -1)
          if [ -n "$WIFI_DEV" ]; then
            break
          fi
          sleep 2
        done

        if [ -z "$WIFI_DEV" ]; then
          echo "No WiFi device found after 60s"
          exit 1
        fi

        # Check if already connected
        CURRENT=$(nmcli -t -f NAME connection show --active | head -1)
        if [ "$CURRENT" = "${cfg.autoConnect}" ]; then
          echo "Already connected to ${cfg.autoConnect}"
          exit 0
        fi

        # Scan and connect with retries
        for i in $(seq 1 5); do
          nmcli device wifi rescan 2>/dev/null || true
          sleep 3
          if nmcli device wifi connect '${cfg.autoConnect}'; then
            echo "Connected to ${cfg.autoConnect}"
            exit 0
          fi
          echo "Attempt $i failed, retrying..."
          sleep 5
        done

        echo "Failed to connect to ${cfg.autoConnect} after 5 attempts"
        exit 1
      '';
    };
  };
}
