{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ./bun.nix
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
