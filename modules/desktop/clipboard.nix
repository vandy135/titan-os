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
  cfg = config.modules.desktop.clipboard;
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "desktop" "clipboard" ];
    description = "Clipboard manager (cliphist + wl-clipboard)";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = with channelPkgs; [
        wl-clipboard-rs   # Wayland clipboard (Rust impl)
        cliphist           # Clipboard history manager
      ];

      # Start cliphist listener with the session
      home-manager.sharedModules = [
        ({...}: {
          systemd.user.services.cliphist = {
            Unit = {
              Description = "Clipboard history service";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${channelPkgs.wl-clipboard-rs}/bin/wl-paste --watch ${channelPkgs.cliphist}/bin/cliphist store";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };
        })
      ];
    };
  }
