{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./nvidia.nix
    ./wifi.nix
  ];
}
