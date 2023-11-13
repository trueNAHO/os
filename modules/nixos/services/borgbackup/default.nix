{
  config,
  lib,
  ...
}: let
  cfg = config.modules.nixos.services.borgbackup;
in {
  imports = [../../../agenix/nixosModules];

  options.modules.nixos.services.borgbackup = {
    enable = lib.mkEnableOption "borgbackup";

    encryption.mode = lib.mkOption {
      default = "repokey-blake2";

      description = ''
        Set the [`services.borgbackup.jobs.<name>.encryption.mode`](
        https://github.com/NixOS/nixpkgs/blob/ec750fd01963ab6b20ee1f0cb488754e8036d89d/nixos/modules/services/backup/borgbackup.nix#L389-L403)
        setting.
      '';

      example = "repokey";
      type = lib.types.str;
    };

    repo = lib.mkOption {
      description = ''
        Set the [`services.borgbackup.jobs.home.repo`](
        https://github.com/NixOS/nixpkgs/blob/ec750fd01963ab6b20ee1f0cb488754e8036d89d/nixos/modules/services/backup/borgbackup.nix#L389-L403)
        setting.
      '';

      example = "/path/to/repo";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    modules.agenix.nixosModules.enable = true;
    age.secrets.servicesBorgbackupJobsHome.file = ./home.age;

    services.borgbackup.jobs.home = {
      compression = "auto,zstd,9";
      doInit = false;

      encryption = {
        mode = cfg.encryption.mode;
        passCommand = "cat ${config.age.secrets.servicesBorgbackupJobsHome.path}";
      };

      environment.BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      paths = "/home";
      repo = cfg.repo;
    };
  };
}
