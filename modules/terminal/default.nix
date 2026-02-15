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
    ./ghostty.nix
    ./zsh.nix
    ./starship.nix
    ./zellij.nix
  ];
}
