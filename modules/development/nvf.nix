{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.development.nvf;
in {
  imports = [
    inputs.nvf.nixosModules.default
  ];

  options.modules.development.nvf = {
    enable = mkEnableOption "NVF - Modular Neovim framework";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          # Core
          viAlias = true;
          vimAlias = true;
          lineNumberMode = "relNr";
          preventJunkFiles = true;
          useSystemClipboard = true;

          # Theme
          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };

          # Telescope
          telescope.enable = true;

          # Autocomplete
          autocomplete.nvim-cmp.enable = true;

          # Languages
          languages = {
            enableLSP = true;
            enableTreesitter = true;

            nix.enable = true;
            rust = {
              enable = true;
              crates.enable = true;
            };
            ts.enable = true;
            lua.enable = true;
            markdown.enable = true;
          };

          # Visuals
          visuals = {
            nvim-web-devicons.enable = true;
            indent-blankline.enable = true;
          };

          # Status line
          statusline.lualine.enable = true;

          # Git
          git = {
            enable = true;
            gitsigns.enable = true;
          };

          # Treesitter
          treesitter.context.enable = true;
        };
      };
    };
  };
}
