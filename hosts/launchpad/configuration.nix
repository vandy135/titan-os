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
    ../common/base.nix
    ../../modules
  ];

  modules.theme.name = "gruvbox";

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
    cli-tools.enable = true;
    ghostty.enable = false;
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
    snapper.enable = false;  # ZFS, not btrfs
    plymouth.enable = false;
  };

  modules.hardware.nvidia = {
    enable = true;
  };
  modules.hardware.bluetooth.enable = true;

  # Auto-connect EDIFIER R1280DB on boot (trust + connect with retry)
  systemd.services.bt-autoconnect-edifier = {
    description = "Auto-connect EDIFIER R1280DB Bluetooth";
    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.bluez}/bin/bluetoothctl power on && ${pkgs.bluez}/bin/bluetoothctl trust FC:E8:06:6E:1A:27 && for i in 1 2 3 4 5; do ${pkgs.bluez}/bin/bluetoothctl connect FC:E8:06:6E:1A:27 && break || sleep 3; done'";
    };
    unitConfig = {
      StartLimitIntervalSec = 120;
      StartLimitBurst = 5;
    };
  };

  home-manager.users.titan = import ./home.nix;

  # Note: hibernation disabled — swap uses randomEncryption (non-resumable)
  # To enable hibernation, switch to persistent encrypted swap with a key file
  boot.kernelParams = [];

  systemd.sleep.extraConfig = ''
    SuspendState=mem
  '';

  networking = {
    hostName = "launchpad";
    hostId = "c9ed046a";
    networkmanager.enable = true;
  };

  # ZFS auto-snapshots (replaces snapper for btrfs)
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 4;    # every 15min, keep 4
    hourly = 24;
    daily = 7;
    weekly = 4;
    monthly = 6;
  };
}
