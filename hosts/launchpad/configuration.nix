# NixOS system configuration for launchpad
{
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules
  ];

  modules.theme.name = "tokyo-night";

  modules.desktop = {
    niri.enable = true;
    waybar.enable = true;
    mako.enable = true;
    fuzzel.enable = true;
    swaybg.enable = true;
    swayidle.enable = true;
    swaylock.enable = true;
    xwayland-satellite.enable = true;
    greetd.enable = true;
    thunar.enable = true;
    zen-browser.enable = true;
  };

  modules.development = {
    claude-code.enable = true;
    codex.enable = true;
    claude-code.channel = "edge";
    codex.channel = "edge";
    nvf.enable = true;
    dbeaver.enable = true;
  };

  modules.terminal = {
    alacritty.enable = true;
    cli-tools.enable = true;
    ghostty.enable = true;
    zsh.enable = true;
    starship.enable = true;
  };

  modules.utilities = {
    cli-tools.enable = true;
    yazi.enable = true;
  };

  modules.communication = {
    remmina.enable = true;
    rustdesk.enable = true;
    vesktop.enable = true;
    zoom.enable = true;
    zoom.channel = "stable";
  };

  modules.system = {
    containers.enable = true;
    pam.enable = true;
    zram.enable = true;
  };

  home-manager.users.titan = import ./home.nix;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [
    "resume=/dev/disk/by-partlabel/disk-main-swap"
  ];

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  networking = {
    hostName = "launchpad";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.titan = {
    isNormalUser = true;
    description = "Titan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
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

  system.stateVersion = "25.11";
}
