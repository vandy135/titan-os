{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.development.gemini-cli;
in {
  options.modules.development.gemini-cli = {
    enable = mkEnableOption "Gemini CLI - Google AI coding agent";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli
    ];
  };
}
