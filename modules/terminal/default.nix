{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./alacritty.nix
    ./fish.nix
    ./starship.nix
  ];
}
