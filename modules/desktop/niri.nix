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
  cfg = config.modules.desktop.niri;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "niri" ];
    description = "Niri Wayland compositor with scrollable tiling";
    defaultChannel = "unstable";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [
        channelPkgs.niri
        channelPkgs.egl-wayland
        channelPkgs.xwayland
        channelPkgs.wayland
        channelPkgs.wayland-utils
        channelPkgs.wayland-protocols
        channelPkgs.wlroots
      ];

      programs.niri.enable = true;

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        ELECTRON_ENABLE_WAYLAND = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };

      xdg.portal = {
        enable = true;
        extraPortals = [ channelPkgs.xdg-desktop-portal-gtk ];
        config = {
          common.default = "gtk";
          niri.default = [ "gtk" ];
        };
      };

      services.greetd = {
        enable = mkDefault true;
        settings = {
          default_session = {
            command = "${channelPkgs.tuigreet}/bin/tuigreet --cmd niri-session";
          };
        };
      };
    };
  }
