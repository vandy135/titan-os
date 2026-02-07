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
  cfg = config.modules.desktop.swayidle;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "swayidle" ];
    description = "Swayidle - Idle management daemon for Wayland";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.swayidle ];
    };
  }
