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
  cfg = config.modules.development.dbeaver;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "development" "dbeaver" ];
    description = "DBeaver - Universal database manager";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.dbeaver-bin ];
    };
  }
