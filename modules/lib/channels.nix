{
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}:
with lib; let
  validChannels = [ "stable" "unstable" "edge" ];

  forChannel = channel:
    if channel == "stable"
    then pkgs-stable
    else if channel == "edge"
    then pkgs-edge
    else pkgs-unstable;

  mkChannelModule = {
    cfg,
    optionPath,
    description,
    defaultChannel ? "unstable",
    mkConfig,
  }: {
    options = setAttrByPath optionPath {
      enable = mkEnableOption description;
      channel = mkOption {
        type = types.enum validChannels;
        default = defaultChannel;
        example = "stable";
        description = "Which nixpkgs channel this module should use.";
      };
    };

    config = mkIf cfg.enable (
      mkConfig {
        channels = {inherit forChannel;};
        channelPkgs = forChannel cfg.channel;
      }
    );
  };
in {
  inherit forChannel mkChannelModule;
}
