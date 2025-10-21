# Quick Start Guide - Titan OS Modules

## Enable/Disable Modules

Edit `/home/titan/.flakes/titan-os/hosts/launchpad/configuration.nix`:

```nix
# Desktop Environment
modules.desktop = {
  niri.enable = true;       # Niri window manager
  waybar.enable = true;     # Status bar
  mako.enable = true;       # Notifications
  rofi.enable = true;       # App launcher
};

# Development Tools
modules.development = {
  claude-code.enable = true;  # Claude Code editor
  codex.enable = true;        # Codex tool
};

# Terminal Environment
modules.terminal = {
  kitty.enable = true;      # Terminal emulator
  fish.enable = true;       # Fish shell
  starship.enable = true;   # Prompt
};

# CLI Utilities
modules.utilities = {
  cli-tools.enable = true;  # Essential CLI tools bundle
};

# Communication
modules.communication = {
  vesktop.enable = true;    # Discord client
  zoom.enable = true;       # Video conferencing
};
```

## Apply Configuration

```bash
# From /home/titan/.flakes/titan-os/

# Check for syntax errors
nix flake check

# Build without activating (test compilation)
sudo nixos-rebuild build --flake .#launchpad

# Test configuration (temporary activation until reboot)
sudo nixos-rebuild test --flake .#launchpad

# Apply permanently
sudo nixos-rebuild switch --flake .#launchpad
```

## Module Reference

| Category | Module | Description |
|----------|--------|-------------|
| **Desktop** | niri | Wayland compositor with scrollable tiling |
| | waybar | Status bar for Wayland |
| | mako | Notification daemon |
| | rofi | Application launcher |
| **Development** | claude-code | AI-powered code editor |
| | codex | Development tool |
| **Terminal** | kitty | GPU-accelerated terminal |
| | fish | User-friendly shell |
| | starship | Cross-shell prompt |
| **Utilities** | cli-tools | bat, fzf, ripgrep, curl, jq, yq, zoxide, fd, eza |
| **Communication** | vesktop | Discord client with Vencord |
| | zoom | Video conferencing |

## Common Tasks

### Add a New Module

1. Create module file:
   ```bash
   vim /home/titan/.flakes/titan-os/modules/CATEGORY/new-module.nix
   ```

2. Use this template:
   ```nix
   {
     config,
     lib,
     pkgs,
     ...
   }:
   with lib; let
     cfg = config.modules.CATEGORY.MODULE;
   in {
     options.modules.CATEGORY.MODULE = {
       enable = mkEnableOption "Description";
     };

     config = mkIf cfg.enable {
       environment.systemPackages = with pkgs; [
         package-name
       ];
     };
   }
   ```

3. Add to category's default.nix:
   ```nix
   imports = [
     ./existing.nix
     ./new-module.nix
   ];
   ```

4. Enable in configuration.nix:
   ```nix
   modules.CATEGORY.new-module.enable = true;
   ```

### Rollback to Previous Configuration

```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or boot into specific generation from GRUB menu
```

### Update All Channels

```bash
nix flake update
sudo nixos-rebuild switch --flake .#launchpad
```

## Troubleshooting

### Module Not Loading

1. Check imports in `/home/titan/.flakes/titan-os/modules/default.nix`
2. Verify category default.nix imports the module
3. Run `nix flake check` to find syntax errors

### Package Not Found

Some packages may be in different channels. Try:

```nix
# In module file:
environment.systemPackages = with pkgs-stable; [
  package-name
];

# Or
environment.systemPackages = with pkgs-edge; [
  package-name
];
```

### Build Fails

```bash
# Show detailed error output
sudo nixos-rebuild switch --flake .#launchpad --show-trace

# Check evaluation only
nix eval .#nixosConfigurations.launchpad.config.system.build.toplevel
```

## File Locations

- **Modules**: `/home/titan/.flakes/titan-os/modules/`
- **Host Config**: `/home/titan/.flakes/titan-os/hosts/launchpad/configuration.nix`
- **Flake**: `/home/titan/.flakes/titan-os/flake.nix`
- **Hardware**: `/home/titan/.flakes/titan-os/hosts/launchpad/hardware-configuration.nix`

## Next Steps

1. Review module configurations and disable unwanted features
2. Customize module options (see individual module files)
3. Add user-specific configurations via Home Manager
4. Configure secrets with sops-nix
5. Set up additional hosts following the same pattern
