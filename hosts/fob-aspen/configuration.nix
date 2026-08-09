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
    ./asus.nix
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
    google-chrome.enable = true;
    sierra-chart = {
      enable = false;
      channel = "stable";
    };
  };

  modules.development = {
    claude-code.enable = true;
    codex.enable = true;
    containers.enable = true;
    nvf.enable = true;
    datagrip.enable = true;
    dbeaver.enable = true;
    dbeaver.channel = "stable";
    bun.enable = true;
    nodejs.enable = true;
    python.enable = true;
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
    nix-ld.enable = true;
  };

  modules.hardware.nvidia = {
    enable = true;
    powerManagement = true;  # laptop
    # Hybrid graphics: the AMD Radeon 890M iGPU drives the internal eDP panel; the
    # RTX 4050 is an on-demand offload GPU (run apps with `nvidia-offload <app>`).
    prime = {
      enable = true;
      amdgpuBusId = "PCI:197:0:0";  # Radeon 890M @ 0000:c5:00.0
      nvidiaBusId = "PCI:196:0:0";  # RTX 4050  @ 0000:c4:00.0
    };
  };

  modules.hardware.bluetooth.enable = true;
  modules.hardware.brightness.enable = true;

  modules.hardware.wifi = {
    enable = true;
    powersave = false;      # MediaTek MT7925 (Wi-Fi 7) — keep powersave off for stability
    backend = "iwd";        # iwd backend (NetworkManager); fine for MT7925
    autoConnect = "Titan";  # Auto-reconnect on boot
  };

  home-manager.users.titan = import ./home.nix;

  # Newest kernel that still builds the NVIDIA 580 module — 6.19 dropped
  # dma_map_ops.map_resource, which breaks NVIDIA 580 (see launchpad). 6.18 also
  # carries the amdxdna NPU (>=6.14), MT7925 Wi-Fi 7, and CS35L41/ACP audio fixes.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Hibernation resume is owned by disko (swap partition has resumeDevice=true,
  # which sets boot.resumeDevice). No manual resume= kernel param needed.

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  networking = {
    hostName = "fob-aspen";
    networkmanager.enable = true;
  };
}
