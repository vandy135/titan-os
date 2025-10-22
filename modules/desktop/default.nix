{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./niri.nix
    ./waybar.nix
    ./mako.nix
    ./dunst.nix
    ./rofi.nix
    ./fuzzel.nix
    ./anyrun.nix
    ./swaybg.nix
    ./swayidle.nix
    ./swaylock.nix
    ./xwayland-satellite.nix
    ./greetd.nix
    ./firefox.nix
  ];
}
