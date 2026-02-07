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
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
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

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."niri/config.kdl".text = ''
            input {
              keyboard {
                xkb {
                  layout "us"
                }
              }
              touchpad {
                tap
                natural-scroll
              }
            }

            layout {
              gaps 10
              border {
                width 2
                active-color "${palette.border}"
                inactive-color "${palette.borderInactive}"
              }
              focus-ring {
                width 3
                active-color "${palette.primary}"
                inactive-color "${palette.surface2}"
              }
            }

            prefer-no-csd
            spawn-at-startup "waybar"
            spawn-at-startup "mako"
            spawn-at-startup "swaybg -i ${palette.wallpaper} -m fill"

            binds {
              Mod+Return { spawn "alacritty"; }
              Mod+D { spawn "fuzzel"; }
              Mod+Q { close-window; }
              Mod+L { spawn "swaylock"; }
              Mod+Shift+E { quit; }
              Mod+F { fullscreen-window; }
              Mod+Left { focus-column-left; }
              Mod+Down { focus-window-down; }
              Mod+Up { focus-window-up; }
              Mod+Right { focus-column-right; }
              Mod+Shift+Left { move-column-left; }
              Mod+Shift+Down { move-window-down; }
              Mod+Shift+Up { move-window-up; }
              Mod+Shift+Right { move-column-right; }
              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+Shift+1 { move-window-to-workspace 1; }
              Mod+Shift+2 { move-window-to-workspace 2; }
              Mod+Shift+3 { move-window-to-workspace 3; }
              Mod+Shift+4 { move-window-to-workspace 4; }
              Mod+Shift+5 { move-window-to-workspace 5; }
            }

            output "*" {
              scale 1.0
            }

            workspace "1"
            workspace "2"
            workspace "3"
          '';
        })
      ];
    };
  }
