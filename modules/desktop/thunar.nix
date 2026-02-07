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
  cfg = config.modules.desktop.thunar;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "thunar" ];
    description = "Thunar - Lightweight file manager";
    mkConfig = {channelPkgs, ...}: {
      programs.thunar = {
        enable = true;
        plugins = with channelPkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];
      };

      # Thumbnail support
      services.tumbler.enable = true;

      # GVFS for trash, network mounts, etc.
      services.gvfs.enable = true;

      environment.systemPackages = with channelPkgs; [
        xfce.thunar-archive-plugin
        file-roller    # Archive manager GUI
      ];
    };
  }
