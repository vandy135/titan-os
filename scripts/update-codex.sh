#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/update-codex.sh [host]
# - Fetches the latest Codex release from GitHub
# - Updates modules/development/codex.nix with the new version/hash
# - Runs nixos-rebuild switch for the given host (defaults to current hostname)

host="${1:-$(hostname)}"
repo_root="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || realpath "$(dirname "$0")/..")"
module_file="$repo_root/modules/development/codex.nix"

command -v curl >/dev/null || { echo "curl required" >&2; exit 1; }
command -v jq  >/dev/null || { echo "jq required"  >&2; exit 1; }
command -v nix >/dev/null || { echo "nix required" >&2; exit 1; }

echo "Fetching latest Codex release tag..."
latest_tag="$(curl -sSf https://api.github.com/repos/openai/codex/releases/latest \
  | jq -r '.tag_name')"

if [[ -z "$latest_tag" || "$latest_tag" == "null" ]]; then
  echo "Could not find latest release tag" >&2
  exit 1
fi

asset_url="https://github.com/openai/codex/releases/download/${latest_tag}/codex-x86_64-unknown-linux-gnu.tar.gz"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Downloading $asset_url..."
curl -L -o "$tmp" "$asset_url"

sha256="$(sha256sum "$tmp" | awk '{print $1}')"
if ! sri="$(nix hash to-sri --type sha256 "$sha256" 2>/dev/null)"; then
  sri="$(nix hash convert --hash-algo sha256 --to sri "$sha256")"
fi

echo "Updating $module_file to ${latest_tag} (${sri})..."
perl -0777 -i -pe \
  "s/codexTag = \\\"[^\\\"]+\\\";/codexTag = \\\"${latest_tag}\\\";/;
   s/hash = \\\"[^\\\"]*\\\";/hash = \\\"${sri}\\\";/" \
  "$module_file"

echo "Rebuilding NixOS for host '${host}'..."
sudo nixos-rebuild switch --flake "$repo_root#${host}"
