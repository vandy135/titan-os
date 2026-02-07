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
  cfg = config.modules.desktop.firefox;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "firefox" ];
    description = "Firefox - Open source web browser";
    defaultChannel = "unstable";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.firefox-wayland ];
      programs.firefox.enable = true;
      environment.variables.DEFAULT_BROWSER = "${channelPkgs.firefox-wayland}/bin/firefox";
    };
  }
