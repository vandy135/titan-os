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
  cfg = config.modules.communication.remmina;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "communication" "remmina" ];
    description = "Remmina - Remote desktop client (RDP, VNC, SSH)";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = with channelPkgs; [
        remmina
        freerdp3    # RDP backend for Remmina
      ];
    };
  }
