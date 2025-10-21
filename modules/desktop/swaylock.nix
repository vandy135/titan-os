{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.swaylock;
in {
  options.modules.desktop.swaylock = {
    enable = mkEnableOption "Swaylock - Screen locker for Wayland";
  };

  config = mkIf cfg.enable {
    # Install Swaylock
    environment.systemPackages = with pkgs; [
      swaylock
    ];

    # Enable security PAM service for swaylock
    security.pam.services.swaylock = {};
  };
}
