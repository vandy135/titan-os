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
  cfg = config.modules.desktop.fuzzel;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "fuzzel" ];
    description = "Fuzzel - Wayland application launcher";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.fuzzel ];
    };
  }
