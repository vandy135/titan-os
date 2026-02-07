{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./alacritty.nix
    ./fish.nix
    ./zsh.nix
    ./starship.nix
  ];
}
