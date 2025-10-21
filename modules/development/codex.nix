{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.development.codex;
in {
  options.modules.development.codex = {
    enable = mkEnableOption "Codex - Development tool";
  };

  config = mkIf cfg.enable {
    # Install Codex
    environment.systemPackages = with pkgs; [
      codex
    ];
  };
}
