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
  cfg = config.modules.terminal.zsh;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "zsh" ];
    description = "Zsh - POSIX-compatible shell with plugins";
    mkConfig = {channelPkgs, ...}: {
      programs.zsh.enable = true;

      environment.systemPackages = with channelPkgs; [
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-completions
        fzf
      ];

      home-manager.sharedModules = [
        ({...}: {
          programs.zsh = {
            enable = true;
            autosuggestion.enable = true;
            syntaxHighlighting.enable = true;
            enableCompletion = true;

            history = {
              size = 50000;
              save = 50000;
              ignoreDups = true;
              ignoreAllDups = true;
              ignoreSpace = true;
              extended = true;
              share = true;
            };

            initContent = ''
              # Vi mode
              bindkey -v
              bindkey '^R' history-incremental-search-backward
              bindkey '^A' beginning-of-line
              bindkey '^E' end-of-line
              bindkey '^K' kill-line
              bindkey '^W' backward-kill-word

              # fzf integration
              if command -v fzf &>/dev/null; then
                eval "$(fzf --zsh)"
              fi

              # Better completion
              zstyle ':completion:*' menu select
              zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
              zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
              zstyle ':completion:*' group-name '''
              zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
            ''
            + optionalString themeEnabled ''
              # Theme colors for zsh-syntax-highlighting
              typeset -A ZSH_HIGHLIGHT_STYLES
              ZSH_HIGHLIGHT_STYLES[command]='fg=#${palette.primary}'
              ZSH_HIGHLIGHT_STYLES[alias]='fg=#${palette.primary}'
              ZSH_HIGHLIGHT_STYLES[builtin]='fg=#${palette.primary}'
              ZSH_HIGHLIGHT_STYLES[function]='fg=#${palette.primary}'
              ZSH_HIGHLIGHT_STYLES[precommand]='fg=#${palette.accent},underline'
              ZSH_HIGHLIGHT_STYLES[path]='fg=#${palette.text},underline'
              ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#${palette.success}'
              ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#${palette.success}'
              ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#${palette.success}'
              ZSH_HIGHLIGHT_STYLES[redirection]='fg=#${palette.secondary}'
              ZSH_HIGHLIGHT_STYLES[comment]='fg=#${palette.subtext0}'
              ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#${palette.error}'
            '';

            shellAliases = {
              ls = "ls --color=auto";
              ll = "ls -lah";
              la = "ls -A";
              ".." = "cd ..";
              "..." = "cd ../..";
              grep = "grep --color=auto";
            };
          };

          programs.fzf = {
            enable = true;
            enableZshIntegration = true;
          };
        })
      ];
    };
  }
