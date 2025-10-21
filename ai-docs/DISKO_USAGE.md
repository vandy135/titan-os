# Disko Configuration Deployment Guide

This guide explains how to deploy the NixOS configuration with disko for automated disk partitioning and formatting.

## Overview

The launchpad host uses a disko-based configuration for declarative disk management with the following layout:

- Device: /dev/nvme0n1 (NVMe SSD)
- Boot Mode: UEFI
- Filesystem: Btrfs with subvolumes
- Swap: 32GB (hibernation-enabled)
- RAM: 32GB

## Partition Layout

```
/dev/nvme0n1
├── /dev/nvme0n1p1  512MB   EFI System Partition (FAT32)  → /boot
├── /dev/nvme0n1p2  32GB    Swap Partition                → swap (hibernation)
└── /dev/nvme0n1p3  Rest    Btrfs Root                    → / (with subvolumes)
```

## Btrfs Subvolumes

The root partition uses btrfs with the following subvolume structure:

```
@           → /              (root filesystem)
@home       → /home          (user data)
@nix        → /nix           (Nix store)
@log        → /var/log       (system logs)
@snapshots  → /.snapshots    (backup snapshots)
```

All subvolumes use:
- Compression: zstd
- Mount options: noatime, compress=zstd, space_cache=v2

## Prerequisites

1. Boot into NixOS live ISO (minimal or graphical)
2. Ensure network connectivity
3. Have your flake repository accessible (USB drive, git clone, etc.)

## Deployment Process

### Step 1: Boot into NixOS Live Environment

Boot from a NixOS ISO. You can download it from:
```
https://nixos.org/download.html
```

### Step 2: Set Up Network (if needed)

For WiFi:
```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourNetworkName"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit
```

For wired, DHCP should work automatically.

### Step 3: Verify Disk Device

Confirm your NVMe device path:
```bash
lsblk
# Should show /dev/nvme0n1
```

If your device is different (e.g., /dev/sda), update `disko-config.nix` accordingly.

### Step 4: Clone or Copy Your Flake

Option A - Clone from git:
```bash
git clone <your-repository-url> /mnt/flake
cd /mnt/flake
```

Option B - Copy from USB:
```bash
mkdir /mnt/flake
cp -r /path/to/usb/titan-os /mnt/flake/
cd /mnt/flake/titan-os
```

### Step 5: Install Disko

Disko is needed to partition and format disks based on the configuration:

```bash
nix-shell -p disko
```

### Step 6: Review Disko Configuration

IMPORTANT: Verify the disko configuration before proceeding. This will DESTROY all data on /dev/nvme0n1.

```bash
cat hosts/launchpad/disko-config.nix
```

### Step 7: Partition and Format with Disko

Run disko to create partitions and filesystems:

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko \
  hosts/launchpad/disko-config.nix
```

This command will:
1. Wipe /dev/nvme0n1
2. Create GPT partition table
3. Create EFI, swap, and btrfs partitions
4. Format partitions
5. Create btrfs subvolumes
6. Mount everything to /mnt

### Step 8: Verify Mounts

Check that all filesystems are properly mounted:

```bash
mount | grep /mnt
# Should show:
# /dev/nvme0n1p3 on /mnt type btrfs (subvol=/@)
# /dev/nvme0n1p1 on /mnt/boot type vfat
# /dev/nvme0n1p3 on /mnt/home type btrfs (subvol=/@home)
# /dev/nvme0n1p3 on /mnt/nix type btrfs (subvol=/@nix)
# /dev/nvme0n1p3 on /mnt/var/log type btrfs (subvol=/@log)
# /dev/nvme0n1p3 on /mnt/.snapshots type btrfs (subvol=/@snapshots)

swapon --show
# Should show /dev/nvme0n1p2
```

### Step 9: Generate Hardware Configuration

Generate hardware-specific configuration:

```bash
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/launchpad/hardware-configuration.nix
```

The `--no-filesystems` flag prevents overwriting disko-managed filesystem declarations.

### Step 10: Install NixOS

Install NixOS using your flake:

```bash
sudo nixos-install --flake .#launchpad
```

When prompted, set the root password.

### Step 11: Set User Password

After installation, set the user password:

```bash
sudo nixos-enter
passwd titan
exit
```

### Step 12: Reboot

```bash
reboot
```

Remove the installation media and boot into your new system.

## Post-Installation

### Verify Hibernation Setup

After booting into your new system:

1. Check swap is active:
```bash
swapon --show
cat /proc/swaps
```

2. Verify resume device is configured:
```bash
cat /proc/cmdline | grep resume
# Should show: resume=/dev/disk/by-label/swap
```

3. Check hibernation capability:
```bash
systemctl hibernate
```

The system should hibernate and resume successfully.

### Test Hibernation

To test hibernation:

```bash
# Test hibernation
systemctl hibernate

# System will shut down, power it back on
# System should resume with all applications restored
```

To test suspend-then-hibernate (suspends to RAM, hibernates after 30 minutes):

```bash
systemctl suspend-then-hibernate
```

## Btrfs Maintenance

### Creating Snapshots

Create snapshots of your subvolumes for backup:

```bash
# Snapshot root
sudo btrfs subvolume snapshot / /.snapshots/@_$(date +%Y%m%d_%H%M%S)

# Snapshot home
sudo btrfs subvolume snapshot /home /.snapshots/@home_$(date +%Y%m%d_%H%M%S)
```

### Listing Snapshots

```bash
sudo btrfs subvolume list /
```

### Restoring from Snapshot

If you need to restore from a snapshot:

1. Boot from NixOS live ISO
2. Mount the btrfs partition:
```bash
mount /dev/nvme0n1p3 /mnt
cd /mnt
```

3. Rename current subvolume and restore snapshot:
```bash
sudo mv @ @_broken
sudo btrfs subvolume snapshot .snapshots/@_20250101_120000 @
```

4. Reboot into system

### Cleaning Old Snapshots

Remove old snapshots to free space:

```bash
sudo btrfs subvolume delete /.snapshots/@_20250101_120000
```

## Troubleshooting

### Disko fails with "Device is busy"

Unmount and deactivate everything:

```bash
sudo umount -R /mnt
sudo swapoff -a
sudo vgchange -an  # If using LVM
```

### Boot fails with "resume: no such device"

This typically means the swap partition UUID changed. Boot into live ISO and:

1. Check actual swap label:
```bash
sudo blkid | grep swap
```

2. Update configuration.nix if needed

### Hibernation fails

Check kernel logs:
```bash
journalctl -b | grep -i hibernate
dmesg | grep -i hibernate
```

Common issues:
- Swap size too small (should match or exceed RAM)
- Swap partition encrypted (disable randomEncryption in disko-config.nix)
- Incorrect resume= kernel parameter

### Btrfs errors

Check filesystem health:
```bash
sudo btrfs scrub start /
sudo btrfs scrub status /
```

## Advanced Configuration

### Enabling Btrfs Auto-Scrub

Add to configuration.nix:

```nix
services.btrfs.autoScrub = {
  enable = true;
  fileSystems = [ "/" ];
  interval = "weekly";
};
```

### Automatic Snapshots

Consider using:
- snapper: Automatic snapshot management
- btrbk: Backup tool for btrfs subvolumes

### Compression Analysis

Check compression ratio:

```bash
sudo compsize /
sudo compsize /home
sudo compsize /nix
```

## References

- Disko Documentation: https://github.com/nix-community/disko
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Btrfs Wiki: https://btrfs.readthedocs.io/
- NixOS Hibernate Documentation: https://nixos.wiki/wiki/Hibernation

## Security Considerations

This configuration does NOT include disk encryption. For encrypted setup:

1. Consider using LUKS encryption with disko
2. Configure TPM2 for automatic unlock
3. Use systemd-cryptenroll for security

Example encrypted disko config available in NixOS documentation.

## Support

For issues or questions:
1. Check NixOS Discourse: https://discourse.nixos.org/
2. Review disko examples: https://github.com/nix-community/disko/tree/master/example
3. Consult NixOS Matrix chat: #nixos:nixos.org
