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
  cfg = config.modules.communication.zoom;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "communication" "zoom" ];
    description = "Zoom - Video conferencing application";
    defaultChannel = "stable";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.zoom-us ];
    };
  }
