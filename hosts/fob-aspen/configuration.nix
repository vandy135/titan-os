# NixOS system configuration for fob-titan
{
  config,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  inputs,
  outputs,
  ...
}: {
  # Import hardware configuration
  # Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "fob-titan";
    networkmanager.enable = true;
  };

  # Timezone and internationalization
  time.timeZone = "America/New_York"; # Adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # User account configuration
  users.users.titan = {
    isNormalUser = true;
    description = "Titan";
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
    # Set initial password with: mkpasswd -m sha-512
    # Then manage via passwd command or consider using sops-nix for secrets
    # hashedPassword = "...";
  };

  # System packages
  # Example: Mix packages from different channels
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop

    # Example: Use a package from stable channel if needed
    # pkgs-stable.somePackage

    # Example: Use bleeding-edge package from master
    # pkgs-edge.newestPackage
  ];

  # Enable flakes and nix-command
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # OpenSSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22]; # SSH
  };

  # This value determines the NixOS release compatibility
  # Don't change this unless you know what you're doing
  system.stateVersion = "25.05";
}
