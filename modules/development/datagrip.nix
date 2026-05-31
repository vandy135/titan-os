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
  cfg = config.modules.development.datagrip;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "development" "datagrip" ];
    description = "DataGrip - Database IDE from JetBrains";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.jetbrains.datagrip ];
    };
  }
