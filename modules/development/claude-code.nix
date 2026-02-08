{
  config,
  lib,
  pkgs-edge,
  ...
}:
with lib; let
  cfg = config.modules.development.claude-code;
in {
  options.modules.development.claude-code = {
    enable = mkEnableOption "Claude Code - AI coding agent";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs-edge.claude-code ];
  };
}
