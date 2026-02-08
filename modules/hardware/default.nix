{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./nvidia.nix
    ./wifi.nix
    ./bluetooth.nix
    ./brightness.nix
  ];
}
