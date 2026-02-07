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
    # Podman as the container runtime (rootless, daemonless)
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;       # docker CLI alias → podman
      dockerSocket.enable = true; # /var/run/docker.sock compat for tools
      defaultNetwork.settings.dns_enabled = true;
    };

    # Useful container tools
    environment.systemPackages = with pkgs; [
      podman-compose   # docker-compose compatible
      podman-tui       # TUI for managing containers
      dive             # Explore docker image layers
      skopeo           # Container image operations
    ];

    # Enable container networking
    networking.firewall.interfaces."podman*" = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}
