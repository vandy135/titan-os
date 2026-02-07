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
  cfg = config.modules.communication.vesktop;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "communication" "vesktop" ];
    description = "Vesktop - Custom Discord client with Vencord built-in";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.vesktop ];
    };
  }
