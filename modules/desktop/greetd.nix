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
  cfg = config.modules.desktop.greetd;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "greetd" ];
    description = "Greetd + ReGreet - GTK4 display manager greeter";
    mkConfig = {channelPkgs, ...}: {
      programs.regreet = {
        enable = true;

        settings = {
          background = mkIf themeEnabled {
            path = palette.wallpaper;
            fit = "Cover";
          };
        };

        theme = {
          name = "Adwaita-dark";
          package = channelPkgs.gnome-themes-extra;
        };

        cursorTheme = {
          name = "Bibata-Modern-Classic";
          package = channelPkgs.bibata-cursors;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = channelPkgs.papirus-icon-theme;
        };

        font = {
          name = "CaskaydiaCove Nerd Font";
          size = 14;
          package = channelPkgs.nerd-fonts.caskaydia-cove;
        };

        extraCss = optionalString themeEnabled ''
          window {
            background-color: ${palette.base};
          }

          entry {
            background-color: ${palette.surface0};
            color: ${palette.text};
            border: 2px solid ${palette.primary};
            border-radius: 8px;
            padding: 8px 12px;
          }

          entry:focus {
            border-color: ${palette.accent};
          }

          button {
            background-color: ${palette.surface1};
            color: ${palette.text};
            border: 1px solid ${palette.surface2};
            border-radius: 6px;
            padding: 8px 16px;
          }

          button:hover {
            background-color: ${palette.surface2};
            border-color: ${palette.primary};
          }

          combobox button {
            background-color: ${palette.surface0};
          }

          label {
            color: ${palette.text};
          }
        '';
      };

      # Assign greetd to VT 7 so logind grants it a seat (fixes libseat)
      services.greetd.settings.terminal.vt = 7;

      environment.etc."greetd/environments".text = ''
        niri-session
      '';
    };
  }
