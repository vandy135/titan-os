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

      environment.systemPackages = with channelPkgs; [
        gnome-keyring
        libsecret   # secret-tool CLI for keyring access
        seahorse    # GUI keyring manager
      ];

      # Faillock: disable lockout (deny=0 = unlimited attempts)
      security.pam.services.login.faillock = {
        enable = true;
        deny = 0;
      };

      security.pam.services.sudo.faillock = {
        enable = true;
        deny = 0;
      };

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
              ExecStart = "${channelPkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets,ssh,pkcs11";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

          # Set SSH_AUTH_SOCK for keyring SSH agent
          home.sessionVariables = {
            SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
          };
        })
      ];
    };
  }
