# Shared host configuration — settings common to all machines
{ pkgs, ... }: {
  # Don't block boot waiting for network
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.titan = {
    isNormalUser = true;
    description = "Titan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Registry pinning handled in flake.nix via specialArgs
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 20;  # bound /boot (ESP) usage across generations
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "25.11";
}
