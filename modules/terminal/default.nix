{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./alacritty.nix
    ./cli-tools.nix
    ./fish.nix
    ./zsh.nix
    ./starship.nix
  ];
}
