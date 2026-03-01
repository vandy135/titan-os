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

  winePrefix = "$HOME/.wine-trading";
  version = cfg.version;

  tradecopia-exe = pkgs.fetchurl {
    url = "https://github.com/tradecopia/tradecopia-desktop/releases/download/v${version}/tradecopia_windows_x86_64.exe";
    hash = cfg.hash;
  };

  tradecopia-run = pkgs.writeShellScriptBin "tradecopia" ''
    export WINEPREFIX="${winePrefix}"

    # First-run: initialize prefix and install dependencies
    if [ ! -d "$WINEPREFIX" ]; then
      echo "Initializing Wine prefix at $WINEPREFIX..."
      ${pkgs.wineWow64Packages.waylandFull}/bin/wineboot --init
      echo "Installing Visual C++ runtime and fonts..."
      ${pkgs.winetricks}/bin/winetricks -q vcrun2019 corefonts
      echo "Wine prefix ready."
    fi

    exec ${pkgs.wineWow64Packages.waylandFull}/bin/wine ${tradecopia-exe} "$@"
  '';

  desktopItem = pkgs.makeDesktopItem {
    name = "tradecopia";
    desktopName = "Tradecopia";
    comment = "Trade journaling and analytics (Wine)";
    exec = "tradecopia";
    icon = "wine";
    categories = ["Office" "Finance"];
    terminal = false;
  };
in
  lib.recursiveUpdate
    (channels.mkChannelModule {
      inherit cfg;
      optionPath = ["modules" "desktop" "tradecopia"];
      description = "Tradecopia - Trade journaling desktop app (Wine)";
      defaultChannel = "unstable";
      mkConfig = {channelPkgs, ...}: {
        hardware.graphics.enable32Bit = true;

        environment.systemPackages = [
          tradecopia-run
          desktopItem
          pkgs.wineWow64Packages.waylandFull
          pkgs.winetricks
          pkgs.cabextract
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
          default = "";
          description = "SRI hash of the Tradecopia exe. Set to empty string to get the correct hash on first build.";
        };
      };
    }
