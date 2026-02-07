{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./claude-code.nix
    ./codex.nix
    ./containers.nix
    ./dbeaver.nix
    ./nvf.nix
  ];
}
