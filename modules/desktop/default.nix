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
    ./swaybg.nix
    ./swayidle.nix
    ./swaylock.nix
    ./xwayland-satellite.nix
    ./greetd.nix
    ./firefox.nix
    ./zen-browser.nix
  ];
}
