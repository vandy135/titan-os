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
  cfg = config.modules.desktop.mako;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "mako" ];
    description = "Mako - Lightweight Wayland notification daemon";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [
        channelPkgs.mako
        channelPkgs.libnotify
      ];

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."mako/config".text = ''
            background-color=${palette.base}
            text-color=${palette.text}
            border-color=${palette.border}
            progress-color=over ${palette.primary}
            border-size=2
            border-radius=8
            padding=12
            default-timeout=5000
            ignore-timeout=1

            [urgency=low]
            border-color=${palette.info}

            [urgency=normal]
            border-color=${palette.primary}

            [urgency=high]
            background-color=${palette.mantle}
            text-color=${palette.text}
            border-color=${palette.error}
          '';
        })
      ];
    };
  }
