{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.system.containers;
in {
  options.modules.system.containers = {
    enable = mkEnableOption "Container runtime (Podman + Docker compat)";
  };

  config = mkIf cfg.enable {
    # Podman (rootless, daemonless)
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Docker (traditional daemon-based)
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Add user to docker group
    users.extraGroups.docker.members = [ "titan" ];

    # Useful container tools
    environment.systemPackages = with pkgs; [
      docker-compose   # Docker Compose v2
      podman-compose   # Podman compose compat
      podman-tui       # TUI for managing containers
      dive             # Explore docker image layers
      skopeo           # Container image operations
      lazydocker       # TUI for Docker
    ];

    # Enable container networking
    networking.firewall.interfaces."podman*" = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}
