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
      ({lib, ...}: let hmLib = lib; in {
        # Force dark theme via dconf/GTK
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      } // optionalAttrs themeEnabled {
        # Deploy Zen theme files via activation script (resolves actual profile dir)
        home.activation.zenBrowserTheme = hmLib.hm.dag.entryAfter ["writeBoundary"] ''
          ZEN_DIR="$HOME/.zen"
          if [ -d "$ZEN_DIR" ] && [ -f "$ZEN_DIR/profiles.ini" ]; then
            # Extract Path= from first [Profile] section (may be 3+ lines after header)
            PROFILE_DIR=$(${pkgs.gawk}/bin/awk '/^\[Profile/{found=1} found && /^Path=/{sub(/^Path=/,""); print; exit}' "$ZEN_DIR/profiles.ini" 2>/dev/null || true)
            if [ -z "$PROFILE_DIR" ]; then
              # Fallback: glob for any profile dir (case-insensitive default match)
              PROFILE_DIR=$(find "$ZEN_DIR" -maxdepth 1 -type d -iname '*default*' 2>/dev/null | head -1 || true)
              PROFILE_DIR=''${PROFILE_DIR##*/}
            fi
            if [ -n "$PROFILE_DIR" ]; then
              TARGET="$ZEN_DIR/$PROFILE_DIR"
              mkdir -p "$TARGET/chrome"

              cat > "$TARGET/chrome/userChrome.css" << 'CHROME_EOF'
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
          CHROME_EOF

              cat > "$TARGET/chrome/userContent.css" << 'CONTENT_EOF'
          @-moz-document url("about:home"), url("about:newtab"), url("about:blank") {
            body {
              background-color: ${palette.base} !important;
              color: ${palette.text} !important;
            }
          }
          CONTENT_EOF

              cat > "$TARGET/user.js" << 'USERJS_EOF'
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          user_pref("ui.systemUsesDarkTheme", 1);
          user_pref("browser.theme.content-theme", 0);
          user_pref("browser.theme.toolbar-theme", 0);
          user_pref("layout.css.prefers-color-scheme.content-override", 0);
          USERJS_EOF
            fi
          fi
        '';
      })
    ];
  };
}
