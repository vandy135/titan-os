{
  config,
  lib,
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
  };
}
