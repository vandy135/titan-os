#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix
set -euo pipefail

# Update Codex CLI to latest GitHub release
# Usage: ./scripts/update-codex.sh

REPO="openai/codex"
MODULE="modules/development/codex.nix"
ASSET="codex-x86_64-unknown-linux-musl.tar.gz"

cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

echo "Fetching latest release from $REPO..."
LATEST=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')

if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
  echo "ERROR: Could not fetch latest release tag" >&2
  exit 1
fi

CURRENT=$(grep 'codexTag = ' "$MODULE" | sed 's/.*"\(.*\)".*/\1/')

if [ "$LATEST" = "$CURRENT" ]; then
  echo "Already up to date: $CURRENT"
  exit 0
fi

echo "Updating: $CURRENT → $LATEST"

URL="https://github.com/$REPO/releases/download/$LATEST/$ASSET"

echo "Prefetching hash..."
HASH=$(nix --extra-experimental-features 'nix-command flakes' store prefetch-file --json "$URL" | jq -r '.hash')

if [ -z "$HASH" ] || [ "$HASH" = "null" ]; then
  echo "ERROR: Could not prefetch $URL" >&2
  exit 1
fi

echo "Hash: $HASH"

# Update the module file
sed -i "s|codexTag = \".*\"|codexTag = \"$LATEST\"|" "$MODULE"
sed -i "s|codexHash = \".*\"|codexHash = \"$HASH\"|" "$MODULE"

echo "Updated $MODULE"
echo "  tag:  $LATEST"
echo "  hash: $HASH"
echo ""
echo "Run 'nrs' to rebuild."
