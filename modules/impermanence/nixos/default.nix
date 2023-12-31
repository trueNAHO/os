{
  config,
  inputs,
  lib,
  ...
}: {
  imports = ["${inputs.impermanence}/nixos.nix" ../../agenix/nixosModules];

  options.modules.impermanence.nixos = {
    enable = lib.mkEnableOption "impermanence";

    path = lib.mkOption {
      default = "/persistent";
      description = "Path to the persistent storage directory.";
      example = "/persist";
      type = lib.types.str;
    };
  };

  config = let
    cfg = config.modules.impermanence.nixos;
  in
    lib.mkIf cfg.enable {
      modules.agenix.nixosModules.enable = true;

      environment.persistence.${cfg.path}.directories = [
        "/etc/ssh"
        "/var/lib/systemd/timers"
      ];

      fileSystems = {
        # https://github.com/ryantm/agenix/issues/45
        "/etc/ssh" = {
          depends = [cfg.path];
          neededForBoot = true;
        };

        ${cfg.path}.neededForBoot = true;
      };
    };
}
