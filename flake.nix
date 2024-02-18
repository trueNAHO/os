{
  description = "NAHO's NixOS Flake";

  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };

    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };

    disks = {
      inputs = {
        disko.follows = "disko";
        flakeUtils.follows = "flakeUtils";
        nixpkgs.follows = "nixpkgs";
        preCommitHooks.follows = "preCommitHooks";
      };

      url = "github:trueNAHO/disks";
    };

    flakeUtils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
    nixosHardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    preCommitHooks = {
      inputs = {
        flake-utils.follows = "flakeUtils";
        nixpkgs-stable.follows = "preCommitHooks/nixpkgs";
        nixpkgs.follows = "nixpkgs";
      };

      url = "github:cachix/pre-commit-hooks.nix";
    };
  };

  outputs = {
    self,
    disks,
    flakeUtils,
    nixpkgs,
    preCommitHooks,
    ...
  } @ inputs:
    flakeUtils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        checks =
          (
            pkgs.lib.attrsets.concatMapAttrs
            (k: v: {"${k}Package" = v;})
            inputs.self.packages.${system}
          )
          // {
            nixosConfigurationsBluetop =
              self.nixosConfigurations.bluetop.config.system.build.toplevel;

            nixosConfigurationsMasterplan =
              self.nixosConfigurations.masterplan.config.system.build.toplevel;

            preCommitHooks = preCommitHooks.lib.${system}.run {
              hooks = {
                alejandra.enable = true;
                convco.enable = true;
                typos.enable = true;
                yamllint.enable = true;
              };

              settings = {
                alejandra.verbosity = "quiet";
                typos.exclude = "*.age";
              };

              src = ./.;
            };
          };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.preCommitHooks) shellHook;
        };

        packages = {
          inherit (disks.packages.${system}) disko format mount shred;
        };
      }
    )
    // {
      nixosConfigurations = import ./hosts {inherit inputs;};
    };
}
