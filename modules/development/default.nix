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
    ./gemini-cli.nix
    ./nodejs.nix
    ./nvf.nix
    ./python.nix
  ];
}
