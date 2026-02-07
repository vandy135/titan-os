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
  cfg = config.modules.desktop.mako;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "mako" ];
    description = "Mako - Lightweight Wayland notification daemon";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [
        channelPkgs.mako
        channelPkgs.libnotify
      ];
    };
  }
