{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./remmina.nix
    ./rustdesk.nix
    ./vesktop.nix
    ./zoom.nix
  ];
}
