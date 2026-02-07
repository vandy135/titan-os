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
  themeName = config.modules.theme.name or "tokyo-night";
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };

  # Map system theme names to Ghostty built-in theme names
  ghosttyTheme = {
    "tokyo-night" = "tokyonight";
    "gruvbox" = "GruvboxDark";
    "catppuccin-mocha" = "catppuccin-mocha";
    "catppuccin-macchiato" = "catppuccin-macchiato";
    "dracula" = "Dracula";
    "everforest" = "Everforest Dark - Hard";
    "nordic" = "nord";
  }.${themeName} or themeName;
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
            # Font
            font-family = JetBrainsMono Nerd Font
            font-size = 13

            # Theme
            theme = ${ghosttyTheme}

            # Window
            window-decoration = false
            gtk-titlebar = false
            window-padding-x = 8
            window-padding-y = 8
            background-opacity = 0.95

            # Cursor
            cursor-style = block
            cursor-style-blink = true

            # Shell
            command = zsh

            # Keybinds
            keybind = ctrl+shift+c=copy_to_clipboard
            keybind = ctrl+shift+v=paste_from_clipboard
            keybind = ctrl+shift+t=new_tab
            keybind = ctrl+shift+w=close_surface

            # Scrollback
            scrollback-limit = 10000

            # Misc
            mouse-hide-while-typing = true
            copy-on-select = clipboard
          '';
        })
      ];
    };
  }
