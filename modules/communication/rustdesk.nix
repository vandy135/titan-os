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
  cfg = config.modules.communication.rustdesk;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "communication" "rustdesk" ];
    description = "RustDesk - Open-source remote desktop";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.rustdesk-flutter ];
    };
  }
