# NixOS system configuration for fob-titan
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
    ../../modules
  ];

  # Example host-level module/channel overrides
  modules.utilities.cli-tools.enable = true;
  modules.utilities.yazi.enable = true;

  home-manager.users.titan = import ./home.nix;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "fob-titan";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.titan = {
    isNormalUser = true;
    description = "Titan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
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

  system.stateVersion = "25.05";
}
