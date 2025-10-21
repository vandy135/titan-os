{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.anyrun;
in {
  options.modules.desktop.anyrun = {
    enable = mkEnableOption "AnyRun - Wayland-native application launcher and runner";
  };

  config = mkIf cfg.enable {
    # Install AnyRun
    environment.systemPackages = with pkgs; [
      anyrun
    ];
  };
}
