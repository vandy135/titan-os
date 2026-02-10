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
  cfg = config.modules.system.snapper;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "system" "snapper" ];
    description = "Snapper - Btrfs snapshot management with automatic cleanup";
    mkConfig = {channelPkgs, ...}: {
      services.snapper = {
        snapshotInterval = "hourly";
        cleanupInterval = "1d";
        configs = {
          root = {
            SUBVOLUME = "/";
            ALLOW_USERS = [ "titan" ];
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
            TIMELINE_LIMIT_HOURLY = "5";
            TIMELINE_LIMIT_DAILY = "7";
            TIMELINE_LIMIT_WEEKLY = "4";
            TIMELINE_LIMIT_MONTHLY = "6";
            TIMELINE_LIMIT_YEARLY = "0";
          };
          home = {
            SUBVOLUME = "/home";
            ALLOW_USERS = [ "titan" ];
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
            TIMELINE_LIMIT_HOURLY = "5";
            TIMELINE_LIMIT_DAILY = "7";
            TIMELINE_LIMIT_WEEKLY = "4";
            TIMELINE_LIMIT_MONTHLY = "6";
            TIMELINE_LIMIT_YEARLY = "2";
          };
        };
      };

      environment.systemPackages = [ channelPkgs.snapper ];
    };
  }
