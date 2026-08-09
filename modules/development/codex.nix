{
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.development.codex;

  # Pinned release — update with scripts/update-codex.sh
  codexTag = "rust-v0.145.0";
  codexVersion = removePrefix "rust-" codexTag;
  codexHash = "sha256-v68Tybo08q12TkqRbEnPcXeuujKc8PcZ4iJ1ZvyNZio=";

  codexBin = pkgs-edge.stdenv.mkDerivation {
    pname = "codex";
    version = codexVersion;

    src = pkgs-edge.fetchurl {
      url = "https://github.com/openai/codex/releases/download/${codexTag}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = codexHash;
    };

    dontUnpack = true;

    # Upstream ships a fully static musl binary — no patching needed
    installPhase = ''
      runHook preInstall
      tar -xzf $src codex-x86_64-unknown-linux-musl
      install -Dm755 codex-x86_64-unknown-linux-musl $out/bin/codex
      runHook postInstall
    '';

    meta = {
      description = "Codex CLI (Linux x86_64) from upstream releases";
      homepage = "https://github.com/openai/codex";
      license = lib.licenses.asl20;
      platforms = [ "x86_64-linux" ];
      mainProgram = "codex";
    };
  };
in {
  options.modules.development.codex = {
    enable = mkEnableOption "Codex - OpenAI coding agent";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ codexBin ];
  };
}
