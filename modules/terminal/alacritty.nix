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
  cfg = config.modules.terminal.alacritty;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "alacritty" ];
    description = "Alacritty - GPU-accelerated terminal emulator";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.alacritty ];
      environment.variables.WINIT_UNIX_BACKEND = "wayland";
    };
  }
