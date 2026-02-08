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
  cfg = config.modules.desktop.swaylock;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "swaylock" ];
    description = "Swaylock Effects - Screen locker for Wayland with blur and lock icon";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.swaylock-effects ];
      security.pam.services.swaylock = {};

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."swaylock/config".text = ''
            daemonize
            ignore-empty-password
            show-failed-attempts

            # Screenshot + blur (no static wallpaper needed)
            screenshots
            effect-blur=20x3
            effect-vignette=0.5:0.5
            fade-in=0.2

            # Clock inside indicator
            clock
            timestr=%H:%M
            datestr=%a, %b %d

            # Indicator ring
            indicator
            indicator-radius=120
            indicator-thickness=10

            # Font
            font=CaskaydiaCove Nerd Font

            # Colors — Tokyo Night themed
            color=${removePrefix "#" palette.base}
            text-color=${removePrefix "#" palette.text}
            separator-color=00000000

            ring-color=${removePrefix "#" palette.primary}
            inside-color=${removePrefix "#" palette.mantle}ee
            line-color=00000000

            key-hl-color=${removePrefix "#" palette.accent}
            bs-hl-color=${removePrefix "#" palette.warning}

            inside-ver-color=${removePrefix "#" palette.info}ee
            ring-ver-color=${removePrefix "#" palette.info}
            text-ver-color=${removePrefix "#" palette.text}

            inside-wrong-color=${removePrefix "#" palette.error}ee
            ring-wrong-color=${removePrefix "#" palette.error}
            text-wrong-color=${removePrefix "#" palette.text}

            inside-clear-color=${removePrefix "#" palette.warning}ee
            ring-clear-color=${removePrefix "#" palette.warning}
            text-clear-color=${removePrefix "#" palette.text}
          '';
        })
      ];
    };
  }
