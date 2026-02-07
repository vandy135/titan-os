{
  description = "NixOS system configurations with multi-channel support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs-edge.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-edge,
    home-manager,
    disko,
    sops-nix,
    nixos-hardware,
    ...
  } @ inputs: let
    inherit (self) outputs;

    supportedSystems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

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

          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }

          ./hosts/${host}/configuration.nix
        ];
      };
  in {
    nixosConfigurations = {
      launchpad = mkSystem {
        host = "launchpad";
      };

      fob-aspen = mkSystem {
        host = "fob-aspen";
      };
    };

    formatter = forAllSystems (system: (pkgsFor system).alejandra);
  };
}
