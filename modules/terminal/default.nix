{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./kitty.nix
    ./fish.nix
    ./starship.nix
  ];
}
