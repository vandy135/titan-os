{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.utilities.yazi;
in {
  options.modules.utilities.yazi = {
    enable = mkEnableOption "Yazi - Blazing fast terminal file manager written in Rust";
  };

  config = mkIf cfg.enable {
    # Install Yazi terminal file manager
    environment.systemPackages = with pkgs; [
      yazi
    ];

    # Enable yazi program configuration if available
    programs.yazi = {
      enable = true;
    };
  };
}
