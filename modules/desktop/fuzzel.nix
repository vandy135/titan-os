{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.fuzzel;
in {
  options.modules.desktop.fuzzel = {
    enable = mkEnableOption "Fuzzel - Wayland application launcher";
  };

  config = mkIf cfg.enable {
    # Install Fuzzel
    environment.systemPackages = with pkgs; [
      fuzzel
    ];
  };
}
