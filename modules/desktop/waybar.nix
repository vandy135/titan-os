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
  cfg = config.modules.desktop.waybar;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "waybar" ];
    description = "Waybar - Highly customizable Wayland status bar";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.waybar ];
      programs.waybar.enable = true;

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."waybar/config.jsonc".text = ''
            {
              "layer": "top",
              "position": "top",
              "height": 34,
              "spacing": 8,
              "modules-left": ["niri/workspaces"],
              "modules-center": ["clock"],
              "modules-right": ["network", "pulseaudio", "battery", "cpu", "memory", "tray"],

              "niri/workspaces": {
                "all-outputs": true,
                "format": "{name}"
              },

              "clock": {
                "format": "{:%a %b %d  %I:%M %p}",
                "tooltip-format": "{:%Y-%m-%d %H:%M:%S}"
              },

              "network": {
                "format-wifi": "  {signalStrength}%",
                "format-ethernet": "󰈀  wired",
                "format-disconnected": "󰖪  offline"
              },

              "pulseaudio": {
                "format": "{icon} {volume}%",
                "format-muted": "󰝟 muted",
                "format-icons": {
                  "default": ["󰕿", "󰖀", "󰕾"]
                }
              },

              "battery": {
                "states": {
                  "warning": 30,
                  "critical": 15
                },
                "format": "{icon} {capacity}%",
                "format-icons": ["", "", "", "", ""]
              },

              "cpu": {
                "format": " {usage}%"
              },

              "memory": {
                "format": " {}%"
              },

              "tray": {
                "spacing": 10
              }
            }
          '';

          xdg.configFile."waybar/style.css".text = ''
            * {
              border: none;
              border-radius: 0;
              font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font", sans-serif;
              font-size: 13px;
              min-height: 0;
            }

            window#waybar {
              background: transparent;
              color: ${palette.barText};
            }

            #workspaces,
            #clock,
            #network,
            #pulseaudio,
            #battery,
            #cpu,
            #memory,
            #tray {
              background: ${palette.barBg};
              color: ${palette.barText};
              border: 1px solid ${palette.surface1};
              border-radius: 8px;
              padding: 4px 10px;
              margin: 6px 2px;
            }

            #workspaces button {
              color: ${palette.subtext1};
              padding: 0 6px;
              border-radius: 6px;
            }

            #workspaces button.active {
              color: ${palette.base};
              background: ${palette.primary};
            }

            #workspaces button:hover {
              background: ${palette.surface2};
              color: ${palette.text};
            }

            #battery.warning {
              color: ${palette.warning};
            }

            #battery.critical,
            #network.disconnected {
              color: ${palette.error};
            }

            #clock {
              color: ${palette.accent};
            }
          '';
        })
      ];
    };
  }
