{
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.desktop.tradecopia;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };

  winePrefix = "$HOME/.wine-tradecopia";
  version = cfg.version;
in
  lib.recursiveUpdate
    (channels.mkChannelModule {
      inherit cfg;
      optionPath = ["modules" "desktop" "tradecopia"];
      description = "Tradecopia - Trade journaling desktop app (Wine)";
      defaultChannel = "unstable";
      mkConfig = {channelPkgs, ...}: let
        # Use X11 Wine (via XWayland) - WebView2 crashes with Wine's Wayland driver
        wine = channelPkgs.wineWow64Packages.full;
        winetricks = channelPkgs.winetricks;
        cabextract = channelPkgs.cabextract;

        tradecopia-exe = channelPkgs.fetchurl {
          url = "https://github.com/tradecopia/tradecopia-desktop/releases/download/v${version}/tradecopia_windows_x86_64.exe";
          hash = cfg.hash;
        };

        tradecopia-run = channelPkgs.writeShellScriptBin "tradecopia" ''
          export WINEPREFIX="${winePrefix}"

          # First-run: initialize prefix and install dependencies
          if [ ! -d "$WINEPREFIX" ]; then
            echo "Initializing Wine prefix at $WINEPREFIX..."
            ${wine}/bin/wineboot --init
            echo "Installing Visual C++ runtime and fonts..."
            ${winetricks}/bin/winetricks -q vcrun2019 corefonts
            echo "Wine prefix ready."
          fi

          EXE_PATH="$WINEPREFIX/drive_c/Program Files/Tradecopia Solutions Inc/Tradecopia/Tradecopia.exe"

          if [ -f "$EXE_PATH" ]; then
            exec ${wine}/bin/wine "$EXE_PATH" "$@"
          else
            echo "Tradecopia is not installed yet. Running installer..."
            ${wine}/bin/wine ${tradecopia-exe}
            echo ""
            echo "Installation complete. Run 'tradecopia' again to launch."
          fi
        '';

        desktopItem = channelPkgs.makeDesktopItem {
          name = "tradecopia";
          desktopName = "Tradecopia";
          comment = "Trade journaling and analytics (Wine)";
          exec = "tradecopia";
          icon = "wine";
          categories = ["Office" "Finance"];
          terminal = false;
        };
      in {
        hardware.graphics.enable32Bit = true;

        environment.systemPackages = [
          tradecopia-run
          desktopItem
          wine
          winetricks
          cabextract
        ];
      };
    })
    {
      options.modules.desktop.tradecopia = {
        version = mkOption {
          type = types.str;
          default = "1.30.6";
          description = "Tradecopia version to install.";
        };
        hash = mkOption {
          type = types.str;
          default = "sha256-DYSAq7ZnAQvNwSuE3t6fBYfC7qS8/+1bo+FgMfdqnms=";
          description = "SRI hash of the Tradecopia exe. Set to empty string to get the correct hash on first build.";
        };
      };
    }
