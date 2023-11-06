{inputs, ...}: {
  masterplan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        imports = [
          "${inputs.impermanence}/nixos.nix"
          ../../modules/networking
          ../../modules/nix/flake
          ../../modules/nix/optimisation
          ../../modules/security/sudo
          ../../modules/services/auto-cpufreq
          ../../modules/services/btrbk
          ../../modules/services/openssh
          ../../modules/sound
          ../../modules/users/users/naho
          ./disko-config.nix
          ./hardware-configuration.nix
          inputs.agenix.nixosModules.default
          inputs.disko.nixosModules.disko
          inputs.nixosHardware.nixosModules.tuxedo-pulse-15-gen2
        ];

        modules = {
          networking = {
            enable = true;
            hostName = "masterplan";
            wpa_gui.enable = true;
          };

          nix = {
            flake.enable = true;
            optimisation.enable = true;
          };

          security.sudo.enable = true;

          services = {
            auto-cpufreq.enable = true;
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

        boot.loader = {
          efi.canTouchEfiVariables = true;

          systemd-boot = {
            enable = true;
            editor = false;
          };
        };

        environment = {
          etc."machine-id".text = "c9afd40dc75e45c593c2fe07274e4395";

          persistence."/persistent".directories = [
            "/etc/ssh"
            "/var/lib/systemd/timers"
          ];
        };

        fileSystems = {
          # https://github.com/ryantm/agenix/issues/45
          "/etc/ssh" = {
            depends = ["/persistent"];
            neededForBoot = true;
          };

          "/persistent".neededForBoot = true;
        };

        hardware = {
          amdgpu.loadInInitrd = false;
          enableAllFirmware = true;
        };

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
  };
}
