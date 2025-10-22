# NixOS Modules Documentation

This document describes all available custom modules in the titan-os configuration.

## Module Categories

### Desktop Environment

Desktop-related applications and Wayland compositors.

#### Firefox
**Module:** `modules.desktop.firefox.enable`
**Location:** `/modules/desktop/firefox.nix`
**Description:** Firefox - Open source web browser with Wayland support

**Features:**
- Firefox with native Wayland support (firefox-wayland)
- System-wide Firefox program configuration
- Set as default browser

**Usage:**
```nix
modules.desktop.firefox.enable = true;
```

#### Niri
**Module:** `modules.desktop.niri.enable`
**Location:** `/modules/desktop/niri.nix`
**Description:** Niri - Scrollable-tiling Wayland compositor

#### Waybar
**Module:** `modules.desktop.waybar.enable`
**Location:** `/modules/desktop/waybar.nix`
**Description:** Waybar - Highly customizable Wayland status bar

#### Notification Daemons

##### Mako
**Module:** `modules.desktop.mako.enable`
**Location:** `/modules/desktop/mako.nix`
**Description:** Mako - Lightweight Wayland notification daemon

##### Dunst
**Module:** `modules.desktop.dunst.enable`
**Location:** `/modules/desktop/dunst.nix`
**Description:** Dunst - Lightweight notification daemon

#### Application Launchers

##### Rofi
**Module:** `modules.desktop.rofi.enable`
**Location:** `/modules/desktop/rofi.nix`
**Description:** Rofi - Application launcher

##### Fuzzel
**Module:** `modules.desktop.fuzzel.enable`
**Location:** `/modules/desktop/fuzzel.nix`
**Description:** Fuzzel - Application launcher for Wayland

##### Anyrun
**Module:** `modules.desktop.anyrun.enable`
**Location:** `/modules/desktop/anyrun.nix`
**Description:** Anyrun - Wayland-native application launcher

#### Wallpaper & Lock

##### Swaybg
**Module:** `modules.desktop.swaybg.enable`
**Location:** `/modules/desktop/swaybg.nix`
**Description:** Swaybg - Wallpaper daemon for Wayland

##### Swayidle
**Module:** `modules.desktop.swayidle.enable`
**Location:** `/modules/desktop/swayidle.nix`
**Description:** Swayidle - Idle management daemon

##### Swaylock
**Module:** `modules.desktop.swaylock.enable`
**Location:** `/modules/desktop/swaylock.nix`
**Description:** Swaylock - Screen locker for Wayland

#### Display & Session

##### XWayland-Satellite
**Module:** `modules.desktop.xwayland-satellite.enable`
**Location:** `/modules/desktop/xwayland-satellite.nix`
**Description:** XWayland-Satellite - Rootless XWayland integration

##### Greetd
**Module:** `modules.desktop.greetd.enable`
**Location:** `/modules/desktop/greetd.nix`
**Description:** Greetd - Minimal and flexible login manager

---

### Terminal Environment

Terminal emulators and shell configuration.

#### Kitty
**Module:** `modules.terminal.kitty.enable`
**Location:** `/modules/terminal/kitty.nix`
**Description:** Kitty - GPU-accelerated terminal emulator

**Features:**
- Kitty terminal emulator
- Wayland support enabled via KITTY_ENABLE_WAYLAND

**Usage:**
```nix
modules.terminal.kitty.enable = true;
```

#### Alacritty
**Module:** `modules.terminal.alacritty.enable`
**Location:** `/modules/terminal/alacritty.nix`
**Description:** Alacritty - GPU-accelerated terminal emulator

**Features:**
- Fast, GPU-accelerated terminal emulator written in Rust
- Native Wayland support via WINIT_UNIX_BACKEND
- Minimal configuration required

**Usage:**
```nix
modules.terminal.alacritty.enable = true;
```

#### Fish
**Module:** `modules.terminal.fish.enable`
**Location:** `/modules/terminal/fish.nix`
**Description:** Fish - User-friendly command line shell

#### Starship
**Module:** `modules.terminal.starship.enable`
**Location:** `/modules/terminal/starship.nix`
**Description:** Starship - Minimal, fast, and customizable prompt

---

### Development Tools

Development environments and tools.

#### Claude Code
**Module:** `modules.development.claude-code.enable`
**Location:** `/modules/development/claude-code.nix`
**Description:** Claude Code - AI-powered development assistant

#### Codex
**Module:** `modules.development.codex.enable`
**Location:** `/modules/development/codex.nix`
**Description:** Codex - Development tools and utilities

---

### CLI Utilities

Command-line tools and utilities.

#### CLI Tools
**Module:** `modules.utilities.cli-tools.enable`
**Location:** `/modules/utilities/cli-tools.nix`
**Description:** Collection of essential CLI tools

#### Yazi
**Module:** `modules.utilities.yazi.enable`
**Location:** `/modules/utilities/yazi.nix`
**Description:** Yazi - Terminal file manager

---

### Communication Apps

Communication and collaboration applications.

#### Vesktop
**Module:** `modules.communication.vesktop.enable`
**Location:** `/modules/communication/vesktop.nix`
**Description:** Vesktop - Discord client

#### Zoom
**Module:** `modules.communication.zoom.enable`
**Location:** `/modules/communication/zoom.nix`
**Description:** Zoom - Video conferencing application

---

## Usage

### Enabling Modules

Modules are enabled in your host configuration file (e.g., `hosts/launchpad/configuration.nix`):

```nix
{
  # Desktop Environment
  modules.desktop = {
    niri.enable = true;
    waybar.enable = true;
    firefox.enable = true;
  };

  # Terminal Environment
  modules.terminal = {
    kitty.enable = true;
    alacritty.enable = true;
    fish.enable = true;
    starship.enable = true;
  };

  # Development Tools
  modules.development = {
    claude-code.enable = true;
    codex.enable = true;
  };

  # CLI Utilities
  modules.utilities = {
    cli-tools.enable = true;
    yazi.enable = true;
  };

  # Communication Apps
  modules.communication = {
    vesktop.enable = true;
    zoom.enable = true;
  };
}
```

### Creating New Modules

1. **Create the module file** in the appropriate category directory:
   ```nix
   {
     config,
     lib,
     pkgs,
     ...
   }:
   with lib; let
     cfg = config.modules.category.name;
   in {
     options.modules.category.name = {
       enable = mkEnableOption "Description of the module";
     };

     config = mkIf cfg.enable {
       # Module configuration here
       environment.systemPackages = with pkgs; [
         package-name
       ];
     };
   }
   ```

2. **Import the module** in the category's `default.nix`:
   ```nix
   imports = [
     ./name.nix
   ];
   ```

3. **Enable the module** in your host configuration:
   ```nix
   modules.category.name.enable = true;
   ```

4. **Update this documentation** with the new module details.

### Module Structure

All modules follow a consistent structure:

- **Options section**: Defines the `enable` option using `mkEnableOption`
- **Config section**: Wrapped in `mkIf cfg.enable` for conditional activation
- **Package installation**: Uses `environment.systemPackages` for system-wide packages
- **Additional configuration**: Program-specific settings, environment variables, etc.

### Best Practices

1. **Use descriptive enable descriptions**: Make it clear what the module provides
2. **Follow naming conventions**: Use category-based namespacing
3. **Document options**: Add comments for non-obvious configurations
4. **Test modules**: Verify that enabling/disabling works correctly
5. **Keep modules focused**: Each module should handle one application or related set of applications

---

## Module Categories Structure

```
modules/
├── desktop/          # Desktop environment components
├── terminal/         # Terminal emulators and shells
├── development/      # Development tools
├── utilities/        # CLI utilities
└── communication/    # Communication applications
```

Each category has a `default.nix` that imports all modules in that category.
