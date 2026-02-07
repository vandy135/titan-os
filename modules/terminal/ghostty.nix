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
  cfg = config.modules.terminal.ghostty;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };

  # Map palette names to Ghostty theme names
  ghosttyTheme = {
    "tokyo-night" = "tokyonight";
    "gruvbox" = "GruvboxDark";
    "catppuccin-mocha" = "catppuccin-mocha";
    "catppuccin-macchiato" = "catppuccin-macchiato";
    "dracula" = "Dracula";
    "everforest" = "Everforest Dark - Hard";
    "nordic" = "nord";
  }.${palette.name or "tokyo-night"} or "tokyonight";
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "ghostty" ];
    description = "Ghostty - GPU-accelerated terminal emulator";
    defaultChannel = "unstable";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.ghostty ];

      home-manager.sharedModules = [
        ({...}: {
          xdg.configFile."ghostty/config".text = ''
            font-family = CaskaydiaCove Nerd Font
            font-size = 13
            ${optionalString themeEnabled "theme = ${ghosttyTheme}"}
            window-decoration = false
            gtk-titlebar = false
            cursor-style = bar
            mouse-hide-while-typing = true
            copy-on-select = clipboard
            window-padding-x = 8
            window-padding-y = 4
          '';
        })
      ];
    };
  }
