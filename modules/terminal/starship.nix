{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.terminal.starship;
in {
  options.modules.terminal.starship = {
    enable = mkEnableOption "Starship - Minimal, fast, and customizable prompt";
  };

  config = mkIf cfg.enable {
    # Install Starship prompt
    environment.systemPackages = with pkgs; [
      starship
    ];

    # Enable Starship system-wide
    programs.starship = {
      enable = true;
    };
  };
}
