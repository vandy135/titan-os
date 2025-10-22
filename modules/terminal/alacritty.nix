{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.terminal.alacritty;
in {
  options.modules.terminal.alacritty = {
    enable = mkEnableOption "Alacritty - GPU-accelerated terminal emulator";
  };

  config = mkIf cfg.enable {
    # Install Alacritty terminal
    environment.systemPackages = with pkgs; [
      alacritty
    ];

    # Enable Wayland support for Alacritty
    environment.variables = {
      WINIT_UNIX_BACKEND = "wayland";
    };
  };
}
