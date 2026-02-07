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
  cfg = config.modules.development.claude-code;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "development" "claude-code" ];
    description = "Claude Code - AI-powered code editor";
    defaultChannel = "edge";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.claude-code ];
    };
  }
