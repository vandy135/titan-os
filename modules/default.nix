{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./desktop
    ./development
    ./terminal
    ./utilities
    ./communication
    ./hardware
    ./system
    ./theme
  ];
}
