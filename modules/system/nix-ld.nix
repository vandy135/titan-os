{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.system.nix-ld;
in {
  options.modules.system.nix-ld = {
    enable = mkEnableOption "nix-ld - run dynamically linked binaries (uv Python, VS Code server, etc.)";
    extraLibraries = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional libraries to expose to nix-ld-managed binaries.";
    };
  };

  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs;
        [
          stdenv.cc.cc.lib
          zlib
          openssl
          expat
          libffi
          xz
          bzip2
          sqlite
          ncurses
          readline
          libxcrypt-legacy
          icu
          libGL
          libxkbcommon
          glib
          nss
          nspr
          dbus
          fuse3
          util-linux
        ]
        ++ (with pkgs.xorg; [
          libX11
          libXcursor
          libXrandr
          libXi
          libXext
          libXrender
          libXtst
          libXScrnSaver
        ])
        ++ cfg.extraLibraries;
    };
  };
}
