{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./kitty.nix
    ./alacritty.nix
    ./fish.nix
    ./starship.nix
  ];
}
