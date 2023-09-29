{
  description = "NAHO's NixOS Flake";

  inputs = {
    flakeUtils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
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
    flakeUtils,
    nixpkgs,
    preCommitHooks,
    ...
  } @ inputs:
    flakeUtils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        checks = {
          nixosConfigurationsMasterplan =
            self.nixosConfigurations.masterplan.config.system.build.toplevel;

          preCommitHooks = preCommitHooks.lib.${system}.run {
            hooks = {
              alejandra.enable = true;
              convco.enable = true;
              shellcheck.enable = true;

              shfmt = {
                enable = true;
                entry =
                  pkgs.lib.mkForce
                  "${pkgs.shfmt}/bin/${pkgs.shfmt.pname} --case-indent --indent 2 --write";
              };
            };

            settings.alejandra.verbosity = "quiet";
            src = ./.;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.preCommitHooks) shellHook;
        };
      }
    )
    // {
      nixosConfigurations = import ./hosts {inherit inputs;};
    };
}
