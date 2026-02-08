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
  cfg = config.modules.desktop.rofi;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };

  c = color: removePrefix "#" color;
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "rofi" ];
    description = "Rofi - Wayland application launcher with icons";
    defaultChannel = "unstable";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [
        channelPkgs.rofi
        channelPkgs.papirus-icon-theme
      ];

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."rofi/config.rasi".text = ''
            configuration {
              modi: "drun,run,window";
              show-icons: true;
              icon-theme: "Papirus-Dark";
              terminal: "alacritty";
              drun-display-format: "{icon} {name}";
              display-drun: " Apps";
              display-run: " Run";
              display-window: " Windows";
            }

            * {
              bg:       #${c palette.base};
              bg-alt:   #${c palette.surface0};
              fg:       #${c palette.text};
              fg-alt:   #${c palette.subtext0};
              accent:   #${c palette.primary};
              warm:     #${c palette.error};
              surface:  #${c palette.surface1};
            }

            window {
              width: 680px;
              background-color: @bg;
              border: 2px solid;
              border-color: @warm;
              border-radius: 8px;
              padding: 0;
            }

            mainbox {
              background-color: @bg;
              children: [ inputbar, listview ];
              spacing: 0;
              padding: 0;
            }

            inputbar {
              background-color: @bg-alt;
              text-color: @fg;
              padding: 12px 16px;
              children: [ prompt, entry ];
              border: 0 0 1px 0 solid;
              border-color: @surface;
            }

            prompt {
              background-color: @bg-alt;
              text-color: @accent;
              padding: 0 8px 0 0;
            }

            entry {
              background-color: @bg-alt;
              text-color: @fg;
              placeholder: "Search...";
              placeholder-color: @fg-alt;
            }

            listview {
              background-color: @bg;
              columns: 1;
              lines: 10;
              padding: 8px 0;
              fixed-height: true;
              dynamic: true;
              scrollbar: false;
            }

            element {
              background-color: @bg;
              text-color: @fg;
              padding: 8px 16px;
              spacing: 12px;
            }

            element normal.normal {
              background-color: @bg;
              text-color: @fg;
            }

            element alternate.normal {
              background-color: @bg;
              text-color: @fg;
            }

            element selected.normal {
              background-color: @surface;
              text-color: @fg;
              border: 0 0 0 3px solid;
              border-color: @warm;
              border-radius: 4px;
            }

            element-icon {
              background-color: inherit;
              size: 24px;
            }

            element-text {
              background-color: inherit;
              text-color: inherit;
              vertical-align: 0.5;
            }
          '';
        })
      ];
    };
  }
