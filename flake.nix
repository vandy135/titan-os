{
  description = "NixOS system configurations with multi-channel support";

  inputs = {
    # Primary nixpkgs channels
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs-edge.url = "github:nixos/nixpkgs/master";

    # Disk partitioning and formatting framework
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management with Mozilla SOPS
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-edge,
    disko,
    sops-nix,
    nixos-hardware,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Supported systems
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Package set factory functions for each channel
    # These create configured package sets for a given system
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

    # Helper function to create a NixOS system configuration
    # This standardizes how we build systems and provides consistent access
    # to multiple nixpkgs channels through specialArgs
    mkSystem = {
      host,
      system ? "x86_64-linux",
      useStableKernel ? false,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs outputs;

          # Provide all three package sets to all modules
          # This allows modules to selectively use packages from different channels
          pkgs-stable = pkgs-stableFor system;
          pkgs-edge = pkgs-edgeFor system;
          pkgs-unstable =
            if useStableKernel
            then pkgs-stableFor system
            else pkgsFor system;
        };

        modules = [
          # Global nixpkgs configuration applied to all hosts
          {
            nixpkgs.config.allowUnfree = true;
          }

          # Disko module for declarative disk management
          inputs.disko.nixosModules.disko

          # Host-specific configuration
          ./hosts/${host}/configuration.nix
        ];
      };
  in {
    # NixOS system configurations
    nixosConfigurations = {
      launchpad = mkSystem {
        host = "launchpad";
      };

      fob-aspen = mkSystem {
        host = "fob-aspen";
      };
    };

    # Code formatter - use with 'nix fmt'
    formatter = forAllSystems (system: (pkgsFor system).alejandra);
  };
}
