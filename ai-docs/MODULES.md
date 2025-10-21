# Titan OS Modules Documentation

This document describes the modular NixOS configuration structure for Titan OS.

## Overview

The module system provides a clean, declarative way to enable system features through options. Each module follows a consistent pattern with `enable` options that can be toggled in the host configuration.

## Directory Structure

```
modules/
├── default.nix                    # Top-level module importer
├── desktop/                       # Desktop environment modules
│   ├── default.nix
│   ├── niri.nix                   # Niri Wayland compositor
│   ├── waybar.nix                 # Status bar
│   ├── mako.nix                   # Notification daemon
│   ├── rofi.nix                   # Application launcher
│   ├── fuzzel.nix                 # Wayland application launcher
│   ├── swaybg.nix                 # Wallpaper manager
│   ├── swayidle.nix               # Idle management daemon
│   ├── swaylock.nix               # Screen locker
│   ├── xwayland-satellite.nix     # Xwayland integration
│   └── greetd.nix                 # Display manager
├── development/                   # Development tools
│   ├── default.nix
│   ├── claude-code.nix            # Claude Code editor
│   └── codex.nix                  # Codex tool
├── terminal/                      # Terminal environment
│   ├── default.nix
│   ├── kitty.nix                  # Terminal emulator
│   ├── fish.nix                   # Fish shell
│   └── starship.nix               # Prompt customization
├── utilities/                     # System utilities
│   ├── default.nix
│   └── cli-tools.nix              # Essential CLI tools bundle
└── communication/                 # Communication applications
    ├── default.nix
    ├── vesktop.nix                # Discord client
    └── zoom.nix                   # Video conferencing
```

## Module Categories

### Desktop (modules.desktop)

Window manager, status bar, notifications, application launcher, and Wayland utilities.

- **niri** - Scrollable tiling Wayland compositor with full Wayland support
  - Includes XDG portal configuration
  - Wayland environment variables for electron/chromium apps
  - greetd login manager integration

- **waybar** - Highly customizable status bar for Wayland
  - System-wide configuration support

- **mako** - Lightweight notification daemon
  - Includes libnotify for notify-send

- **rofi** - Application launcher and window switcher
  - Wayland-native rofi-wayland package

- **fuzzel** - Wayland-native application launcher
  - Fast and lightweight alternative to rofi
  - System-wide configuration support

- **swaybg** - Wallpaper manager for Wayland
  - Simple background image setter

- **swayidle** - Idle management daemon for Wayland
  - Configurable idle timeout actions
  - System-wide configuration support

- **swaylock** - Screen locker for Wayland
  - Secure screen locking with PAM integration
  - Works with swayidle for automatic locking

- **xwayland-satellite** - Xwayland integration for Wayland compositors
  - Enables X11 application compatibility

- **greetd** - Display manager with gtkgreet greeter
  - Modern, lightweight login manager
  - Configured for niri session integration
  - Graphical greeter interface

### Development (modules.development)

Development tools and editors.

- **claude-code** - AI-powered code editor
- **codex** - Development tool

### Terminal (modules.terminal)

Terminal emulator, shell, and prompt customization.

- **kitty** - GPU-accelerated terminal emulator
  - Wayland support enabled

- **fish** - User-friendly shell with smart autosuggestions
  - Configured as system shell

- **starship** - Cross-shell prompt with git integration
  - System-wide configuration

### Utilities (modules.utilities)

Essential command-line tools and system utilities.

- **cli-tools** - Comprehensive CLI tools bundle including:
  - bat (syntax-highlighted cat)
  - fzf (fuzzy finder)
  - ripgrep (fast grep)
  - zip/unzip (compression)
  - curl (HTTP client)
  - jq (JSON processor)
  - yq (YAML processor)
  - zoxide (smart cd)
  - fd (better find)
  - eza (modern ls)

### Communication (modules.communication)

Messaging and conferencing applications.

- **vesktop** - Custom Discord client with Vencord built-in
- **zoom** - Video conferencing application

## Usage

### Enabling Modules in Host Configuration

In your host configuration file (e.g., `/home/titan/.flakes/titan-os/hosts/launchpad/configuration.nix`):

```nix
{
  imports = [
    ./hardware-configuration.nix
    ../../modules  # Import all modules
  ];

  # Enable desired modules
  modules.desktop = {
    niri.enable = true;
    waybar.enable = true;
    mako.enable = true;
    rofi.enable = false;
    fuzzel.enable = true;
    swaybg.enable = true;
    swayidle.enable = true;
    swaylock.enable = true;
    xwayland-satellite.enable = true;
    greetd.enable = true;
  };

  modules.development = {
    claude-code.enable = true;
    codex.enable = true;
  };

  modules.terminal = {
    kitty.enable = true;
    fish.enable = true;
    starship.enable = true;
  };

  modules.utilities = {
    cli-tools.enable = true;
  };

  modules.communication = {
    vesktop.enable = true;
    zoom.enable = true;
  };
}
```

### Module Pattern

Each module follows this consistent structure:

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
    enable = mkEnableOption "Description of module";
    # Additional options can be added here
  };

  config = mkIf cfg.enable {
    # Package installation
    environment.systemPackages = with pkgs; [
      package-name
    ];

    # Service configuration
    # programs.* settings
    # environment variables
    # etc.
  };
}
```

## Adding New Modules

To add a new module:

1. **Create the module file** in the appropriate category directory:
   ```bash
   touch modules/CATEGORY/new-module.nix
   ```

2. **Follow the module pattern** shown above

3. **Add import to category default.nix**:
   ```nix
   imports = [
     ./existing-module.nix
     ./new-module.nix  # Add this line
   ];
   ```

4. **Enable in host configuration**:
   ```nix
   modules.CATEGORY.new-module.enable = true;
   ```

## Creating New Categories

To create a new module category:

1. **Create the directory**:
   ```bash
   mkdir modules/new-category
   ```

2. **Create default.nix**:
   ```nix
   {
     config,
     lib,
     ...
   }:
   with lib; {
     imports = [
       ./module1.nix
       ./module2.nix
     ];
   }
   ```

3. **Add to top-level modules/default.nix**:
   ```nix
   imports = [
     ./desktop
     ./development
     ./terminal
     ./utilities
     ./communication
     ./new-category  # Add this line
   ];
   ```

## Benefits of This Structure

1. **Modularity** - Each feature is self-contained and can be enabled/disabled independently
2. **Maintainability** - Clear organization makes it easy to find and update configurations
3. **Reusability** - Modules can be shared across multiple host configurations
4. **Type Safety** - NixOS option system provides validation and documentation
5. **Discoverability** - Clear naming and structure makes it obvious what's available
6. **Consistency** - Uniform pattern across all modules reduces cognitive load

## Testing

To test your configuration without applying it:

```bash
# Check for syntax errors
nix flake check

# Build the configuration without activating
sudo nixos-rebuild build --flake .#launchpad

# Test the configuration (temporary activation)
sudo nixos-rebuild test --flake .#launchpad

# Apply the configuration permanently
sudo nixos-rebuild switch --flake .#launchpad
```

## Package Availability

Some packages may not be available in the standard nixpkgs channel. The flake configuration provides multiple channels:

- `pkgs` - Default channel (nixos-25.05)
- `pkgs-stable` - Stable channel (nixos-24.11)
- `pkgs-edge` - Latest unstable (nixos-unstable)
- `pkgs-unstable` - Alternative unstable source

These are available via specialArgs in your modules. Example:

```nix
{
  config,
  lib,
  pkgs,
  pkgs-edge,  # Available through specialArgs
  ...
}:
```

## Notes

- The Niri module includes greetd setup for display manager functionality
- Fish is automatically configured as the system shell when enabled
- Wayland environment variables are configured for proper electron/chromium app support
- All desktop modules assume a Wayland-based environment
- CLI tools bundle includes both traditional and modern alternatives (e.g., ls/eza, cat/bat)

## Future Enhancements

Potential additions to the module system:

- Hardware-specific modules (GPU drivers, laptop power management)
- Security modules (firewall profiles, hardening options)
- Backup and sync modules
- Container runtime modules (Docker, Podman)
- Programming language environments (Python, Node.js, Rust)
- Gaming modules (Steam, Lutris, game dependencies)
