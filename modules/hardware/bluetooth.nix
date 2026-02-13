{
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.hardware.bluetooth;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "hardware" "bluetooth" ];
    description = "Bluetooth support with blueman GUI";
    defaultChannel = "stable";
    mkConfig = {channelPkgs, ...}: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;  # Battery reporting for BT devices
            AutoEnable = true;
          };
          Policy = {
            AutoEnable = true;
          };
        };
      };

      services.blueman.enable = true;

      environment.systemPackages = with channelPkgs; [
        bluez
        bluez-tools
      ];
    };
  }
