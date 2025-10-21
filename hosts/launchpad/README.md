# Launchpad Host Configuration

NixOS configuration for the "launchpad" host with automated disk management using disko.

## System Specifications

- Hostname: launchpad
- Target Disk: /dev/nvme0n1 (NVMe SSD)
- Boot Mode: UEFI (systemd-boot)
- RAM: 32GB
- Swap: 32GB (hibernation-enabled)
- Root Filesystem: Btrfs with compression and subvolumes

## Architecture

### Disk Layout (Disko-managed)

```
/dev/nvme0n1
├── p1: 512MB    EFI System Partition → /boot
├── p2: 32GB     Swap (hibernation)   → swap
└── p3: Rest     Btrfs root           → /
```

### Btrfs Subvolumes

- `@` - Root filesystem (/)
- `@home` - User data (/home)
- `@nix` - Nix store (/nix)
- `@log` - System logs (/var/log)
- `@snapshots` - Snapshot storage (/.snapshots)

All subvolumes use zstd compression and optimized mount options.

### Features

- Hibernation support (32GB swap matching RAM)
- Automatic btrfs compression (zstd)
- Snapshot-ready subvolume structure
- UEFI boot with systemd-boot
- Optimized for NVMe storage

## Configuration Files

- `configuration.nix` - Main system configuration
- `disko-config.nix` - Disk partitioning and filesystem layout
- `hardware-configuration.nix` - Hardware-specific settings (placeholder)
- `DEPLOYMENT_QUICKSTART.md` - Quick deployment reference

## Deployment

See the deployment guides:

1. **Quick Start**: `DEPLOYMENT_QUICKSTART.md` - Condensed command reference
2. **Full Guide**: `/home/titan/.flakes/titan-os/DISKO_USAGE.md` - Complete documentation

### One-Line Summary

```bash
# Boot NixOS ISO, then:
sudo nix run github:nix-community/disko -- --mode disko hosts/launchpad/disko-config.nix
sudo nixos-install --flake .#launchpad
```

## Module Configuration

This host uses the following modules:

**Desktop Environment:**
- Niri (Wayland compositor)
- Waybar, Mako, Fuzzel
- Swaybg, Swayidle, Swaylock
- Xwayland-satellite
- Greetd (login manager)

**Development:**
- Claude Code
- Codex

**Terminal:**
- Kitty
- Fish shell with Starship prompt

**Utilities:**
- CLI tools suite

**Communication:**
- Vesktop (Discord)
- Zoom

## Post-Installation

### Test Hibernation

```bash
systemctl hibernate
```

System will shut down and write RAM to swap. On boot, it will restore session.

### Create Snapshots

```bash
sudo btrfs subvolume snapshot / /.snapshots/@_$(date +%Y%m%d_%H%M%S)
```

### Verify Btrfs Compression

```bash
sudo compsize /
```

### System Updates

```bash
sudo nixos-rebuild switch --flake .#launchpad
```

## Maintenance

### Snapshot Management

List snapshots:
```bash
sudo btrfs subvolume list /
```

Delete old snapshot:
```bash
sudo btrfs subvolume delete /.snapshots/@_20250101_120000
```

### Filesystem Health

Check and repair:
```bash
sudo btrfs scrub start /
sudo btrfs scrub status /
```

### Hibernation Issues

View logs:
```bash
journalctl -b | grep -i hibernate
```

## Security Notes

This configuration does NOT include disk encryption. For production systems, consider:

1. LUKS full-disk encryption
2. TPM2 integration for auto-unlock
3. Secure Boot configuration

## References

- [Disko Documentation](https://github.com/nix-community/disko)
- [Btrfs Wiki](https://btrfs.readthedocs.io/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Hibernation](https://nixos.wiki/wiki/Hibernation)
