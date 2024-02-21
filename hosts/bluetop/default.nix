{inputs, ...}: {
  bluetop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        imports = [
          ../../modules/agenix/nixosModules/default
          ../../modules/disko/nixosModules
          ../../modules/environment/systemPackages/os
          ../../modules/impermanence/nixos
          ../../modules/nixos/boot/blacklistedKernelModules
          ../../modules/nixos/networking
          ../../modules/nixos/nix/gc
          ../../modules/nixos/nix/settings/auto_optimise_store
          ../../modules/nixos/nix/settings/experimental_features
          ../../modules/nixos/security/sudo
          ../../modules/nixos/services/auto_cpufreq
          ../../modules/nixos/services/borgbackup
          ../../modules/nixos/services/btrbk
          ../../modules/nixos/services/openssh
          ../../modules/nixos/sound
          ../../modules/nixos/users/users/naho
          ./disko.nix
          ./hardware_configuration.nix
        ];

        modules = {
          agenix.nixosModules.default.enable = true;
          disko.nixosModules.enable = true;
          environment.systemPackages.os.enable = true;

          impermanence.nixos = {
            btrfsSubvolumes = {
              enable = true;
              rootFilesystem = "/dev/mapper/luks";
              rootSubvolume = "root";
            };

            enable = true;
            path = "/persistent";
          };

          nixos = {
            boot.blacklistedKernelModules.uvcvideo.enable = true;

            networking = {
              enable = true;
              hostName = "bluetop";
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

              btrbk = {
                enable = true;
                snapshotDir = "/nix/btrbk";
              };

              openssh.enable = true;
            };

            sound.enable = true;

            users.users.naho = {
              enable = true;
              enableInsecurePassword = true;
              enableUserConfigurationRequirements = true;
            };
          };
        };

        boot.loader = {
          efi.canTouchEfiVariables = true;

          systemd-boot = {
            enable = true;
            editor = false;
          };
        };

        environment.etc."machine-id".text = "c9afd40dc75e45c593c2fe07274e4395";
        nixpkgs.config.allowUnfree = true;

        system = {
          autoUpgrade = {
            enable = true;
            flake = "github:trueNAHO/os#bluetop";
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
