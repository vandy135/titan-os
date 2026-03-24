{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.development.python;
in {
  options.modules.development.python = {
    enable = mkEnableOption "Python 3";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.python3 ];
  };
}
