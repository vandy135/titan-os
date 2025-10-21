{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.xwayland-satellite;
in {
  options.modules.desktop.xwayland-satellite = {
    enable = mkEnableOption "Xwayland-satellite - Xwayland integration for Wayland compositors";
  };

  config = mkIf cfg.enable {
    # Install Xwayland-satellite
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
