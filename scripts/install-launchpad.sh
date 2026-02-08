#!/usr/bin/env bash
# Installation script for launchpad NixOS system
#
# WARNING: This script will ERASE ALL DATA on /dev/nvme0n1
# Only run this on the target machine, NOT on your current system!
#
# Usage:
#   1. Boot NixOS installer ISO on target machine
#   2. Copy this script and the flake to the installer
#   3. Review and edit configuration as needed
#   4. Run: sudo ./install-launchpad.sh

set -e  # Exit on error
set -u  # Exit on undefined variable

# Configuration
DISK="/dev/nvme0n1"
FLAKE_REPO="https://github.com/vandy135/titan-os.git"
FLAKE_DIR="/tmp/titan-os"
HOST="launchpad"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}NixOS Installation for $HOST${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""

# Safety check - verify we're not on the running system
if mount | grep -q "/mnt/titan-os"; then
    echo -e "${RED}ERROR: This appears to be your running system!${NC}"
    echo -e "${RED}This script should only be run from a NixOS installer ISO.${NC}"
    exit 1
fi

# Verify disk exists
if [ ! -b "$DISK" ]; then
    echo -e "${RED}ERROR: Disk $DISK not found!${NC}"
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL
    exit 1
fi

# Final confirmation
echo -e "${RED}WARNING: This will ERASE ALL DATA on $DISK${NC}"
echo ""
lsblk "$DISK"
echo ""
read -p "Are you absolutely sure you want to continue? (type 'yes' to proceed): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Installation aborted."
    exit 0
fi

echo ""
echo -e "${GREEN}Step 1: Cloning flake repository...${NC}"
if [ -d "$FLAKE_DIR" ]; then
    echo "Removing existing $FLAKE_DIR"
    rm -rf "$FLAKE_DIR"
fi
git clone "$FLAKE_REPO" "$FLAKE_DIR"
cd "$FLAKE_DIR"

echo ""
echo -e "${GREEN}Step 2: Cleaning disk and removing old signatures...${NC}"
echo "Wiping filesystem signatures from $DISK"
sudo wipefs -a "$DISK" || true
echo "Zeroing first 100MB of disk"
sudo dd if=/dev/zero of="$DISK" bs=1M count=100 status=progress || true
sync

echo ""
echo -e "${GREEN}Step 3: Running disko to partition and format disk...${NC}"
echo "This will:"
echo "  - Create GPT partition table"
echo "  - Create 2GB EFI partition"
echo "  - Create 32GB swap partition"
echo "  - Create btrfs root with subvolumes"
echo ""
sleep 3
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
    --mode disko \
    "$FLAKE_DIR/hosts/$HOST/disko-config.nix"

echo ""
echo -e "${GREEN}Step 4: Installing NixOS...${NC}"
sudo nixos-install --flake "$FLAKE_DIR#$HOST"

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Remove the installer USB"
echo "  2. Run: reboot"
echo "  3. Set user password after first boot: passwd titan"
echo ""
echo -e "${YELLOW}Note: You may want to configure SSH keys and other secrets${NC}"
echo -e "${YELLOW}before rebooting for easier remote management.${NC}"
