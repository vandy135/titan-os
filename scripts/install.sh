#!/usr/bin/env bash
# titan-os install script
# Run from NixOS live USB with internet access
# Usage: sudo ./scripts/install.sh <hostname>
# Example: sudo ./scripts/install.sh fob-aspen

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

HOST="${1:-}"

if [[ -z "$HOST" ]]; then
  echo -e "${RED}Usage: $0 <hostname>${NC}"
  echo "Available hosts:"
  ls -1 hosts/
  exit 1
fi

if [[ ! -d "hosts/$HOST" ]]; then
  echo -e "${RED}Host '$HOST' not found in hosts/${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Must run as root (sudo)${NC}"
  exit 1
fi

echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}  titan-os installer — $HOST${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo ""

# Show target disk from disko config
DISK=$(grep -oP 'device = "\K[^"]+' "hosts/$HOST/disko-config.nix" 2>/dev/null || echo "unknown")
echo -e "Target disk: ${RED}$DISK${NC}"
echo -e "${RED}⚠  THIS WILL ERASE ALL DATA ON $DISK${NC}"
echo ""
read -p "Type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

echo ""
echo -e "${GREEN}[1/4] Partitioning with disko...${NC}"
nix run github:nix-community/disko -- --mode disko "hosts/$HOST/disko-config.nix"

echo ""
echo -e "${GREEN}[2/4] Generating hardware config...${NC}"
nixos-generate-config --no-filesystems --root /mnt --show-hardware-config > "hosts/$HOST/hardware-configuration.nix"
echo "  → hosts/$HOST/hardware-configuration.nix updated"

echo ""
echo -e "${GREEN}[3/4] Installing NixOS ($HOST)...${NC}"
nixos-install --flake ".#$HOST" --no-root-password

echo ""
echo -e "${GREEN}[4/4] Done!${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo "  Set your password:  nixos-enter --root /mnt -c 'passwd titan'"
echo "  Then reboot:        reboot"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
