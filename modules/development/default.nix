{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./claude-code.nix
    ./codex.nix
    ./dbeaver.nix
    ./nvf.nix
  ];
}
