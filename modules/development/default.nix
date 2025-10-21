{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./claude-code.nix
    ./codex.nix
  ];
}
