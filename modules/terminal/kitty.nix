{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.terminal.kitty;
in {
  options.modules.terminal.kitty = {
    enable = mkEnableOption "Kitty - GPU-accelerated terminal emulator";
  };

  config = mkIf cfg.enable {
    # Install Kitty terminal
    environment.systemPackages = with pkgs; [
      kitty
    ];

    # Enable Wayland support for Kitty
    environment.variables = {
      KITTY_ENABLE_WAYLAND = "1";
    };
  };
}
