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
  cfg = config.modules.utilities.yazi;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "utilities" "yazi" ];
    description = "Yazi - Blazing fast terminal file manager written in Rust";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.yazi ];
    };
  }
