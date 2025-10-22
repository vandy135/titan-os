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
    enable = mkEnableOption "Greetd - Display manager with tuigreet greeter";
  };

  config = mkIf cfg.enable {
    # Enable greetd display manager with tuigreet (terminal UI)
    # Note: This overrides the default tuigreet configuration from niri module
    services.greetd = {
      enable = mkForce true;
      settings = {
        default_session = mkForce {
          # Use tuigreet - simple terminal-based greeter
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

    # Configure available sessions for tuigreet
    environment.etc."greetd/environments".text = ''
      niri-session
    '';
  };
}
