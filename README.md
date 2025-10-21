# titan-os NixOS Configuration

Multi-channel, multi-host NixOS configuration using flakes.

## Architecture

### Multi-Channel Package Management

This configuration provides access to three nixpkgs channels:

- **nixpkgs (unstable)**: Primary channel, latest packages
- **nixpkgs-stable (release-25.05)**: Stable release channel
- **nixpkgs-edge (master)**: Bleeding-edge packages from master branch

All three package sets are available in every module through `specialArgs`:

```nix
{
  config,
  pkgs,           # Default (unstable)
  pkgs-stable,    # Stable channel
  pkgs-edge,      # Master branch
  pkgs-unstable,  # Alias to unstable (or stable if useStableKernel = true)
  ...
}: {
  environment.systemPackages = with pkgs; [
    vim              # From unstable
    pkgs-stable.git  # Explicitly from stable
    pkgs-edge.neovim # Bleeding-edge package
  ];
}
```

### System Configuration Helper

The `mkSystem` helper function standardizes host creation:

```nix
mkSystem = {
  host,                      # Required: host directory name
  system ? "x86_64-linux",   # Optional: target architecture
  useStableKernel ? false,   # Optional: use stable kernel
}
```

## Hosts

### launchpad
Production system configuration.

### fob-titan
Secondary system configuration.

## Usage

### Initial Setup

1. **Generate hardware configuration** (for new hosts):
   ```bash
   nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```

2. **Update flake lock file**:
   ```bash
   nix flake update
   ```

3. **Build and switch** (requires root):
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

### Common Commands

```bash
# Enter development shell
nix develop

# Format Nix files
nix fmt

# Check flake
nix flake check --no-build

# Show flake outputs
nix flake show

# Update specific input
nix flake lock --update-input nixpkgs

# Build without switching
sudo nixos-rebuild build --flake .#<hostname>

# Test configuration (doesn't update bootloader)
sudo nixos-rebuild test --flake .#<hostname>
```

### Managing Channels

Update all channels:
```bash
nix flake update
```

Update specific channel:
```bash
nix flake lock --update-input nixpkgs-stable
```

Pin a channel to specific commit:
```nix
nixpkgs-stable.url = "github:nixos/nixpkgs/abc123...";
```

## Adding a New Host

1. Create host directory:
   ```bash
   mkdir -p hosts/<hostname>
   ```

2. Add configuration files:
   ```bash
   cp hosts/launchpad/configuration.nix hosts/<hostname>/
   nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```

3. Add to flake.nix:
   ```nix
   nixosConfigurations = {
     # ... existing hosts
     <hostname> = mkSystem {
       host = "<hostname>";
     };
   };
   ```

4. Customize configuration and deploy.

## Directory Structure

```
.
├── flake.nix              # Main flake definition
├── flake.lock             # Locked dependency versions
├── hosts/
│   ├── launchpad/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── fob-titan/
│       ├── configuration.nix
│       └── hardware-configuration.nix
└── README.md
```

## Best Practices

1. **Use specific channels for specific needs**:
   - Default to unstable for most packages
   - Use stable for critical system components
   - Use edge sparingly for cutting-edge features

2. **Test before deploying**:
   ```bash
   sudo nixos-rebuild test --flake .#<hostname>
   ```

3. **Keep hardware-configuration.nix up-to-date**:
   - Regenerate after hardware changes
   - Review and commit changes

4. **Regular updates**:
   ```bash
   nix flake update
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

5. **Backup before major changes**:
   - NixOS supports rollbacks via boot menu
   - Can also rollback with: `sudo nixos-rebuild switch --rollback`

## Troubleshooting

### Build failures after update
```bash
# Rollback flake.lock
git checkout flake.lock

# Or update individual inputs
nix flake lock --update-input nixpkgs
```

### Package not available in channel
```bash
# Search in different channels
nix search nixpkgs#<package>
nix search nixpkgs-stable#<package>

# Check package availability
nix eval nixpkgs#<package>.version
nix eval nixpkgs-stable#<package>.version
```

### Kernel issues with unstable
```nix
# Use stable kernel
<hostname> = mkSystem {
  host = "<hostname>";
  useStableKernel = true;
};
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [nixpkgs Search](https://search.nixos.org/packages)
- [NixOS Discourse](https://discourse.nixos.org/)
