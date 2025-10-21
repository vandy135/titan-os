{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.utilities.cli-tools;
in {
  options.modules.utilities.cli-tools = {
    enable = mkEnableOption "Essential CLI tools bundle (bat, fzf, ripgrep, zip, curl, jq, yq, zoxide)";
  };

  config = mkIf cfg.enable {
    # Install essential CLI tools
    environment.systemPackages = with pkgs; [
      bat # Better cat with syntax highlighting
      fzf # Fuzzy finder
      ripgrep # Fast grep alternative
      zip # Compression tool
      unzip # Decompression tool
      curl # HTTP client
      jq # JSON processor
      yq-go # YAML processor
      zoxide # Smart cd replacement
      fd # Better find alternative
      eza # Modern ls replacement
    ];
  };
}
