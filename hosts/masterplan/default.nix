{inputs, ...}: {
  masterplan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        imports = [
          "${inputs.impermanence}/nixos.nix"
          ../../modules/networking.nix
          ../../modules/nix/flake.nix
          ../../modules/nix/optimisation.nix
          ../../modules/services/auto-cpufreq.nix
          ../../modules/services/openssh.nix
          ../../modules/services/xserver/desktopManager.nix
          ../../modules/services/xserver/displayManager.nix
          ../../modules/sound.nix
          ../../modules/users/users/naho.nix
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
          };

          nix = {
            flake.enable = true;
            optimisation.enable = true;
          };

          services = {
            auto-cpufreq.enable = true;
            openssh.enable = true;

            xserver = {
              desktopManager.enable = true;
              displayManager.enable = true;
            };
          };

          sound.enable = true;

          users.users.naho = {
            enable = true;
            insecureInitialHashedPassword = true;
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
          persistence."/persistent".directories = ["/etc/ssh"];
        };

        fileSystems."/persistent".neededForBoot = true;
        nixpkgs.config.allowUnfree = true;
        programs.dconf.enable = true;
        services.printing.enable = true;

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
