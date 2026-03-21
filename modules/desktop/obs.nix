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
  cfg = config.modules.desktop.obs;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "obs" ];
    description = "OBS Studio - Open Broadcaster Software";
    mkConfig = {channelPkgs, ...}: {
      # JACK support for OBS audio routing
      services.pipewire.jack.enable = true;

      environment.systemPackages = with channelPkgs; [
        (obs-studio.override {
          cudaSupport = config.modules.hardware.nvidia.enable or false;
        })
        # XWayland window capture support
        xorg.libXcomposite
      ];
    };
  }
