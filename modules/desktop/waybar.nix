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
  cfg = config.modules.desktop.waybar;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "waybar" ];
    description = "Waybar - Highly customizable Wayland status bar";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.waybar ];
      programs.waybar.enable = true;
    };
  }
