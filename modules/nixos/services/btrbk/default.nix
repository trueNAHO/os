{
  config,
  lib,
  ...
}: {
  options.modules.nixos.services.btrbk = {
    enable = lib.mkEnableOption "btrbk";

    snapshotDir = lib.mkOption {
      description = "Path to Btrbk's snapshot directory.";
      example = "/nix/btrbk";
      type = lib.types.str;
    };
  };

  config = let
    cfg = config.modules.nixos.services.btrbk;
  in
    lib.mkIf cfg.enable {
      services.btrbk.instances.home = {
        onCalendar = "hourly";

        settings = {
          snapshot_dir = cfg.snapshotDir;
          snapshot_preserve = "7d 5w";
          snapshot_preserve_min = "2d";
          subvolume = "/home";
        };
      };

      systemd.tmpfiles.rules = ["d ${cfg.snapshotDir} 700"];
    };
}
