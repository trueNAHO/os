{
  config,
  lib,
  ...
}: {
  options.modules.services.xserver.desktopManager.enable =
    lib.mkEnableOption "the desktop manager";

  config = lib.mkIf config.modules.services.xserver.desktopManager.enable {
    services.xserver = {
      desktopManager.plasma5.enable = true;
      enable = true;
    };
  };
}
