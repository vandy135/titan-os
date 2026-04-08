{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.chromium;
in {
  options.modules.desktop.chromium = {
    enable = mkEnableOption "Chromium - used by Playwright MCP";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.chromium ];
  };
}
