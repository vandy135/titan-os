{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.development.nodejs;
in {
  options.modules.development.nodejs = {
    enable = mkEnableOption "Node.js and npx";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nodejs ];
  };
}
