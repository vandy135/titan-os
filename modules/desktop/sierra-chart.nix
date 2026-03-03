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
  globalThemeName = config.modules.theme.name;

  winePrefix = "$HOME/.wine-sierra";
  installPath = cfg.installPath;

  # Wine registry color maps
  colorMaps = {
    tokyo-night = {
      ActiveBorder = "52 59 88";
      ActiveTitle = "52 59 88";
      AppWorkSpace = "36 40 59";
      Background = "26 27 38";
      ButtonAlternativeFace = "247 118 142";
      ButtonDkShadow = "15 15 20";
      ButtonFace = "52 59 88";
      ButtonHilight = "169 177 214";
      ButtonLight = "68 75 106";
      ButtonShadow = "36 40 59";
      ButtonText = "169 177 214";
      GradientActiveTitle = "52 59 88";
      GradientInactiveTitle = "36 40 59";
      GrayText = "120 127 151";
      Hilight = "115 218 202";
      HilightText = "26 27 38";
      HotTrackingColor = "122 162 247";
      InactiveBorder = "36 40 59";
      InactiveTitle = "36 40 59";
      InactiveTitleText = "120 127 151";
      InfoText = "169 177 214";
      InfoWindow = "52 59 88";
      Menu = "36 40 59";
      MenuBar = "26 27 38";
      MenuHilight = "115 218 202";
      MenuText = "169 177 214";
      Scrollbar = "68 75 106";
      TitleText = "169 177 214";
      Window = "26 27 38";
      WindowFrame = "52 59 88";
      WindowText = "169 177 214";
    };
    gruvbox = {
      ActiveBorder = "60 56 54";
      ActiveTitle = "60 56 54";
      AppWorkSpace = "29 32 33";
      Background = "40 40 40";
      ButtonAlternativeFace = "214 147 155";
      ButtonDkShadow = "20 22 23";
      ButtonFace = "60 56 54";
      ButtonHilight = "235 219 178";
      ButtonLight = "80 73 69";
      ButtonShadow = "29 32 33";
      ButtonText = "235 219 178";
      GradientActiveTitle = "60 56 54";
      GradientInactiveTitle = "29 32 33";
      GrayText = "146 131 116";
      Hilight = "131 165 152";
      HilightText = "29 32 33";
      HotTrackingColor = "254 128 25";
      InactiveBorder = "29 32 33";
      InactiveTitle = "29 32 33";
      InactiveTitleText = "146 131 116";
      InfoText = "235 219 178";
      InfoWindow = "60 56 54";
      Menu = "29 32 33";
      MenuBar = "40 40 40";
      MenuHilight = "131 165 152";
      MenuText = "235 219 178";
      Scrollbar = "80 73 69";
      TitleText = "235 219 178";
      Window = "40 40 40";
      WindowFrame = "60 56 54";
      WindowText = "235 219 178";
    };
  };

  selectedColorScheme =
    if cfg.colorScheme == "auto"
    then (if globalThemeName == "gruvbox" then "gruvbox" else "tokyo-night")
    else cfg.colorScheme;
  selectedColorMap = colorMaps.${selectedColorScheme};
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

        # Generate wine registry commands to apply theme colors
        applyThemeCommands = lib.concatStringsSep "\n" (lib.mapAttrsToList
          (key: value: ''${wine}/bin/wine reg add "HKCU\\Control Panel\\Colors" /v "${key}" /t REG_SZ /d "${value}" /f'')
          selectedColorMap);

        # One-time Wine theme setup (first-run only)
        initThemeCommands = ''
          # Disable Windows visual styles so registry colors take effect
          ${wine}/bin/wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ThemeManager" /v ThemeActive /t REG_SZ /d "0" /f
          ${wine}/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v Decorated /t REG_DWORD /d 1 /f
          ${wine}/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v Managed /t REG_DWORD /d 1 /f

          # Grayscale font smoothing (ClearType subpixel doesn't work well on Wayland)
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingType /t REG_DWORD /d 1 /f
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingGamma /t REG_DWORD /d 1800 /f

          # Set Segoe UI as system/menu font for crisp menu text
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v MenuFont /t REG_BINARY /d f4ffffff0000000000000000000000009001000053006500670065006f0065002000550049000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 /f
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v StatusFont /t REG_BINARY /d f4ffffff0000000000000000000000009001000053006500670065006f0065002000550049000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 /f
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v MessageFont /t REG_BINARY /d f4ffffff0000000000000000000000009001000053006500670065006f0065002000550049000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 /f
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v CaptionFont /t REG_BINARY /d f4ffffff0000000000000000000000009001000053006500670065006f0065002000550049000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 /f

          # DPI
          ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v LogPixels /t REG_DWORD /d 96 /f
        '';

        sierra-chart-run = channelPkgs.writeShellScriptBin "sierra-chart" ''
          export WINEPREFIX="${winePrefix}"

          # First-run: initialize prefix and install dependencies
          if [ ! -d "$WINEPREFIX" ]; then
            echo "Initializing Wine prefix at $WINEPREFIX..."
            ${wine}/bin/wineboot --init
            echo "Installing Visual C++ runtime and fonts..."
            ${winetricks}/bin/winetricks -q vcrun2019 corefonts
            ${lib.optionalString cfg.theme ''
            echo "Configuring ${selectedColorScheme} theme..."
            ${initThemeCommands}
            ''}
            echo "Wine prefix ready."
          fi

          ${lib.optionalString cfg.theme ''
          # Apply theme colors + ensure ThemeActive=0 on each launch
          ${wine}/bin/wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ThemeManager" /v ThemeActive /t REG_SZ /d "0" /f 2>/dev/null
          ${applyThemeCommands} 2>/dev/null
          ''}

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
      options.modules.desktop.sierra-chart = {
        installPath = mkOption {
          type = types.str;
          default = "C:/SierraChart";
          description = "Windows-style install path for Sierra Chart inside the Wine prefix.";
        };
        theme = mkOption {
          type = types.bool;
          default = false;
          description = "Apply a custom color theme to the Wine prefix.";
        };
        colorScheme = mkOption {
          type = types.enum ["auto" "tokyo-night" "gruvbox"];
          default = "auto";
          description = "Wine color scheme for Sierra Chart. 'auto' uses Gruvbox when modules.theme.name is gruvbox, otherwise Tokyo Night.";
        };
      };
    }
