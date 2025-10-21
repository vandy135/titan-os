{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.communication.zoom;
in {
  options.modules.communication.zoom = {
    enable = mkEnableOption "Zoom - Video conferencing application";
  };

  config = mkIf cfg.enable {
    # Install Zoom
    environment.systemPackages = with pkgs; [
      zoom-us
    ];
  };
}
