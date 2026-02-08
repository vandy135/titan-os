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
    description = "SDDM - Display manager with Wayland support";
    mkConfig = {channelPkgs, ...}: {
      # Disable greetd if it was enabled elsewhere
      services.greetd.enable = mkForce false;

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
      };

      services.displayManager.defaultSession = "niri";

      environment.systemPackages = [
        (pkgs-stable.sddm-astronaut.override {
          embeddedTheme = "tokyo-night";
          themeConfig = {
            HourFormat = "hh:mm AP";
            DateFormat = "dddd, MMMM d";
            FontSize = 11;
            HeaderText = "";
            DimBackgroundImage = "0.4";
            ScaleImageCropped = true;
          } // optionalAttrs themeEnabled {
            Background = palette.wallpaper;
          };
        })
      ];
    };
  }
