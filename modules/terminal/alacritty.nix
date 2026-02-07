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
  cfg = config.modules.terminal.alacritty;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "alacritty" ];
    description = "Alacritty - GPU-accelerated terminal emulator";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.alacritty ];
      environment.variables.WINIT_UNIX_BACKEND = "wayland";

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."alacritty/alacritty.toml".text = ''
            [window]
            opacity = 0.95
            padding = { x = 10, y = 10 }

            [font]
            size = 11.0

            [font.normal]
            family = "CaskaydiaCove Nerd Font"
            style = "Regular"

            [colors.primary]
            background = "${palette.base}"
            foreground = "${palette.text}"

            [colors.cursor]
            text = "${palette.base}"
            cursor = "${palette.text}"

            [colors.normal]
            black = "${palette.crust}"
            red = "${palette.error}"
            green = "${palette.success}"
            yellow = "${palette.warning}"
            blue = "${palette.primary}"
            magenta = "${palette.secondary}"
            cyan = "${palette.info}"
            white = "${palette.subtext1}"

            [colors.bright]
            black = "${palette.surface1}"
            red = "${palette.error}"
            green = "${palette.success}"
            yellow = "${palette.warning}"
            blue = "${palette.primary}"
            magenta = "${palette.accent}"
            cyan = "${palette.info}"
            white = "${palette.text}"
          '';
        })
      ];
    };
  }
