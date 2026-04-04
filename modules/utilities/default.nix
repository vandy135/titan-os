{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./yazi.nix
  ];
}
