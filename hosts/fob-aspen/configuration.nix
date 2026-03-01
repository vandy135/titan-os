# NixOS system configuration for fob-aspen
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
    ./amd.nix
    ../common/base.nix
    ../../modules
  ];

  modules.theme.name = "catppuccin-mocha";

  modules.desktop = {
    niri.enable = true;
    waybar.enable = true;
    noctalia.enable = false;
    mako.enable = true;
    fuzzel.enable = true;
    rofi.enable = false;
    swaybg.enable = true;
    swayidle.enable = true;
    swaylock.enable = true;
    xwayland-satellite.enable = true;
    greetd.enable = true;
    thunar.enable = true;
    screenshot.enable = true;
    clipboard.enable = true;
    zen-browser.enable = true;
    sierra-chart = {
      enable = true;
      channel = "stable";
    };
  };

  modules.development = {
    claude-code.enable = true;
    codex.enable = true;
    containers.enable = true;
    nvf.enable = true;
    dbeaver.enable = true;
  };

  modules.terminal = {
    alacritty.enable = true;
    ghostty.enable = false;
    cli-tools.enable = true;
    zsh.enable = true;
    fish.enable = true;
    starship.enable = true;
    zellij.enable = true;
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
    pam.enable = true;
    zram.enable = true;
    snapper.enable = true;
    plymouth.enable = false;
  };

  modules.hardware.nvidia = {
    enable = true;
    powerManagement = true;  # laptop
  };

  modules.hardware.bluetooth.enable = true;
  modules.hardware.brightness.enable = true;

  modules.hardware.wifi = {
    enable = true;
    powersave = false;      # MediaTek MT7922 — more reliable with powersave off
    backend = "iwd";        # Better WiFi 6E support than wpa_supplicant
    autoConnect = "Titan";  # Auto-reconnect on boot
  };

  home-manager.users.titan = import ./home.nix;

  boot.kernelParams = [
    "resume=/dev/disk/by-partlabel/disk-main-swap"
  ];

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  networking = {
    hostName = "fob-aspen";
    networkmanager.enable = true;
  };
}
