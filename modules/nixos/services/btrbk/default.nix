{
  config,
  lib,
  ...
}: {
  options.modules.nixos.services.btrbk.enable = lib.mkEnableOption "btrbk";

  config = lib.mkIf config.modules.nixos.services.btrbk.enable {
    services.btrbk.instances.home = {
      onCalendar = "hourly";

      settings = {
        snapshot_dir = "/nix/btrbk";
        snapshot_preserve = "7d 5w";
        snapshot_preserve_min = "2d";
        subvolume = "/home";
      };
    };
  };
}
