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
  cfg = config.modules.terminal.starship;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "starship" ];
    description = "Starship - Minimal, fast, and customizable prompt";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [ channelPkgs.starship ];

      home-manager.sharedModules = [
        ({...}: {
          programs.starship = {
            enable = true;
            enableFishIntegration = true;
            enableZshIntegration = true;
            settings = {
              # Left prompt:  nf-dev-nixos  nf-fa-flask  ../../parent/current (git)
              format = lib.concatStrings [
                "[](bold blue) "     # nf-dev-nixos
                "[](bold purple) "   # nf-fa-flask
                "$directory"
                "$git_branch"
                "$git_status"
                "$character"
              ];

              # Right prompt: (language icon + version) (time)
              right_format = lib.concatStrings [
                "$rust"
                "$nodejs"
                "$python"
                "$nix_shell"
                "$lua"
                "$golang"
                "$java"
                "$dotnet"
                "$time"
              ];

              character = {
                success_symbol = "[❯](bold green)";
                error_symbol = "[❯](bold red)";
                vimcmd_symbol = "[❮](bold blue)";
              };

              directory = {
                truncation_length = 3;
                truncation_symbol = "…/";
                style = "bold cyan";
                read_only = " 󰌾";
              };

              git_branch = {
                format = "[$symbol$branch]($style) ";
                symbol = " ";
                style = "bold purple";
                truncation_length = 30;
              };

              git_status = {
                format = "([$all_status$ahead_behind]($style) )";
                style = "bold red";
                conflicted = "=";
                ahead = "⇡$count";
                behind = "⇣$count";
                diverged = "⇕⇡$ahead_count⇣$behind_count";
                untracked = "?$count";
                stashed = "\\$$count";
                modified = "!$count";
                staged = "+$count";
                renamed = "»$count";
                deleted = "✘$count";
              };

              # Language modules (right prompt)
              rust = {
                format = "[ $version](bold orange) ";
                symbol = "";
              };

              nodejs = {
                format = "[ $version](bold green) ";
                symbol = "";
              };

              python = {
                format = "[ $version](bold yellow) ";
                symbol = "";
              };

              nix_shell = {
                format = "[ $state](bold blue) ";
                symbol = "";
              };

              lua = {
                format = "[ $version](bold blue) ";
                symbol = "";
              };

              golang = {
                format = "[ $version](bold cyan) ";
                symbol = "";
              };

              java = {
                format = "[ $version](bold red) ";
                symbol = "";
              };

              dotnet = {
                format = "[󰪮 $version](bold purple) ";
                symbol = "󰪮";
              };

              time = {
                disabled = false;
                format = "[$time](dimmed white)";
                time_format = "%H:%M";
              };

              # Disable modules we don't need in left prompt
              username.disabled = true;
              hostname.disabled = true;
              package.disabled = true;
              cmd_duration.disabled = true;
            };
          };
        })
      ];
    };
  }
