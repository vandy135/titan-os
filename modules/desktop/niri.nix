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
        channelPkgs.swaybg
      ];

      programs.niri.enable = true;

      # Nerd fonts for waybar icons, fuzzel, alacritty
      fonts.packages = [
        (channelPkgs.nerd-fonts.caskaydia-cove)
      ];
      fonts.fontconfig.defaultFonts = {
        monospace = [ "CaskaydiaCove Nerd Font" ];
      };

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        ELECTRON_ENABLE_WAYLAND = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };

      xdg.portal = {
        enable = true;
        config = {
          common.default = [ "gtk" ];
          niri.default = [ "gtk" ];
        };
      };

      # Display manager handled by modules/desktop/greetd.nix (SDDM)

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
              focus-follows-mouse max-scroll-amount="0%"
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
              default-column-width { proportion 0.5; }
              center-focused-column "never"
            }

            window-rule {
              geometry-corner-radius 8 8 8 8
              clip-to-geometry true
            }

            cursor {
              hide-when-typing
              xcursor-theme "Bibata-Modern-Classic"
              xcursor-size 24
            }

            prefer-no-csd
            ${if config.modules.desktop.waybar.enable then ''spawn-at-startup "waybar"'' else ""}
            ${if config.modules.desktop.mako.enable then ''spawn-at-startup "mako"'' else ""}
            ${if config.modules.desktop.noctalia.enable then ''spawn-at-startup "noctalia-shell"'' else ""}
            ${if config.modules.desktop.swaybg.enable then ''spawn-at-startup "bash" "-c" "swaybg -i ${palette.wallpaper} -m fill"'' else ""}

            binds {
              Mod+Return { spawn "alacritty"; }
              Mod+E { spawn "thunar"; }
              Mod+D { spawn "fuzzel"; }
              Mod+S { spawn "zen"; }
              Mod+W { spawn "vesktop"; }
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

              // Screenshots
              Print { spawn "sh" "-c" "grim - | wl-copy"; }
              Mod+Shift+S { spawn "sh" "-c" "slurp | xargs -I {} grim -g '{}' - | wl-copy"; }
              Mod+Print { spawn "sh" "-c" "grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"; }

              // Clipboard history
              Mod+V { spawn "sh" "-c" "cliphist list | fuzzel --dmenu -p 'Clipboard: ' | cliphist decode | wl-copy"; }

              // Brightness
              XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
              XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

              // Volume
              XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
              XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
              XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
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
