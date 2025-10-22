# NixOS system configuration for launchpad
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
  # Import hardware configuration and modules
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules
  ];

  # ============================================================================
  # Module Configuration - Enable desired features
  # ============================================================================

  # Desktop Environment
  modules.desktop = {
    niri.enable = true;
    waybar.enable = true;
    mako.enable = false;
    dunst.enable = true;
    rofi.enable = false;
    fuzzel.enable = false;
    anyrun.enable = true;
    swaybg.enable = true;
    swayidle.enable = true;
    swaylock.enable = true;
    xwayland-satellite.enable = true;
    greetd.enable = true;
    firefox.enable = true;
  };

  # Development Tools
  modules.development = {
    claude-code.enable = true;
    codex.enable = true;
  };

  # Terminal Environment
  modules.terminal = {
    kitty.enable = true;
    alacritty.enable = true;
    fish.enable = true;
    starship.enable = true;
  };

  # CLI Utilities
  modules.utilities = {
    cli-tools.enable = true;
    yazi.enable = true;
  };

  # Communication Apps
  modules.communication = {
    vesktop.enable = true;
    zoom.enable = true;
  };

  # ============================================================================
  # System Configuration
  # ============================================================================

  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Hibernation support - resume device configured by disko
  boot.kernelParams = [
    "resume=/dev/disk/by-partlabel/disk-main-swap"
  ];

  # Systemd sleep and hibernation configuration
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  # Networking
  networking = {
    hostName = "launchpad";
    networkmanager.enable = true;
  };

  # Timezone and internationalization
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account configuration
  users.users.titan = {
    isNormalUser = true;
    description = "Titan";
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
    shell = pkgs.fish; # Set Fish as default shell
    # Set initial password with: mkpasswd -m sha-512
    # Then manage via passwd command or consider using sops-nix for secrets
    # hashedPassword = "...";
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
  ];

  # Nix configuration
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

  # Enable sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # This value determines the NixOS release compatibility
  # Don't change this unless you know what you're doing
  system.stateVersion = "25.05";
}
