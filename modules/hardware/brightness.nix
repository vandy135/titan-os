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
  cfg = config.modules.hardware.brightness;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "hardware" "brightness" ];
    description = "Screen brightness control (brightnessctl)";
    defaultChannel = "stable";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.brightnessctl ];

      # Allow users in video group to control backlight
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${channelPkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${channelPkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      '';
    };
  }
