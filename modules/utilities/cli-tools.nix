# Consolidated into modules/terminal/cli-tools.nix
# This module exists for backward compatibility — enabling it is a no-op
# (all packages are provided by terminal.cli-tools)
{
  config,
  lib,
  ...
}:
with lib; {
  options.modules.utilities.cli-tools = {
    enable = mkEnableOption "CLI tools (provided by terminal.cli-tools)";
    channel = mkOption {
      type = types.enum [ "stable" "unstable" "edge" ];
      default = "stable";
      description = "Unused — kept for compatibility.";
    };
  };

  # No config — terminal/cli-tools provides everything
}
