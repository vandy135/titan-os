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
    description = "Ly - Lightweight TUI display manager";
    mkConfig = {channelPkgs, ...}: {
      # Disable greetd — using Ly instead
      services.greetd.enable = mkForce false;

      services.displayManager.ly = {
        enable = true;
        settings = {
          animation = "matrix";
          hide_borders = true;
          clock = "%H:%M";
        } // optionalAttrs themeEnabled {
          bg = removePrefix "#" palette.base;
          fg = removePrefix "#" palette.text;
          border_color = removePrefix "#" palette.primary;
          input_color = removePrefix "#" palette.surface0;
        };
      };
    };
  }
