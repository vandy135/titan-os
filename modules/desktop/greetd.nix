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
        package = channelPkgs.kdePackages.sddm;
      };

      services.displayManager.defaultSession = "niri-session";

      environment.systemPackages = [
        (channelPkgs.sddm-astronaut.override {
          embeddedTheme = "tokyo-night";
          themeConfig = {
            # Clock
            HourFormat = "hh:mm AP";
            DateFormat = "dddd, MMMM d";

            # Appearance
            FontSize = 11;
            HeaderText = "";

            # Background
            DimBackgroundImage = "0.4";
            ScaleImageCropped = true;
            ScreenWidth = 1920;
            ScreenHeight = 1080;
          } // optionalAttrs themeEnabled {
            Background = palette.wallpaper;
          };
        })
      ];
    };
  }
