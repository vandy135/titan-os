{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./vesktop.nix
    ./zoom.nix
  ];
}
