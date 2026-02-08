{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.theme;

  palettes = {
    catppuccin-mocha = import ./palettes/catppuccin-mocha.nix;
    catppuccin-macchiato = import ./palettes/catppuccin-macchiato.nix;
    tokyo-night = import ./palettes/tokyo-night.nix;
    everforest = import ./palettes/everforest.nix;
    dracula = import ./palettes/dracula.nix;
    cargofox = import ./palettes/cargofox.nix;
    moonfly = import ./palettes/moonfly.nix;
    nordic = import ./palettes/nordic.nix;
    gruvbox = import ./palettes/gruvbox.nix;
  };

  selectedPalette = palettes.${cfg.name} or palettes.catppuccin-mocha;
in {
  options.modules.theme = {
    enable = mkEnableOption "Unified system-wide theming" // { default = true; };

    name = mkOption {
      type = types.enum (attrNames palettes);
      default = "catppuccin-mocha";
      example = "tokyo-night";
      description = "Theme palette name applied across desktop and terminal modules.";
    };

    palette = mkOption {
      type = types.attrs;
      readOnly = true;
      description = "Resolved theme palette for downstream modules.";
    };
  };

  config = mkIf cfg.enable {
    modules.theme.palette = selectedPalette;

    # System-wide dark GTK theme
    environment.variables = {
      GTK_THEME = "Adwaita:dark";
    };

    # Ensure adwaita + cursor theme available
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      papirus-icon-theme
      bibata-cursors
    ];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        # GTK dark preference via dconf
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          cursor-theme = "Bibata-Modern-Classic";
          cursor-size = lib.hm.gvariant.mkInt32 24;
        };

        # Cursor theme
        home.pointerCursor = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };

        # GTK 3 settings
        gtk = {
          enable = true;
          theme = {
            name = "Adwaita-dark";
            package = pkgs.adwaita-icon-theme;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = true;
          };
          gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = true;
          };
        };
      })
    ];
  };
}
