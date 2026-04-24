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

  winePrefix = "$HOME/trading/primary-sc/wine";
  installPath = cfg.installPath;

  sierraChartVersion = "2899";

  # Wine registry color maps
  colorMaps = {
    catppuccin-mocha = {
      ActiveBorder = "88 91 112";
      ActiveTitle = "88 91 112";
      AppWorkSpace = "69 71 90";
      Background = "30 30 46";
      ButtonAlternativeFace = "243 139 168";
      ButtonDkShadow = "17 17 27";
      ButtonFace = "49 50 68";
      ButtonHilight = "186 194 222";
      ButtonLight = "69 71 90";
      ButtonShadow = "24 24 37";
      ButtonText = "205 214 244";
      GradientActiveTitle = "88 91 112";
      GradientInactiveTitle = "69 71 90";
      GrayText = "166 173 200";
      Hilight = "203 166 247";
      HilightText = "30 30 46";
      HotTrackingColor = "137 180 250";
      InactiveBorder = "49 50 68";
      InactiveTitle = "69 71 90";
      InactiveTitleText = "166 173 200";
      InfoText = "205 214 244";
      InfoWindow = "49 50 68";
      Menu = "49 50 68";
      MenuBar = "30 30 46";
      MenuHilight = "203 166 247";
      MenuText = "205 214 244";
      Scrollbar = "88 91 112";
      TitleText = "205 214 244";
      Window = "30 30 46";
      WindowFrame = "49 50 68";
      WindowText = "205 214 244";
    };
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
    then
      if globalThemeName == "gruvbox"
      then "gruvbox"
      else if globalThemeName == "catppuccin-mocha"
      then "catppuccin-mocha"
      else "tokyo-night"
    else cfg.colorScheme;
  selectedColorMap = colorMaps.${selectedColorScheme};
in
  lib.recursiveUpdate
  (channels.mkChannelModule {
    inherit cfg;
    optionPath = ["modules" "desktop" "sierra-chart"];
    description = "Sierra Chart - Professional trading platform (Wine 11)";
    defaultChannel = "unstable";
    mkConfig = {channelPkgs, ...}: let
      wine = channelPkgs.wineWow64Packages.stable; # Wine 11 (WoW64)
      winetricks = channelPkgs.winetricks;
      cabextract = channelPkgs.cabextract;
      unzip = channelPkgs.unzip;

      sierraChartInstaller = channelPkgs.fetchurl {
        url = "https://download2.sierrachart.com/downloads/ZipFiles/SierraChart${sierraChartVersion}.zip";
        hash = "sha256-FetCs1ucQ6FFuBP5IvbK71cBXSHfmgHMsknKZ9R1Etw=";
      };

      applyThemeCommands = lib.concatStringsSep "\n" (lib.mapAttrsToList
        (key: value: ''${wine}/bin/wine reg add "HKCU\\Control Panel\\Colors" /v "${key}" /t REG_SZ /d "${value}" /f'')
        selectedColorMap);

      # Wine 11 defaults to EGL for OpenGL; force GLX for Sierra Chart.
      # See: https://bugs.winehq.org/show_bug.cgi?id=59246
      applyWineX11Config = ''
        ${wine}/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v UseEGL /t REG_SZ /d "N" /f
        ${wine}/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v Decorated /t REG_DWORD /d 1 /f
        ${wine}/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v Managed /t REG_DWORD /d 1 /f
        ${wine}/bin/wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ThemeManager" /v ThemeActive /t REG_SZ /d "0" /f
      '';

      # One-time font/performance tuning (first-run only).
      initTuningCommands = ''
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingType /t REG_DWORD /d 2 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingGamma /t REG_DWORD /d 1400 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingOrientation /t REG_DWORD /d 1 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingContrast /t REG_DWORD /d 1200 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v LogPixels /t REG_DWORD /d 96 /f
        ${wine}/bin/wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v UseTakeFocus /t REG_SZ /d N /f

        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v DragFullWindows /t REG_SZ /d 0 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f
        ${wine}/bin/wine reg add "HKCU\\Control Panel\\Mouse" /v MouseHoverTime /t REG_SZ /d 10 /f
        ${wine}/bin/wine reg add "HKLM\\System\\CurrentControlSet\\Control\\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f
      '';

      themeEnforcementDaemon = channelPkgs.writeShellScript "sierra-chart-theme-daemon" ''
        set -euo pipefail
        export PATH="${wine}/bin:$PATH"
        export WINEPREFIX="${winePrefix}"
        export WINEARCH=win64
        while true; do
          sleep 10
          if pgrep -f "wine.*SierraChart" > /dev/null; then
            ${applyThemeCommands} > /dev/null 2>&1 || true
          fi
        done
      '';

      sierra-chart-setup = channelPkgs.writeShellScriptBin "sierra-chart-setup" ''
        set -euo pipefail

        export PATH="${wine}/bin:$PATH"
        export WINE="${wine}/bin/wine"
        export WINESERVER="${wine}/bin/wineserver"
        export WINELOADER="${wine}/bin/wine"

        WINEPREFIX="${winePrefix}"
        export WINEPREFIX
        export WINEARCH=win64
        export WINEDLLOVERRIDES="mscoree,mshtml="

        SIERRA_DIR="$WINEPREFIX/drive_c/${lib.removePrefix "C:/" installPath}"

        if [ ! -d "$WINEPREFIX" ]; then
          mkdir -p "$(dirname "$WINEPREFIX")"
          echo "Creating new Wine prefix at $WINEPREFIX"
          ${wine}/bin/wineboot --init

          echo "Installing core Windows fonts..."
          ${winetricks}/bin/winetricks --unattended corefonts

          echo "Applying font smoothing + performance tuning..."
          ${initTuningCommands}

          echo "Configuring Wine X11 driver (GLX backend, no Windows theme)..."
          ${applyWineX11Config}

          ${lib.optionalString cfg.theme ''
          echo "Applying ${selectedColorScheme} theme colors..."
          ${applyThemeCommands}
          ''}

          mkdir -p "$SIERRA_DIR"
        else
          echo "Wine prefix already exists. Re-applying config..."
          ${applyWineX11Config}
          ${lib.optionalString cfg.theme ''
          # Remove malformed LOGFONTW blobs written by previous module versions.
          for v in MenuFont StatusFont MessageFont CaptionFont; do
            ${wine}/bin/wine reg delete "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v "$v" /f >/dev/null 2>&1 || true
          done
          ${applyThemeCommands}
          ''}
        fi

        if [ ! -f "$SIERRA_DIR/SierraChart_64.exe" ] && [ "''${SIERRA_CHART_AUTO_EXTRACT:-1}" = "1" ]; then
          echo "Extracting Sierra Chart ${sierraChartVersion}..."
          ${unzip}/bin/unzip -q -o "${sierraChartInstaller}" -d "$SIERRA_DIR"
        fi

        if [ -f "$SIERRA_DIR/SierraChart_64.exe" ]; then
          echo "Sierra Chart ready at: $SIERRA_DIR"
        else
          echo ""
          echo "Sierra Chart not installed in $SIERRA_DIR"
          echo "Extract the ZIP manually or re-run 'sierra-chart-setup'."
        fi
      '';

      sierra-chart-run = channelPkgs.writeShellScriptBin "sierra-chart" ''
        set -euo pipefail

        export PATH="${wine}/bin:$PATH"
        export WINE="${wine}/bin/wine"
        export WINESERVER="${wine}/bin/wineserver"
        export WINELOADER="${wine}/bin/wine"

        export WINEPREFIX="${winePrefix}"
        export WINEARCH=win64
        export WINEDLLOVERRIDES="mscoree,mshtml="
        export WINEDEBUG="-all"

        export WINE_CPU_TOPOLOGY="8:2"
        export STAGING_SHARED_MEMORY=1
        export FREETYPE_PROPERTIES="truetype:interpreter-version=40 cff:no-stem-darkening=0 autofitter:warping=1 truetype:stem-darkening-properties=x-height-snapping-exceptions truetype:increase-x-height=0"
        export WINE_LARGE_ADDRESS_AWARE=1
        export STAGING_RT_PRIORITY_BASE=90
        export STAGING_RT_PRIORITY_SERVER=95
        export MESA_GL_VERSION_OVERRIDE=4.5
        export __GL_THREADED_OPTIMIZATIONS=1
        export __GL_SYNC_TO_VBLANK=0

        SIERRA_DIR="$WINEPREFIX/drive_c/${lib.removePrefix "C:/" installPath}"
        EXE_PATH="$SIERRA_DIR/SierraChart_64.exe"

        if [ ! -d "$WINEPREFIX" ] || [ ! -f "$EXE_PATH" ]; then
          ${sierra-chart-setup}/bin/sierra-chart-setup
        fi

        if [ ! -f "$EXE_PATH" ]; then
          echo "Sierra Chart not found in $SIERRA_DIR"
          exit 1
        fi

        ${applyWineX11Config} >/dev/null 2>&1 || true

        ${lib.optionalString cfg.theme ''
        ${applyThemeCommands} >/dev/null 2>&1 || true

        ${themeEnforcementDaemon} &
        DAEMON_PID=$!
        cleanup() { kill $DAEMON_PID 2>/dev/null || true; }
        trap cleanup EXIT
        ''}

        cd "$SIERRA_DIR"
        exec ${wine}/bin/wine SierraChart_64.exe "$@"
      '';

      desktopItem = channelPkgs.makeDesktopItem {
        name = "sierra-chart";
        desktopName = "Sierra Chart";
        comment = "Professional Trading & Charting (Wine 11)";
        exec = "sierra-chart";
        icon = "wine";
        categories = ["Office" "Finance"];
        terminal = false;
        startupWMClass = "sierrachart_64.exe";
      };
    in {
      hardware.graphics.enable32Bit = true;

      environment.systemPackages = [
        sierra-chart-run
        sierra-chart-setup
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
        default = true;
        description = "Apply a custom color theme to the Wine prefix.";
      };
      colorScheme = mkOption {
        type = types.enum ["auto" "tokyo-night" "gruvbox" "catppuccin-mocha"];
        default = "auto";
        description = "Wine color scheme for Sierra Chart. 'auto' picks the scheme that matches modules.theme.name (catppuccin-mocha / gruvbox), falling back to tokyo-night.";
      };
    };
  }
