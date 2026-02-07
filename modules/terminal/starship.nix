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
  cfg = config.modules.terminal.starship;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "starship" ];
    description = "Starship - Minimal, fast, and customizable prompt";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.starship ];
      programs.starship.enable = true;
    };
  }
