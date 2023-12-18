{inputs, ...}: {
  masterplan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        imports = [
          ../../modules/agenix/nixosModules/default
          ../../modules/disko/nixosModules
          ../../modules/environment/systemPackages/os
          ../../modules/impermanence/nixos
          ../../modules/nixos/networking
          ../../modules/nixos/nix/gc
          ../../modules/nixos/nix/settings/auto-optimise-store
          ../../modules/nixos/nix/settings/experimental-features
          ../../modules/nixos/security/sudo
          ../../modules/nixos/services/auto-cpufreq
          ../../modules/nixos/services/borgbackup
          ../../modules/nixos/services/btrbk
          ../../modules/nixos/services/openssh
          ../../modules/nixos/sound
          ../../modules/nixos/users/users/naho
          ../../modules/nixosHardware/nixosModules/tuxedo-pulse-15-gen2
          ./disko-config.nix
          ./hardware-configuration.nix
        ];

        modules = {
          agenix.nixosModules.default.enable = true;
          disko.nixosModules.enable = true;
          environment.systemPackages.os.enable = true;

          impermanence.nixos = {
            enable = true;
            path = "/persistent";
          };

          nixos = {
            networking = {
              enable = true;
              hostName = "masterplan";
              wpa_gui.enable = true;
            };

            nix = {
              gc.enable = true;

              settings = {
                auto-optimise-store.enable = true;
                experimental-features.enable = true;
              };
            };

            security.sudo.enable = true;

            services = {
              auto-cpufreq.enable = true;

              borgbackup = {
                enable = true;
                encryption.mode = "repokey";
                repo = "/mnt/borgbackup";
              };

              btrbk.enable = true;
              openssh.enable = true;
            };

            sound.enable = true;

            users.users.naho = {
              enable = true;
              enableInsecurePassword = true;
              enableUserConfigurationRequirements = true;
            };
          };

          nixosHardware.nixosModules.tuxedo-pulse-15-gen2.enable = true;
        };

        boot = {
          kernelParams = [
            "tuxedo_keyboard.mode=0"
          ];

          loader = {
            efi.canTouchEfiVariables = true;

            systemd-boot = {
              enable = true;
              editor = false;
            };
          };
        };

        environment.etc."machine-id".text = "c9afd40dc75e45c593c2fe07274e4395";
        hardware.tuxedo-keyboard.enable = true;
        nixpkgs.config.allowUnfree = true;

        system = {
          autoUpgrade = {
            enable = true;
            flake = "github:trueNAHO/os#masterplan";
          };

          stateVersion = "23.05";
        };

        time.timeZone = "Europe/Luxembourg";
        users.mutableUsers = false;
      }
    ];

    specialArgs = {inherit inputs;};
  };
}
