{
  description = "NixOS system configurations with multi-channel support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-edge.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-edge,
    home-manager,
    disko,
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

    pkgs-unstableFor = system:
      import inputs.nixpkgs-unstable {
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
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs outputs;
          pkgs-stable = pkgsFor system;
          pkgs-unstable = pkgs-unstableFor system;
          pkgs-edge = pkgs-edgeFor system;
          noctalia = inputs.noctalia;
        };

        modules = [
          # Global nixpkgs + binary cache configuration
          {
            nixpkgs.config.allowUnfree = true;

            # Binary caches — avoid building from source where possible
            nix.settings = {
              substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
                "https://nixpkgs-wayland.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
              ];
              trusted-users = ["root" "titan"];
            };

            # Pin flake registry so `nix run/shell/search` use the same nixpkgs
            nix.registry = {
              nixpkgs.flake = inputs.nixpkgs;
              nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
            };
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
