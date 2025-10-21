{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.mako;
in {
  options.modules.desktop.mako = {
    enable = mkEnableOption "Mako - Lightweight Wayland notification daemon";
  };

  config = mkIf cfg.enable {
    # Install Mako notification daemon
    environment.systemPackages = with pkgs; [
      mako
      libnotify # For notify-send command
    ];
  };
}
