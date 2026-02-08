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
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "greetd" ];
    description = "Greetd - Display manager with tuigreet greeter";
    mkConfig = {channelPkgs, ...}: {
      services.greetd = {
        enable = mkForce true;
        settings = {
          default_session = mkForce {
            command = "${channelPkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd niri-session";
            user = "greeter";
          };
        };
      };

      # Disable SDDM if previously enabled
      services.displayManager.sddm.enable = mkForce false;

      environment.etc."greetd/environments".text = ''
        niri-session
      '';
    };
  }
