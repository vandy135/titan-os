{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.dunst;
in {
  options.modules.desktop.dunst = {
    enable = mkEnableOption "Dunst - Lightweight and customizable notification daemon";
  };

  config = mkIf cfg.enable {
    # Install Dunst notification daemon
    environment.systemPackages = with pkgs; [
      dunst
      libnotify # For notify-send command
    ];
  };
}
