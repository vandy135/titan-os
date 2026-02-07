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
  cfg = config.modules.desktop.swaybg;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "swaybg" ];
    description = "Swaybg - Wallpaper manager for Wayland";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.swaybg ];
    };
  }
