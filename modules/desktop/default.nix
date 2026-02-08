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
    ./fuzzel.nix
    ./rofi.nix
    ./swaybg.nix
    ./swayidle.nix
    ./swaylock.nix
    ./thunar.nix
    ./xwayland-satellite.nix
    ./greetd.nix
    ./firefox.nix
    ./zen-browser.nix
  ];
}
