{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.greetd;
in {
  options.modules.desktop.greetd = {
    enable = mkEnableOption "Greetd - Display manager with gtkgreet greeter";
  };

  config = mkIf cfg.enable {
    # Install gtkgreet package
    environment.systemPackages = with pkgs; [
      gtkgreet
    ];

    # Enable greetd display manager with gtkgreet
    # Note: This overrides the default tuigreet configuration from niri module
    services.greetd = {
      enable = mkForce true;
      settings = {
        default_session = mkForce {
          # Run gtkgreet in a cage compositor for proper Wayland display
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet -l -c niri-session";
          user = "greeter";
        };
      };
    };

    # Create runtime directory for greeter user
    systemd.tmpfiles.rules = [
      "d /run/user/999 0700 greeter greeter -"
    ];

    # Configure environment for gtkgreet
    environment.etc."greetd/environments".text = ''
      niri-session
    '';
  };
}
