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

      # Note: "import-environment without variable list" warning is from niri-session upstream
      # Harmless deprecation warning, will be fixed in a future niri release

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

            // Animations — smooth and classy
            animations {
              window-open {
                duration-ms 200
                curve "ease-out-expo"
              }
              window-close {
                duration-ms 150
                curve "ease-out-quad"
              }
              workspace-switch {
                duration-ms 250
                curve "ease-out-cubic"
              }
              horizontal-view-movement {
                duration-ms 250
                curve "ease-out-cubic"
              }
              config-notification-open-close {
                duration-ms 200
                curve "ease-out-quad"
              }
            }

            prefer-no-csd
            ${if config.modules.desktop.waybar.enable then
              (if config.modules.desktop.hyprland.enable then
                ''spawn-at-startup "bash" "-c" "waybar --config ~/.config/waybar/config-niri.jsonc"''
              else
                ''spawn-at-startup "waybar"'')
            else ""}
            ${if config.modules.desktop.mako.enable then ''spawn-at-startup "mako"'' else ""}
            ${if config.modules.desktop.noctalia.enable then ''spawn-at-startup "noctalia-shell"'' else ""}
            spawn-at-startup "bash" "-c" "swaybg -i ${palette.wallpaper} -m fill"
            ${if config.modules.desktop.swayidle.enable then ''spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock" "timeout" "600" "niri msg action power-off-monitors" "resume" "niri msg action power-on-monitors" "before-sleep" "swaylock"'' else ""}

            binds {
              Mod+Return { spawn "alacritty"; }
              Mod+E { spawn "thunar"; }
              Mod+D { spawn "fuzzel"; }
              Mod+S { spawn "zen-beta"; }
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
              Mod+1 { focus-workspace "term"; }
              Mod+2 { focus-workspace "chat"; }
              Mod+3 { focus-workspace "web"; }
              Mod+4 { focus-workspace "remote"; }
              Mod+5 { focus-workspace "5"; }
              Mod+Shift+1 { move-window-to-workspace "term"; }
              Mod+Shift+2 { move-window-to-workspace "chat"; }
              Mod+Shift+3 { move-window-to-workspace "web"; }
              Mod+Shift+4 { move-window-to-workspace "remote"; }
              Mod+Shift+5 { move-window-to-workspace "5"; }

              // Scratch workspace toggle
              Mod+grave { focus-workspace "scratch"; }
              Mod+Shift+grave { move-window-to-workspace "scratch"; }

              // Screenshots
              Print { spawn "sh" "-c" "grim - | wl-copy"; }
              Mod+P { spawn "sh" "-c" "slurp | xargs -I {} grim -g '{}' - | wl-copy"; }
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

            // Inactive windows get slight transparency
            window-rule {
              opacity 0.85
            }
            window-rule {
              match is-focused=true
              opacity 1.0
            }

            // Assign apps to workspaces
            window-rule {
              match app-id="Alacritty"
              open-on-workspace "term"
            }
            window-rule {
              match app-id="vesktop"
              open-on-workspace "chat"
            }
            window-rule {
              match app-id="zen-beta"
              open-on-workspace "web"
            }
            window-rule {
              match app-id="org.remmina.Remmina"
              open-on-workspace "remote"
            }

            output "*" {
              scale 1.0
            }

            workspace "term"
            workspace "chat"
            workspace "web"
            workspace "remote"
            workspace "scratch"
          '';
        })
      ];
    };
  }
