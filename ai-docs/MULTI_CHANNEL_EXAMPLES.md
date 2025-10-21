# Multi-Channel Usage Examples

This document demonstrates practical patterns for using multiple nixpkgs channels in your NixOS configuration.

## Basic Channel Selection

### Use Case: Stable System with Latest Development Tools

```nix
# hosts/fob-titan/configuration.nix
{
  config,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}: {
  # Use stable kernel for reliability
  boot.kernelPackages = pkgs-stable.linuxPackages;

  # Mix packages from different channels
  environment.systemPackages = [
    # Core system utilities from stable
    pkgs-stable.coreutils
    pkgs-stable.systemd

    # Latest development tools from unstable
    pkgs.neovim
    pkgs.vscode
    pkgs.git

    # Bleeding-edge tools from master
    pkgs-edge.zed-editor
  ];

  # Use stable version of critical services
  services.postgresql = {
    enable = true;
    package = pkgs-stable.postgresql_16;
  };
}
```

## Advanced Patterns

### Pattern 1: Version-Specific Dependencies

When you need a specific version of a package that's only in one channel:

```nix
{pkgs, pkgs-stable, ...}: {
  environment.systemPackages = [
    # Use specific Python version from stable
    pkgs-stable.python311

    # But use latest Python packages from unstable
    pkgs.python312Packages.numpy
    pkgs.python312Packages.pandas
  ];
}
```

### Pattern 2: Fallback Strategy

Try unstable first, fall back to stable if broken:

```nix
{pkgs, pkgs-stable, ...}: let
  # Helper to choose package with fallback
  preferUnstable = pkg:
    if builtins.hasAttr pkg pkgs
    then pkgs.${pkg}
    else pkgs-stable.${pkg};
in {
  environment.systemPackages = [
    (preferUnstable "firefox")
    (preferUnstable "chromium")
  ];
}
```

### Pattern 3: Service with Specific Version

Pin a critical service to stable while using unstable for everything else:

```nix
{pkgs, pkgs-stable, ...}: {
  # Database from stable for reliability
  services.mysql = {
    enable = true;
    package = pkgs-stable.mysql80;
  };

  # Web server from unstable for latest features
  services.nginx = {
    enable = true;
    package = pkgs.nginx;
  };
}
```

### Pattern 4: Development Environment

Different channels for different development stacks:

```nix
{pkgs, pkgs-stable, pkgs-edge, ...}: {
  environment.systemPackages = [
    # Rust toolchain from unstable
    pkgs.rustc
    pkgs.cargo
    pkgs.rust-analyzer

    # Node.js LTS from stable
    pkgs-stable.nodejs_20

    # Cutting-edge Bun from edge
    pkgs-edge.bun

    # Go from unstable
    pkgs.go
  ];
}
```

### Pattern 5: Overlay for Cross-Channel Package

Create an overlay to combine packages from different channels:

```nix
{
  config,
  pkgs,
  pkgs-stable,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      # Create custom package using stable base
      my-custom-python = pkgs-stable.python311.withPackages (ps:
        with ps; [
          # Mix stable and unstable Python packages
          pkgs-stable.python311Packages.requests
          pkgs.python311Packages.httpx
        ]);
    })
  ];

  environment.systemPackages = [
    pkgs.my-custom-python
  ];
}
```

## Kernel Management

### Using Stable Kernel System-Wide

In `flake.nix`:

```nix
nixosConfigurations = {
  production-server = mkSystem {
    host = "production-server";
    useStableKernel = true;  # This sets pkgs-unstable = pkgs-stable
  };
};
```

Then in configuration:

```nix
{pkgs-unstable, ...}: {
  # This will use stable kernel even though it looks like unstable
  boot.kernelPackages = pkgs-unstable.linuxPackages;
}
```

### Mixed Kernel Strategy

Use stable kernel but unstable modules:

```nix
{pkgs, pkgs-stable, ...}: {
  # Stable kernel
  boot.kernelPackages = pkgs-stable.linuxPackages_latest;

  # But use latest ZFS from unstable if needed
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.package = pkgs.zfs;
}
```

## Desktop Environment Examples

### Hyprland from Edge with Stable Base

```nix
{
  pkgs,
  pkgs-stable,
  pkgs-edge,
  ...
}: {
  # Stable Xorg/Wayland base
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
  };

  # Latest Hyprland from edge
  programs.hyprland = {
    enable = true;
    package = pkgs-edge.hyprland;
  };

  environment.systemPackages = [
    # Stable system tools
    pkgs-stable.alacritty
    pkgs-stable.firefox

    # Latest utilities from unstable
    pkgs.waybar
    pkgs.rofi-wayland

    # Bleeding-edge tools
    pkgs-edge.hyprpaper
  ];
}
```

## Channel Selection Decision Tree

```
Need a package? Follow this decision tree:

1. Is it a critical system component (kernel, systemd, glibc)?
   YES -> Use pkgs-stable
   NO  -> Continue

2. Is it a desktop application or CLI tool?
   YES -> Use pkgs (unstable) for latest features
   NO  -> Continue

3. Is it a development tool you need latest version of?
   YES -> Check pkgs first, pkgs-edge if very new
   NO  -> Continue

4. Is it a server/service for production?
   YES -> Use pkgs-stable for reliability
   NO  -> Continue

5. Do you need a cutting-edge feature only in master?
   YES -> Use pkgs-edge (but be prepared for breakage)
   NO  -> Default to pkgs (unstable)
```

## Testing Channel Differences

### Check Package Versions Across Channels

```bash
# Compare package versions
nix eval .#nixosConfigurations.fob-titan.pkgs.firefox.version
nix eval .#nixosConfigurations.fob-titan.config.specialArgs.pkgs-stable.firefox.version
nix eval .#nixosConfigurations.fob-titan.config.specialArgs.pkgs-edge.firefox.version

# Or use nix eval directly
nix eval nixpkgs#firefox.version
nix eval nixpkgs-stable#firefox.version
```

### Test Build Before Applying

```bash
# Build configuration without switching
sudo nixos-rebuild build --flake .#fob-titan

# Test configuration (temporary activation)
sudo nixos-rebuild test --flake .#fob-titan

# Only switch if test successful
sudo nixos-rebuild switch --flake .#fob-titan
```

## Common Pitfalls

### Pitfall 1: Mixing Incompatible Versions

WRONG:
```nix
{pkgs, pkgs-stable, ...}: {
  # Python from stable, packages from unstable - may break!
  environment.systemPackages = [
    pkgs-stable.python311
    pkgs.python311Packages.django  # Different Python ABI!
  ];
}
```

CORRECT:
```nix
{pkgs, pkgs-stable, ...}: {
  # Keep Python and its packages from same channel
  environment.systemPackages = [
    (pkgs-stable.python311.withPackages (ps: with ps; [
      django
      requests
    ]))
  ];
}
```

### Pitfall 2: Not Updating Lock File

After changing channel usage, always update:

```bash
nix flake update
```

### Pitfall 3: Assuming Package Names Match

Some packages have different names across channels:

```nix
{pkgs, pkgs-stable, ...}: {
  environment.systemPackages = [
    # Check package exists in channel first!
    pkgs.firefox  # May exist
    # pkgs-stable.firefox-bin  # Might be named differently
  ];
}
```

Search first: `nix search nixpkgs#firefox` and `nix search nixpkgs-stable#firefox`

## Summary

Use this hierarchy for channel selection:

1. **pkgs-stable**: Kernels, critical services, production systems
2. **pkgs (unstable)**: Desktop apps, dev tools, general use
3. **pkgs-edge**: Experimental features, latest releases (use sparingly)
4. **pkgs-unstable**: Alias that respects `useStableKernel` flag

Always test configurations before deploying to production systems.
