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
  cfg = config.modules.desktop.swaylock;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "swaylock" ];
    description = "Swaylock - Screen locker for Wayland";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.swaylock ];
      security.pam.services.swaylock = {};
    };
  }
