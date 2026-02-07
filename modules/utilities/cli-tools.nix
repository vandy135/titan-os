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
  cfg = config.modules.utilities.cli-tools;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "utilities" "cli-tools" ];
    description = "Essential CLI tools bundle (bat, fzf, ripgrep, zip, curl, jq, yq, zoxide)";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [
        channelPkgs.bat
        channelPkgs.fzf
        channelPkgs.ripgrep
        channelPkgs.zip
        channelPkgs.unzip
        channelPkgs.curl
        channelPkgs.jq
        channelPkgs.yq-go
        channelPkgs.zoxide
        channelPkgs.fd
        channelPkgs.eza
      ];
    };
  }
