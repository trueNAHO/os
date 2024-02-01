{
  config,
  lib,
  ...
}: {
  options.modules.nixos.boot.blacklistedKernelModules.uvcvideo.enable =
    lib.mkEnableOption "boot.blacklistedKernelModules";

  config =
    lib.mkIf
    config.modules.nixos.boot.blacklistedKernelModules.uvcvideo.enable {
      boot.blacklistedKernelModules = ["uvcvideo"];
    };
}
