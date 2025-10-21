# Launchpad Deployment Quick Reference

This is a condensed deployment guide. See `/home/titan/.flakes/titan-os/DISKO_USAGE.md` for detailed instructions.

## Pre-Installation Checklist

- [ ] NixOS Live ISO booted
- [ ] Network connectivity confirmed
- [ ] Flake repository accessible
- [ ] Backup of any important data on /dev/nvme0n1
- [ ] Confirmed disk device is /dev/nvme0n1

## Installation Commands

```bash
# 1. Install disko
nix-shell -p disko

# 2. Clone/copy your flake
cd /path/to/titan-os

# 3. VERIFY DISK DEVICE (DESTRUCTIVE OPERATION)
lsblk
# Confirm /dev/nvme0n1 is correct before proceeding

# 4. Partition and format with disko
sudo nix run github:nix-community/disko -- \
  --mode disko \
  hosts/launchpad/disko-config.nix

# 5. Verify mounts
mount | grep /mnt
swapon --show

# 6. Generate hardware configuration
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/launchpad/hardware-configuration.nix

# 7. Install NixOS
sudo nixos-install --flake .#launchpad

# 8. Set user password
sudo nixos-enter
passwd titan
exit

# 9. Reboot
reboot
```

## Post-Installation Verification

```bash
# Check swap
swapon --show

# Verify resume parameter
cat /proc/cmdline | grep resume

# Test hibernation
systemctl hibernate
```

## Expected Disk Layout

```
/dev/nvme0n1p1  512MB   /boot      (FAT32)
/dev/nvme0n1p2  32GB    swap       (hibernation)
/dev/nvme0n1p3  Rest    /          (btrfs with subvolumes)
```

## Btrfs Subvolumes

```
@           → /
@home       → /home
@nix        → /nix
@log        → /var/log
@snapshots  → /.snapshots
```

## Snapshot Management

Create snapshot:
```bash
sudo btrfs subvolume snapshot / /.snapshots/@_$(date +%Y%m%d_%H%M%S)
```

List snapshots:
```bash
sudo btrfs subvolume list /
```

## Troubleshooting

Device busy error:
```bash
sudo umount -R /mnt
sudo swapoff -a
```

Check hibernation logs:
```bash
journalctl -b | grep -i hibernate
```

## Key Files

- Disko config: `/home/titan/.flakes/titan-os/hosts/launchpad/disko-config.nix`
- Main config: `/home/titan/.flakes/titan-os/hosts/launchpad/configuration.nix`
- Hardware config: `/home/titan/.flakes/titan-os/hosts/launchpad/hardware-configuration.nix`
- Full guide: `/home/titan/.flakes/titan-os/DISKO_USAGE.md`
