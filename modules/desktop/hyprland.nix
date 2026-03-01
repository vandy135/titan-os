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
  cfg = config.modules.desktop.hyprland;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "hyprland" ];
    description = "Hyprland - Dynamic tiling Wayland compositor";
    defaultChannel = "unstable";
    mkConfig = {channelPkgs, ...}: {
      programs.hyprland = {
        enable = true;
        package = channelPkgs.hyprland;
        xwayland.enable = true;
        withUWSM = true;
      };

      environment.systemPackages = [
        channelPkgs.hyprland
        channelPkgs.egl-wayland
        channelPkgs.wayland
        channelPkgs.wayland-utils
        channelPkgs.wayland-protocols
        channelPkgs.swaybg
      ];

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
          hyprland.default = [ "gtk" "hyprland" ];
        };
      };

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."hypr/hyprland.conf".text = ''
            # ── Monitors ──
            monitor=,preferred,auto,1

            # ── Input ──
            input {
              kb_layout = us
              follow_mouse = 1
              touchpad {
                natural_scroll = true
                tap-to-click = true
              }
            }

            # ── General ──
            general {
              gaps_in = 5
              gaps_out = 10
              border_size = 2
              col.active_border = rgb(${builtins.replaceStrings ["#"] [""] palette.primary})
              col.inactive_border = rgb(${builtins.replaceStrings ["#"] [""] palette.borderInactive})
              layout = dwindle
            }

            # ── Decoration ──
            decoration {
              rounding = 8
              active_opacity = 1.0
              inactive_opacity = 0.85

              blur {
                enabled = true
                size = 5
                passes = 2
              }
            }

            # ── Animations ──
            animations {
              enabled = true
              bezier = easeOut, 0.16, 1, 0.3, 1
              animation = windows, 1, 4, easeOut
              animation = windowsOut, 1, 3, easeOut
              animation = fade, 1, 4, easeOut
              animation = workspaces, 1, 4, easeOut
            }

            # ── Layout ──
            dwindle {
              pseudotile = true
              preserve_split = true
            }

            # ── Cursor ──
            cursor {
              hide_on_key_press = true
            }
            env = XCURSOR_THEME,Bibata-Modern-Classic
            env = XCURSOR_SIZE,24

            # ── Autostart ──
            ${if config.modules.desktop.waybar.enable then "exec-once = waybar" else ""}
            ${if config.modules.desktop.mako.enable then "exec-once = mako" else ""}
            exec-once = swaybg -i ${palette.wallpaper} -m fill
            ${if config.modules.desktop.swayidle.enable then "exec-once = swayidle -w timeout 300 swaylock timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep swaylock" else ""}

            # ── Keybinds ──
            $mod = SUPER

            # App launchers
            bind = $mod, Return, exec, alacritty
            bind = $mod, E, exec, thunar
            bind = $mod, D, exec, fuzzel
            bind = $mod, S, exec, zen-beta
            bind = $mod, W, exec, vesktop

            # Window management
            bind = $mod, Q, killactive
            bind = $mod, F, fullscreen
            bind = $mod, L, exec, swaylock
            bind = $mod SHIFT, E, exit

            # Focus (arrow keys)
            bind = $mod, left, movefocus, l
            bind = $mod, right, movefocus, r
            bind = $mod, up, movefocus, u
            bind = $mod, down, movefocus, d

            # Move windows (Shift + arrow keys)
            bind = $mod SHIFT, left, movewindow, l
            bind = $mod SHIFT, right, movewindow, r
            bind = $mod SHIFT, up, movewindow, u
            bind = $mod SHIFT, down, movewindow, d

            # Workspaces: 1=term, 2=chat, 3=web, 4=remote, 5=general, 6=scratch
            bind = $mod, 1, workspace, 1
            bind = $mod, 2, workspace, 2
            bind = $mod, 3, workspace, 3
            bind = $mod, 4, workspace, 4
            bind = $mod, 5, workspace, 5
            bind = $mod, grave, workspace, 6

            bind = $mod SHIFT, 1, movetoworkspace, 1
            bind = $mod SHIFT, 2, movetoworkspace, 2
            bind = $mod SHIFT, 3, movetoworkspace, 3
            bind = $mod SHIFT, 4, movetoworkspace, 4
            bind = $mod SHIFT, 5, movetoworkspace, 5
            bind = $mod SHIFT, grave, movetoworkspace, 6

            # Screenshots
            bind = , Print, exec, grim - | wl-copy
            bind = $mod, P, exec, slurp | xargs -I {} grim -g '{}' - | wl-copy
            bind = $mod, Print, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

            # Clipboard history
            bind = $mod, V, exec, cliphist list | fuzzel --dmenu -p 'Clipboard: ' | cliphist decode | wl-copy

            # Volume (repeatable with binde)
            binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
            binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

            # Brightness (repeatable)
            binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
            binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

            # ── Window Rules ──
            windowrule = workspace 1, match:class Alacritty
            windowrule = workspace 2, match:class vesktop
            windowrule = workspace 3, match:class zen-beta
            windowrule = workspace 4, match:class org.remmina.Remmina
          '';
        })
      ];
    };
  }
