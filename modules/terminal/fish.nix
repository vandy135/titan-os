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
  cfg = config.modules.terminal.fish;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "fish" ];
    description = "Fish shell - Smart and user-friendly command line shell";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.fish ];
      programs.fish.enable = true;
    };
  }
