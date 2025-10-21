{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.swaybg;
in {
  options.modules.desktop.swaybg = {
    enable = mkEnableOption "Swaybg - Wallpaper manager for Wayland";
  };

  config = mkIf cfg.enable {
    # Install Swaybg
    environment.systemPackages = with pkgs; [
      swaybg
    ];
  };
}
