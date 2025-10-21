# Migration from titan-nix

This document explains what was restored from the titan-nix configuration and what was intentionally left out.

## What Was Restored

### 1. Multi-Channel Nixpkgs Setup

RESTORED from titan-nix lines 4-8:
```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
  nixpkgs-edge.url = "github:nixos/nixpkgs/master";
}
```

### 2. Package Set Factory Functions

RESTORED from titan-nix lines 99-118:
```nix
pkgsFor = system:
  import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

pkgs-stableFor = system:
  import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

pkgs-edgeFor = system:
  import inputs.nixpkgs-edge {
    inherit system;
    config.allowUnfree = true;
  };
```

Note: Removed commonOverlays since those were workarounds for broken packages.

### 3. mkSystem Helper Function

RESTORED from titan-nix lines 126-151:
```nix
mkSystem = {
  host,
  system ? "x86_64-linux",
  useStableKernel ? false,
}:
  nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs outputs;
      pkgs-stable = pkgs-stableFor system;
      pkgs-edge = pkgs-edgeFor system;
      pkgs-unstable =
        if useStableKernel
        then pkgs-stableFor system
        else pkgsFor system;
    };
    modules = [
      {
        nixpkgs.config.allowUnfree = true;
      }
      ./hosts/${host}/configuration.nix
    ];
  };
```

Note: Removed commonOverlays from nixpkgs.overlays since we don't need the Intel workarounds.

### 4. Multi-Host Support

RESTORED pattern from titan-nix lines 153-156:
```nix
nixosConfigurations = {
  launchpad = mkSystem { host = "launchpad"; };
  fob-titan = mkSystem { host = "fob-titan"; };
};
```

### 5. Development Shell Structure

RESTORED from titan-nix but simplified (removed pre-commit hooks and extra tools):
```nix
devShells = forAllSystems (system: let
  pkgs = pkgsFor system;
in {
  default = pkgs.mkShell {
    packages = with pkgs; [
      alejandra
      git
      sops
      nixos-rebuild
    ];
  };
});
```

## What Was NOT Restored

### 1. Package Overlays

REMOVED from titan-nix lines 87-96:
```nix
# These were workarounds for broken packages
commonOverlays = [
  (final: prev: {
    intel-graphics-compiler = prev.hello;
    intel-compute-runtime = prev.runCommand "..." {} ''...'';
  })
];
```

Reason: These were specific workarounds, not general-purpose configuration.

### 2. Extra Flake Inputs

NOT RESTORED:
- home-manager (can add if needed)
- alejandra (now using nixpkgs version)
- pre-commit-hooks (optional development tool)
- hyprland ecosystem (desktop-specific)
- nvf (neovim flake)
- stylix (theming system)

Reason: Keep the base configuration minimal. Users can add these as needed.

### 3. Pre-commit Hooks

NOT RESTORED from titan-nix:
```nix
pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
```

Reason: Optional development feature, not core to the multi-channel setup.

### 4. Specific Host Configurations

NOT RESTORED:
- Desktop-specific configurations
- Homelab-specific configurations
- Intel workarounds

Reason: Each system should define its own specific configuration.

## Key Differences

### titan-nix (Complex)
- 17 flake inputs
- Desktop-specific configurations (Hyprland)
- Hardware workarounds (Intel graphics)
- Pre-commit hooks
- Multiple specialized modules

### titan-os (Clean)
- 6 flake inputs (core only)
- Generic base configurations
- No hardware-specific workarounds
- Minimal dependencies
- Template-ready for any use case

## When to Add More

You might want to restore additional inputs when:

1. **Home Manager** - If managing user environment declaratively
   ```nix
   home-manager = {
     url = "github:nix-community/home-manager";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

2. **Hyprland** - If using Hyprland desktop
   ```nix
   hyprland.url = "github:hyprwm/Hyprland";
   ```

3. **Stylix** - If you want system-wide theming
   ```nix
   stylix = {
     url = "github:danth/stylix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

4. **Pre-commit Hooks** - If you want automated code quality checks
   ```nix
   pre-commit-hooks = {
     url = "github:cachix/pre-commit-hooks.nix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

## Usage Philosophy

### titan-nix Philosophy
"Everything configured, ready for desktop use"

### titan-os Philosophy
"Minimal foundation, add what you need"

The titan-os approach:
1. Provides the multi-channel infrastructure
2. Demonstrates the pattern with examples
3. Lets users add their specific requirements
4. Avoids assumptions about use case (desktop vs server vs development)

## Maintaining Both Configurations

If you want to keep both:

```bash
# titan-nix: Full desktop configuration
cd ~/.flakes/titan-nix
sudo nixos-rebuild switch --flake .#desktop

# titan-os: Clean multi-channel base
cd ~/.flakes/titan-os
sudo nixos-rebuild switch --flake .#launchpad
```

They serve different purposes:
- **titan-nix**: Production desktop with all features
- **titan-os**: Clean template for new systems or learning

## Summary

titan-os restores the **core architecture** from titan-nix:
- Multi-channel package management
- mkSystem helper function
- Package set factory functions
- Clean modular structure

But removes the **specific implementations**:
- Desktop environment configurations
- Hardware workarounds
- Optional development tools
- Application-specific modules

This creates a clean foundation that follows NixOS best practices while remaining flexible for any use case.
