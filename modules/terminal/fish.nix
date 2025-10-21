{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.terminal.fish;
in {
  options.modules.terminal.fish = {
    enable = mkEnableOption "Fish shell - Smart and user-friendly command line shell";
  };

  config = mkIf cfg.enable {
    # Install Fish shell
    environment.systemPackages = with pkgs; [
      fish
    ];

    # Enable Fish as a system shell
    programs.fish = {
      enable = true;
    };
  };
}
