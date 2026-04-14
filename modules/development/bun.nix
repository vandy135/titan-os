{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.development.bun;
in {
  options.modules.development.bun = {
    enable = mkEnableOption "Bun JavaScript runtime";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bun ];
  };
}
