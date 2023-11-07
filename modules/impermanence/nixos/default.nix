{
  config,
  inputs,
  lib,
  ...
}: {
  imports = ["${inputs.impermanence}/nixos.nix" ../../agenix/nixosModules];
  options.modules.impermanence.nixos.enable = lib.mkEnableOption "impermanence";

  config = lib.mkIf config.modules.impermanence.nixos.enable {
    modules.agenix.nixosModules.enable = true;

    environment.persistence."/persistent".directories = [
      "/etc/ssh"
      "/var/lib/systemd/timers"
    ];

    fileSystems = {
      # https://github.com/ryantm/agenix/issues/45
      "/etc/ssh" = {
        depends = ["/persistent"];
        neededForBoot = true;
      };

      "/persistent".neededForBoot = true;
    };
  };
}
