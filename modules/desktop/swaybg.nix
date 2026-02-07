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
  cfg = config.modules.desktop.swaybg;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "swaybg" ];
    description = "Swaybg - Wallpaper manager for Wayland";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.swaybg ];

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."swaybg/wallpaper".text = palette.wallpaper;
        })
      ];
    };
  }
