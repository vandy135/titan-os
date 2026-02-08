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
  codexTag = "rust-v0.98.0";
  codexVersion = removePrefix "rust-" codexTag;
  codexHash = "sha256-smZ5dxFkFVdRZRs6Z/v7SLZove/TUsGhVssDU4NJDUA=";

  codexBin = pkgs-edge.stdenv.mkDerivation {
    pname = "codex";
    version = codexVersion;

    src = pkgs-edge.fetchurl {
      url = "https://github.com/openai/codex/releases/download/${codexTag}/codex-x86_64-unknown-linux-gnu.tar.gz";
      hash = codexHash;
    };

    dontUnpack = true;

    nativeBuildInputs = [ pkgs-edge.autoPatchelfHook ];
    buildInputs = with pkgs-edge; [
      stdenv.cc.cc.lib  # libstdc++, libgcc_s
      openssl
      zlib
      libcap            # libcap.so.2
    ];

    installPhase = ''
      runHook preInstall
      tar -xzf $src codex-x86_64-unknown-linux-gnu
      install -Dm755 codex-x86_64-unknown-linux-gnu $out/bin/codex
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
