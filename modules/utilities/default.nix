{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./cli-tools.nix
  ];
}
