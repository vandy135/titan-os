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
  cfg = config.modules.development.codex;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "development" "codex" ];
    description = "Codex - Development tool";
    defaultChannel = "edge";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.codex ];
    };
  }
