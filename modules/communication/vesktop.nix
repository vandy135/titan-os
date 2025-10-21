{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.communication.vesktop;
in {
  options.modules.communication.vesktop = {
    enable = mkEnableOption "Vesktop - Custom Discord client with Vencord built-in";
  };

  config = mkIf cfg.enable {
    # Install Vesktop (Discord with Vencord)
    environment.systemPackages = with pkgs; [
      vesktop
    ];
  };
}
