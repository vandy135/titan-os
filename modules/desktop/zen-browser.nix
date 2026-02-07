{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.zen-browser;
in {
  options.modules.desktop.zen-browser = {
    enable = mkEnableOption "Zen Browser - Privacy-focused Firefox fork";
    variant = mkOption {
      type = types.enum ["beta" "twilight"];
      default = "beta";
      description = "Which Zen Browser variant to install.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.${cfg.variant}
    ];

    home-manager.sharedModules = [
      ({...}: {
        # Force dark theme via dconf/GTK
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      })
    ];
  };
}
