{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.rofi;
in {
  options.modules.desktop.rofi = {
    enable = mkEnableOption "Rofi - Window switcher and application launcher";
  };

  config = mkIf cfg.enable {
    # Install Rofi with Wayland support (rofi now has built-in Wayland support)
    environment.systemPackages = with pkgs; [
      rofi
    ];
  };
}
