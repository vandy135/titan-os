{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./nvidia.nix
  ];
}
