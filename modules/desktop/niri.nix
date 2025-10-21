{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.niri;
in {
  options.modules.desktop.niri = {
    enable = mkEnableOption "Niri Wayland compositor with scrollable tiling";
  };

  config = mkIf cfg.enable {
    # Install Niri and Wayland dependencies
    environment.systemPackages = with pkgs; [
      niri
      egl-wayland
      xwayland
      wayland
      wayland-utils
      wayland-protocols
      wlroots
    ];

    # Enable Niri as a display manager session
    programs.niri = {
      enable = true;
    };

    # Wayland environment variables for electron/chromium apps
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      ELECTRON_ENABLE_WAYLAND = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # XDG portal configuration for Wayland
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config = {
        common.default = "gtk";
        niri.default = ["gtk"];
      };
    };

    # Enable seat management for Wayland
    services.greetd = {
      enable = mkDefault true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
        };
      };
    };
  };
}
