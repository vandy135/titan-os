{
  config,
  lib,
  pkgs,
  noctalia,
  ...
}:
with lib; let
  cfg = config.modules.desktop.noctalia;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
in {
  options.modules.desktop.noctalia = {
    enable = mkEnableOption "Noctalia shell - Wayland desktop shell";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.brightnessctl
      pkgs.imagemagick
      pkgs.cliphist
    ];

    home-manager.sharedModules = [
      noctalia.homeModules.default
      ({pkgs, ...}: {
        programs.noctalia-shell = {
          enable = true;
          settings = {
            wallpaper = {
              enable = false;  # swaybg handles wallpaper
            };
            bar = {
              position = "top";
              density = "default";
              widgets = {
                left = [
                  {
                    id = "ControlCenter";
                    useDistroLogo = true;
                  }
                  { id = "Workspace"; }
                ];
                center = [
                  {
                    id = "MediaPlayer";
                  }
                ];
                right = [
                  { id = "Network"; }
                  { id = "Bluetooth"; }
                  { id = "Audio"; }
                  {
                    id = "Battery";
                    warningThreshold = 30;
                  }
                  {
                    id = "Clock";
                    formatHorizontal = "hh:mm AP";
                    useMonospacedFont = true;
                  }
                  { id = "Power"; }
                ];
              };
            };
            # Map our palette names to Noctalia predefined schemes
            colorSchemes.predefinedScheme = {
              "tokyo-night" = "Tokyo Night";
              "catppuccin-mocha" = "Catppuccin Mocha";
              "catppuccin-macchiato" = "Catppuccin Macchiato";
              "dracula" = "Dracula";
              "gruvbox" = "Gruvbox";
              "everforest" = "Everforest";
              "nordic" = "Nord";
            }.${palette.name} or "Monochrome";
            general = {
              radiusRatio = 0.2;
            };
            location = {
              monthBeforeDay = false;
            };
            notifications = {
              enableDoNotDisturb = true;
            };
          };
        };
      })
    ];
  };
}
