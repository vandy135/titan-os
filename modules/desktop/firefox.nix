{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.firefox;
in {
  options.modules.desktop.firefox = {
    enable = mkEnableOption "Firefox - Open source web browser";
  };

  config = mkIf cfg.enable {
    # Install Firefox with Wayland support
    environment.systemPackages = with pkgs; [
      firefox-wayland
    ];

    # Enable Firefox program configuration
    programs.firefox = {
      enable = true;
    };

    # Set Firefox as default browser
    environment.variables = {
      DEFAULT_BROWSER = "${pkgs.firefox-wayland}/bin/firefox";
    };
  };
}
