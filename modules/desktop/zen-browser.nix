{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.zen-browser;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
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
      } // optionalAttrs themeEnabled {
        # Theme-aware userChrome.css for Zen Browser UI
        home.file.".zen/default/chrome/userChrome.css".text = ''
          @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

          /* Theme: ${palette.name or "custom"} */
          :root {
            --zen-primary-color: ${palette.primary} !important;
            --toolbar-bgcolor: ${palette.base} !important;
            --toolbar-color: ${palette.text} !important;
            --urlbar-background-color: ${palette.surface0} !important;
            --urlbar-color: ${palette.text} !important;
            --tab-selected-bgcolor: ${palette.surface0} !important;
            --tab-selected-textcolor: ${palette.text} !important;
            --lwt-accent-color: ${palette.base} !important;
            --lwt-text-color: ${palette.text} !important;
            --sidebar-background-color: ${palette.mantle} !important;
            --sidebar-text-color: ${palette.text} !important;
          }
        '';

        # userContent.css for web content (new tab, etc.)
        home.file.".zen/default/chrome/userContent.css".text = ''
          @-moz-document url("about:home"), url("about:newtab"), url("about:blank") {
            body {
              background-color: ${palette.base} !important;
              color: ${palette.text} !important;
            }
          }
        '';

        # Enable userChrome.css loading
        home.file.".zen/default/user.js".text = ''
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          user_pref("ui.systemUsesDarkTheme", 1);
          user_pref("browser.theme.content-theme", 0);
          user_pref("browser.theme.toolbar-theme", 0);
          user_pref("layout.css.prefers-color-scheme.content-override", 0);
        '';
      })
    ];
  };
}
