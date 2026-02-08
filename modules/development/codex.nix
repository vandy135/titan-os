# Codex CLI — installed via npm for latest versions
# nixpkgs lags behind significantly; npm gives us same-day releases
#
# To update: npm update -g @openai/codex
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
    enable = mkEnableOption "Codex - OpenAI coding agent (via npm)";
  };

  config = mkIf cfg.enable {
    # Ensure Node.js is available for npm global installs
    environment.systemPackages = [ pkgs.nodejs ];

    # Install/update codex on activation
    system.activationScripts.install-codex = lib.stringAfter [ "users" ] ''
      echo "Installing/updating @openai/codex..."
      ${pkgs.nodejs}/bin/npm install -g @openai/codex@latest 2>/dev/null || true
    '';
  };
}
