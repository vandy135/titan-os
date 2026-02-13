{
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.system.pam;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "system" "pam" ];
    description = "PAM configuration with gnome-keyring and faillock settings";
    mkConfig = {channelPkgs, ...}: {
      # gnome-keyring for credential storage (SSH keys, WiFi passwords, etc.)
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.enableGnomeKeyring = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.sddm.enableGnomeKeyring = true;

      environment.systemPackages = with channelPkgs; [
        gnome-keyring
        libsecret   # secret-tool CLI for keyring access
        seahorse    # GUI keyring manager
      ];

      # Faillock: brute-force protection
      # 5 failed attempts within 15min → lock for 15min
      environment.etc."security/faillock.conf".text = ''
        deny = 5
        fail_interval = 900
        unlock_time = 900
      '';

      # Auto-unlock keyring on login
      home-manager.sharedModules = [
        ({...}: {
          # Ensure gnome-keyring-daemon starts with the session
          systemd.user.services.gnome-keyring = {
            Unit = {
              Description = "GNOME Keyring daemon";
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${channelPkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets,pkcs11";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

          # SSH agent handled by fish shell (not gnome-keyring)
        })
      ];
    };
  }
