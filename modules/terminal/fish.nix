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
      environment.systemPackages = [ channelPkgs.fish ];
      programs.fish.enable = true;

      home-manager.sharedModules = mkIf themeEnabled [
        ({...}: {
          programs.fish = {
            enable = true;
            interactiveShellInit = ''
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
