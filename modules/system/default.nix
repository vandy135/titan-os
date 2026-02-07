{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./pam.nix
    ./zram.nix
  ];
}
