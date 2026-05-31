{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./pam.nix
    ./zram.nix
    ./snapper.nix
    ./plymouth.nix
    ./nix-ld.nix
  ];
}
