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
      environment.systemPackages = [
        channelPkgs.waybar
        channelPkgs.pavucontrol  # Audio control GUI (waybar click)
      ];
      # NOTE: do NOT set programs.waybar.enable — it starts waybar via systemd,
      # but niri already spawns it via spawn-at-startup, causing duplicates.

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."waybar/config.jsonc".text = ''
            {
              "layer": "top",
              "position": "top",
              "height": 34,
              "spacing": 8,
              "modules-left": ["${if config.modules.desktop.hyprland.enable then "hyprland/workspaces" else "niri/workspaces"}"],
              "modules-center": ["mpris", "clock"],
              "modules-right": ["bluetooth", "network", "pulseaudio", "battery", "cpu", "memory", "tray", "custom/power"],

              ${if config.modules.desktop.hyprland.enable then ''"hyprland/workspaces": {
                "format": "{id}",
                "on-click": "activate",
                "sort-by-number": true
              },'' else ''"niri/workspaces": {
                "all-outputs": true,
                "format": "{name}"
              },''}

              "mpris": {
                "format": "{player_icon} {artist} — {title}",
                "format-paused": "{player_icon} {status_icon} {artist} — {title}",
                "player-icons": {
                  "default": "▶",
                  "spotify": "",
                  "zen": "󰈹",
                  "zen-browser": "󰈹",
                  "firefox": "󰈹",
                  "chromium": "",
                  "vlc": "󰕼"
                },
                "status-icons": {
                  "paused": "⏸"
                },
                "max-length": 40,
                "tooltip-format": "{player}: {title}\n{artist} — {album}"
              },

              "clock": {
                "format": "{:%a %b %d  %I:%M %p}",
                "tooltip-format": "{:%Y-%m-%d %H:%M:%S}"
              },

              "bluetooth": {
                "format": "󰂯 {status}",
                "format-connected": "󰂱 {num_connections}",
                "format-disabled": "󰂲",
                "format-off": "󰂲",
                "tooltip-format": "{controller_alias}\n{num_connections} connected",
                "tooltip-format-connected": "{controller_alias}\n{num_connections} connected\n\n{device_enumerate}",
                "tooltip-format-enumerate-connected": "{device_alias}\t{device_battery_percentage}%",
                "on-click": "blueman-manager"
              },

              "network": {
                "format-wifi": "  {signalStrength}%",
                "format-ethernet": "󰈀  wired",
                "format-disconnected": "󰖪  offline",
                "tooltip-format-wifi": "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}",
                "on-click": "alacritty -e nmtui"
              },

              "pulseaudio": {
                "format": "{icon} {volume}%",
                "format-muted": "󰝟 muted",
                "format-icons": {
                  "default": ["󰕿", "󰖀", "󰕾"]
                },
                "on-click": "pavucontrol",
                "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+",
                "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-",
                "on-click-right": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
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
              },

              "custom/power": {
                "format": "⏻",
                "tooltip": false,
                "on-click": "bash -c 'case $(printf \"Lock\\nLogout\\nSuspend\\nReboot\\nShutdown\" | fuzzel --dmenu --prompt \"Power: \") in Lock) swaylock;; Logout) ${if config.modules.desktop.hyprland.enable then "hyprctl dispatch exit" else "niri msg action quit"};; Suspend) systemctl suspend;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac'"
              }
            }
          '';

          xdg.configFile."waybar/style.css".text = ''
            * {
              border: none;
              border-radius: 0;
              font-family: "CaskaydiaCove Nerd Font", "Symbols Nerd Font", sans-serif;
              font-size: 13px;
              min-height: 0;
            }

            window#waybar {
              background: transparent;
              color: ${palette.barText};
            }

            #workspaces,
            #clock,
            #bluetooth,
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

            #mpris {
              color: ${palette.success};
              font-style: italic;
            }

            #clock {
              color: ${palette.accent};
            }

            #custom-power {
              color: ${palette.error};
              padding: 4px 8px;
            }
          '';
        })
      ];
    };
  }
