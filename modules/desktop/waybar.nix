{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.waybar;
in {
  options.modules.desktop.waybar = {
    enable = mkEnableOption "Waybar - Highly customizable Wayland status bar";
  };

  config = mkIf cfg.enable {
    # Install Waybar
    environment.systemPackages = with pkgs; [
      waybar
    ];

    # Enable programs.waybar for system-wide configuration
    programs.waybar = {
      enable = true;
    };
  };
}
