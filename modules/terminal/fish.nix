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
  cfg = config.modules.terminal.fish;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "fish" ];
    description = "Fish shell - Smart and user-friendly command line shell";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = with channelPkgs; [
        fish
        fishPlugins.fzf-fish
        fishPlugins.done
        fishPlugins.grc
        grc
      ];
      programs.fish.enable = true;

      home-manager.sharedModules = [
        ({...}: {
          programs.fish = {
            enable = true;

            shellAbbrs = {
              # Navigation
              ".." = "cd ..";
              "..." = "cd ../..";
              "...." = "cd ../../..";

              # Git
              g = "git";
              ga = "git add";
              gaa = "git add -A";
              gc = "git commit";
              gcm = "git commit -m";
              gco = "git checkout";
              gd = "git diff";
              gds = "git diff --staged";
              gl = "git log --oneline --graph --decorate -20";
              gp = "git push";
              gpl = "git pull";
              gs = "git status";
              gb = "git branch";
              gsw = "git switch";
              gst = "git stash";
              gstp = "git stash pop";
              lg = "lazygit";

              # NixOS
              nrs = "sudo nixos-rebuild switch --flake .";
              nrt = "sudo nixos-rebuild test --flake .";
              nfu = "nix flake update";
              nfs = "nix flake show";
              nss = "nix search nixpkgs";
              ngc = "sudo nix-collect-garbage -d";
            };

            shellAliases = {
              # Modern CLI replacements
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

              # Quick access
              flake = "cd ~/.flakes/titan-os";
              vim = "nvim";
              v = "nvim";
            };

            interactiveShellInit = ''
              # SSH agent + auto-load keys
              if not set -q SSH_AGENT_PID
                eval (ssh-agent -c) >/dev/null 2>&1
              end
              if test -f ~/.ssh/id_ed25519_github; and not ssh-add -l 2>/dev/null | grep -q github
                ssh-add ~/.ssh/id_ed25519_github 2>/dev/null
              end

              # Disable greeting
              set -g fish_greeting

              # Vi mode
              fish_vi_key_bindings

              # Keep ctrl-r for fzf history
              bind -M insert \cr _fzf_search_history
              bind -M insert \cf _fzf_search_directory

              # Zoxide
              zoxide init fish | source

              # Direnv
              direnv hook fish | source

              # pay-respects (thefuck replacement)
              pay-respects fish --alias f | source
            ''
            + optionalString themeEnabled ''

              # Theme colors
              set -g fish_color_normal ${palette.text}
              set -g fish_color_command ${palette.primary}
              set -g fish_color_keyword ${palette.accent}
              set -g fish_color_quote ${palette.success}
              set -g fish_color_redirection ${palette.secondary}
              set -g fish_color_end ${palette.subtext1}
              set -g fish_color_error ${palette.error}
              set -g fish_color_param ${palette.text}
              set -g fish_color_comment ${palette.subtext0}
              set -g fish_color_selection --background=${palette.surface1}
              set -g fish_color_search_match --background=${palette.surface2}
              set -g fish_color_operator ${palette.warning}
              set -g fish_color_escape ${palette.info}
              set -g fish_color_autosuggestion ${palette.subtext0}
              set -g fish_color_valid_path ${palette.success}
              set -g fish_pager_color_prefix ${palette.primary}
              set -g fish_pager_color_completion ${palette.text}
              set -g fish_pager_color_description ${palette.subtext1}
              set -g fish_pager_color_selected_background --background=${palette.surface0}
            '';
          };
        })
      ];
    };
  }
