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
  cfg = config.modules.desktop.sierra-chart;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };

  winePrefix = "$HOME/.wine-sierra";
  installPath = cfg.installPath;
in
  lib.recursiveUpdate
    (channels.mkChannelModule {
      inherit cfg;
      optionPath = ["modules" "desktop" "sierra-chart"];
      description = "Sierra Chart - Professional trading platform (Wine)";
      defaultChannel = "unstable";
      mkConfig = {channelPkgs, ...}: let
        wine = channelPkgs.wineWow64Packages.waylandFull;
        winetricks = channelPkgs.winetricks;
        cabextract = channelPkgs.cabextract;

        sierra-chart-run = channelPkgs.writeShellScriptBin "sierra-chart" ''
          export WINEPREFIX="${winePrefix}"

          # First-run: initialize prefix and install dependencies
          if [ ! -d "$WINEPREFIX" ]; then
            echo "Initializing Wine prefix at $WINEPREFIX..."
            ${wine}/bin/wineboot --init
            echo "Installing Visual C++ runtime and fonts..."
            ${winetricks}/bin/winetricks -q vcrun2019 corefonts
            echo "Wine prefix ready."
          fi

          EXE_PATH="$WINEPREFIX/drive_c/${lib.removePrefix "C:/" installPath}/SierraChart_64.exe"

          if [ -f "$EXE_PATH" ]; then
            exec ${wine}/bin/wine "$EXE_PATH" "$@"
          else
            echo ""
            echo "Sierra Chart is not installed yet."
            echo ""
            echo "To install, download the installer from https://www.sierrachart.com"
            echo "and run it with:"
            echo ""
            echo "  WINEPREFIX=${winePrefix} wine SierraChartSetup.exe"
            echo ""
            echo "After installation, run 'sierra-chart' again to launch."
            exit 1
          fi
        '';

        desktopItem = channelPkgs.makeDesktopItem {
          name = "sierra-chart";
          desktopName = "Sierra Chart";
          comment = "Professional Trading & Charting (Wine)";
          exec = "sierra-chart";
          icon = "wine";
          categories = ["Office" "Finance"];
          terminal = false;
        };
      in {
        hardware.graphics.enable32Bit = true;

        environment.systemPackages = [
          sierra-chart-run
          desktopItem
          wine
          winetricks
          cabextract
        ];
      };
    })
    {
      options.modules.desktop.sierra-chart.installPath = mkOption {
        type = types.str;
        default = "C:/SierraChart";
        description = "Windows-style install path for Sierra Chart inside the Wine prefix.";
      };
    }
