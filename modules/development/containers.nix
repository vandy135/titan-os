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
  cfg = config.modules.development.containers;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };

  enableDocker = cfg.runtime == "docker" || cfg.runtime == "both";
  enablePodman = cfg.runtime == "podman" || cfg.runtime == "both";
  podmanOnly = cfg.runtime == "podman";

  channelModule = channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "development" "containers" ];
    description = "Container runtimes (Docker/Podman)";
    defaultChannel = "stable";
    mkConfig = {channelPkgs, ...}: mkMerge [
      # Docker
      (mkIf enableDocker {
        virtualisation.docker = {
          enable = true;
          enableOnBoot = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };
        users.extraGroups.docker.members = [ "titan" ];
        environment.systemPackages = [ channelPkgs.docker-compose ];
      })

      # Podman
      (mkIf enablePodman {
        virtualisation.podman = {
          enable = true;
          dockerCompat = podmanOnly;
          defaultNetwork.settings.dns_enabled = true;
        };
        # Rootless Podman support (subuid/subgid ranges)
        users.users.titan = mkIf cfg.podmanRootless {
          subUidRanges = [{ startUid = 100000; count = 65536; }];
          subGidRanges = [{ startGid = 100000; count = 65536; }];
        };
        environment.systemPackages = [ channelPkgs.podman-compose ];
        networking.firewall.interfaces."podman*" = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [ 53 ];
        };
      })

      # Common tools
      {
        environment.systemPackages = with channelPkgs; [
          dive
          skopeo
          lazydocker
        ];
      }
    ];
  };
in {
  options.modules.development.containers = {
    enable = mkEnableOption "Container runtimes (Docker/Podman)";
    channel = mkOption {
      type = types.enum [ "stable" "unstable" "edge" ];
      default = "stable";
      example = "stable";
      description = "Which nixpkgs channel this module should use.";
    };
    runtime = mkOption {
      type = types.enum [ "docker" "podman" "both" ];
      default = "docker";
      description = "Which container runtime to enable.";
    };
    podmanRootless = mkOption {
      type = types.bool;
      default = true;
      description = "Enable rootless Podman.";
    };
  };

  config = channelModule.config;
}
