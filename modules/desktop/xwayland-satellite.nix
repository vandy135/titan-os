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
  cfg = config.modules.desktop.xwayland-satellite;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "xwayland-satellite" ];
    description = "Xwayland-satellite - Xwayland integration for Wayland compositors";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.xwayland-satellite ];
    };
  }
