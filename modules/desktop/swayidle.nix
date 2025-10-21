{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.swayidle;
in {
  options.modules.desktop.swayidle = {
    enable = mkEnableOption "Swayidle - Idle management daemon for Wayland";
  };

  config = mkIf cfg.enable {
    # Install Swayidle
    environment.systemPackages = with pkgs; [
      swayidle
    ];
  };
}
