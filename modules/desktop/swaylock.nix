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
    description = "Swaylock - Screen locker for Wayland";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.swaylock ];
      security.pam.services.swaylock = {};

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."swaylock/config".text = ''
            daemonize
            ignore-empty-password
            show-failed-attempts
            image=${palette.wallpaper}
            scaling=fill

            color=${removePrefix "#" palette.base}
            text-color=${removePrefix "#" palette.text}
            separator-color=${removePrefix "#" palette.surface1}

            ring-color=${removePrefix "#" palette.primary}
            inside-color=${removePrefix "#" palette.mantle}
            line-color=${removePrefix "#" palette.surface2}

            key-hl-color=${removePrefix "#" palette.accent}
            bs-hl-color=${removePrefix "#" palette.warning}
            layout-bg-color=${removePrefix "#" palette.base}
            layout-text-color=${removePrefix "#" palette.text}

            inside-ver-color=${removePrefix "#" palette.info}
            ring-ver-color=${removePrefix "#" palette.info}
            inside-wrong-color=${removePrefix "#" palette.error}
            ring-wrong-color=${removePrefix "#" palette.error}
          '';
        })
      ];
    };
  }
