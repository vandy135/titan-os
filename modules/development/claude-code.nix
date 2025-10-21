{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.development.claude-code;
in {
  options.modules.development.claude-code = {
    enable = mkEnableOption "Claude Code - AI-powered code editor";
  };

  config = mkIf cfg.enable {
    # Install Claude Code
    environment.systemPackages = with pkgs; [
      claude-code
    ];
  };
}
