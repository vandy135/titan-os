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
  cfg = config.modules.terminal.cli-tools;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
  # Map palette names to tool-specific theme names
  batTheme = {
    gruvbox = "gruvbox-dark";
    everforest = "gruvbox-dark";
    catppuccin-mocha = "Catppuccin Mocha";
    catppuccin-macchiato = "Catppuccin Macchiato";
    dracula = "Dracula";
    nordic = "Nord";
    tokyo-night = "gruvbox-dark";
  }.${palette.name or "gruvbox"} or "gruvbox-dark";

  btopTheme = {
    gruvbox = "gruvbox_dark";
    everforest = "everforest-dark-hard";
    catppuccin-mocha = "catppuccin_mocha";
    catppuccin-macchiato = "catppuccin_macchiato";
    dracula = "dracula";
    nordic = "nord";
    tokyo-night = "tokyo-night";
  }.${palette.name or "gruvbox"} or "Default";

  deltaTheme = batTheme; # delta uses same theme names as bat
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "cli-tools" ];
    description = "Modern CLI tools - bat, eza, fd, ripgrep, etc.";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = with channelPkgs; [
        bat          # better cat
        eza          # better ls (with icons)
        fd           # better find
        ripgrep      # better grep
        tldr         # quick man pages
        zoxide       # better cd
        dust         # better du
        duf          # better df
        btop         # better htop
        delta        # better diff
        procs        # better ps
        jq           # JSON
        yq-go        # YAML
        httpie       # better curl
        trashy       # trash-cli (recoverable deletes)
        zip          # zip creation
        unzip        # zip extraction
        p7zip        # 7z support
        gnutar       # tar
        gzip         # gz
        xz           # xz/lzma
        zstd         # zstd compression
      ];

      home-manager.sharedModules = [
        ({...}: {
          programs.direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;  # Cached nix-shell/flake environments
          };

          programs.bat = {
            enable = true;
            config = {
              pager = "less -FR";
            } // optionalAttrs themeEnabled {
              theme = batTheme;
            };
          };

          programs.eza = {
            enable = true;
            icons = "auto";
            git = true;
            extraOptions = [
              "--group-directories-first"
            ];
          };

          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
          };

          programs.ripgrep = {
            enable = true;
          };

          programs.fd = {
            enable = true;
          };

          programs.btop = {
            enable = true;
            settings = {
              color_theme = if themeEnabled then btopTheme else "Default";
              vim_keys = true;
              shown_boxes = "cpu mem net proc";
            };
          };

          programs.delta = mkIf themeEnabled {
            enable = true;
            enableGitIntegration = true;
            options = {
              syntax-theme = deltaTheme;
              line-numbers = true;
              side-by-side = false;
              navigate = true;
            };
          };

          # Shell aliases wired into zsh
          programs.zsh.shellAliases = {
            cat = "bat";
            ls = "eza --icons";
            ll = "eza --icons -lah";
            la = "eza --icons -a";
            lt = "eza --icons --tree --level=2";
            grep = "rg";
            find = "fd";
            du = "dust";
            df = "duf";
            ps = "procs";
            top = "btop";
            rm = "trash put";
            cd = "z";
          };
        })
      ];
    };
  }
