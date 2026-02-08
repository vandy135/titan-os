{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.development.nvf;
  themeName = config.modules.theme.name;

  # Map titan-os palette names -> NVF theme name + style
  nvfThemeMap = {
    "catppuccin-mocha" = {
      name = "catppuccin";
      style = "mocha";
    };
    "catppuccin-macchiato" = {
      name = "catppuccin";
      style = "macchiato";
    };
    "tokyo-night" = {
      name = "tokyonight";
      style = "night";
    };
    "dracula" = {
      name = "dracula";
      style = "";
    };
    "gruvbox" = {
      name = "gruvbox";
      style = "dark";
    };
    "everforest" = {
      name = "everforest";
      style = "medium";
    };
    "nordic" = {
      name = "nord";
      style = "";
    };
    # No native NVF theme; fall back to catppuccin
    "moonfly" = {
      name = "catppuccin";
      style = "mocha";
    };
    "cargofox" = {
      name = "catppuccin";
      style = "mocha";
    };
  };

  nvfTheme = nvfThemeMap.${themeName} or {
    name = "catppuccin";
    style = "mocha";
  };
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
          lineNumberMode = "relNumber";
          preventJunkFiles = true;

          clipboard = {
            enable = true;
            registers = "unnamedplus";
          };

          # Theme (follows modules.theme.name)
          theme = {
            enable = true;
            name = nvfTheme.name;
          }
          // (optionalAttrs (nvfTheme.style != "") {
            style = nvfTheme.style;
          });

          # LSP + language support
          lsp.enable = true;

          languages = {
            enableTreesitter = true;

            nix = {
              enable = true;
              lsp.options = {
                nil.nix.flake.autoArchive = true;
              };
            };
            rust = {
              enable = true;
              extensions.crates-nvim.enable = true;
            };
            ts.enable = true;
            lua.enable = true;
            markdown.enable = true;
            csharp.enable = true;
            python.enable = true;
          };

          # Treesitter
          treesitter = {
            enable = true;
            context.enable = true;
          };

          # Telescope (file finder, grep, buffers)
          telescope.enable = true;

          # File explorer
          filetree.nvimTree.enable = true;

          # Autocomplete
          autocomplete.nvim-cmp.enable = true;

          # Git
          git = {
            enable = true;
            gitsigns.enable = true;
            vim-fugitive.enable = true;
          };

          # UI / visuals
          statusline.lualine.enable = true;

          visuals = {
            nvim-web-devicons.enable = true;
            indent-blankline.enable = true;
          };

          # Keybind helper
          binds.whichKey.enable = true;

          # Editing helpers
          autopairs.nvim-autopairs.enable = true;
          comments.comment-nvim.enable = true;
        };
      };
    };
  };
}
