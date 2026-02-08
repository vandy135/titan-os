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
  cfg = config.modules.desktop.screenshot;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "screenshot" ];
    description = "Screenshot tools (grim + slurp)";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = with channelPkgs; [
        grim       # Wayland screenshot tool
        slurp      # Region selector
        wl-clipboard  # For piping screenshots to clipboard
      ];
    };
  }
