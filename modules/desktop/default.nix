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
    ./rofi.nix
    ./fuzzel.nix
    ./swaybg.nix
    ./swayidle.nix
    ./swaylock.nix
    ./xwayland-satellite.nix
    ./greetd.nix
  ];
}
