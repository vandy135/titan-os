# Claude Code CLI — installed via npm for latest versions
# nixpkgs lags behind significantly; npm gives us same-day releases
#
# To update: npm update -g @anthropic-ai/claude-code
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
    enable = mkEnableOption "Claude Code - AI coding agent (via npm)";
  };

  config = mkIf cfg.enable {
    # Ensure Node.js is available for npm global installs
    environment.systemPackages = [ pkgs.nodejs ];

    # Install/update claude-code on activation
    system.activationScripts.install-claude-code = lib.stringAfter [ "users" ] ''
      echo "Installing/updating @anthropic-ai/claude-code..."
      ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code@latest 2>/dev/null || true
    '';
  };
}
