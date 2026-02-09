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
  cfg = config.modules.desktop.fuzzel;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "fuzzel" ];
    description = "Fuzzel - Wayland application launcher";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.fuzzel ];

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          xdg.configFile."fuzzel/fuzzel.ini".text = ''
            [main]
            terminal=alacritty
            width=45
            lines=12
            layer=overlay
            font=CaskaydiaCove Nerd Font:size=11
            icon-theme=Papirus-Dark

            [colors]
            background=${removePrefix "#" palette.base}ff
            text=${removePrefix "#" palette.text}ff
            prompt=${removePrefix "#" palette.primary}ff
            placeholder=${removePrefix "#" palette.subtext0}ff
            input=${removePrefix "#" palette.text}ff
            match=${removePrefix "#" palette.accent}ff
            selection=${removePrefix "#" palette.surface1}ff
            selection-text=${removePrefix "#" palette.text}ff
            selection-match=${removePrefix "#" palette.primary}ff
            border=${removePrefix "#" palette.border}ff
          '';
        })
      ];
    };
  }
